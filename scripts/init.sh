#!/bin/bash

checkutil () {
    if [ -z "$(which $@)" ]; then
        echo "Could not find \"$@\" anywhere, please install it\!"
        exit 1
    fi
}

# echo "--> Starting intialization script..."
export AWS_REGION=$(jq '.region' ../terraform/project/main/dev.vars.json | sed 's/"//g')
export CLUSTER_NAME=$(cat ../terraform/project/main/dev.vars.json | jq '.eks_cluster_name' | sed 's/"//g')
cd ../terraform/project/main
export DB_ID=$(terraform state pull | jq '.outputs.db_instance_data.value.db_instance_data.db_instance_id' | sed 's/"//g')
cd -
export DB_USER=$(cat ../terraform/project/main/dev.vars.json | jq '.db_username' | sed 's/"//g')
export DB_PASSWD=$(cat ../terraform/project/main/dev.vars.json | jq '.db_password' | sed 's/"//g')
export LOCAL_SUBSCRIBERS_REGEXP=$(cat ../terraform/project/main/dev.vars.json | jq '.local_subscribers_regexp' | sed 's/"//g')

echo "--> Configuring access to EKS..."
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
sleep 3 # sleep 5 # read -p "Press enter to continue"

echo "--> Resolving DB params..."
export DB_ADDRESS=$(aws --region=us-east-1 rds describe-db-instances --db-instance-identifier $DB_ID | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g')

# Check if aws command is available
checkutil "aws"

# Check if kubectl command is available
checkutil "kubectl"

# Check if heml command is available
checkutil "helm"

# Install consul
echo "--> Install consul..."
if [ "$(helm list --all-namespaces | grep 'consul' | wc -l)" -eq "1" ]; then
    echo "Consul chart already installed, skipping."
else
    helm repo add hashicorp https://helm.releases.hashicorp.com
    #helm install -f consul/helm-consul-values.yaml hashicorp hashicorp/consul
    helm install --values consul/helm-consul-values.yaml consul hashicorp/consul --set global.name=consul --create-namespace --namespace consul    
    sleep 5 # sleep 5 # read -p "Press enter to continue"
    # Get kubernetes' DNS IP, configure the configMap and apply it
    export CONSUL_DNS_IP=$(kubectl get svc -n consul consul-dns -o jsonpath='{.spec.clusterIP}')
    # Replace and apply the confuigmap for consul-dns
    sed "s/{{ CONSUL_DNS_IP }}/$CONSUL_DNS_IP/g" consul/dns-configMap-template.yaml > consul/dns-configMap.yaml 
    kubectl apply -f consul/dns-configMap.yaml
    sleep 5 # sleep 5 # read -p "Press enter to continue"
    # Add the forwarding of all .consul resolve requests to consul-dns and apply
    kubectl get -n kube-system cm/coredns -o yaml | python3 update-configmap.py | kubectl apply -f -
    sleep 5 # sleep 5 # read -p "Press enter to continue"
fi

# Create service account
echo "--> Configure a Service Account in our new cluster..."
if [ "$(kubectl get serviceaccounts -A | grep 'eks-admin' | wc -l)" -eq "1" ]; then
    echo "ServiceAccount already exists, not creating..."
else
    kubectl apply -f k8s-service-account/service-account.yaml
fi

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Install dashboard and dashboard-admin
echo "--> Install dashboard and dashboard-admin..."
if [ "$(kubectl get pods -A | grep 'kubernetes-dashboard' | wc -l)" -eq "2" ]; then
    echo "Dashboard already deployed, not deploying..."
else
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
    kubectl apply -f dashboard/dashboard-admin.yaml
fi

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Just in case the svc is not yet deployed...
echo "--> Just in case the svc is not yet deployed, we'll query for it..."
until [ "$(kubectl get svc -n consul | grep 'consul-ui' | wc -l)" -eq "1" ]; do
    echo "Waiting for consul service to be up... (3 seconds)"
    sleep 3
done

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Wait for consul-server is running
echo "--> Wait for consul-server to be running..."
until [ "1" -eq "$(kubectl get pod -n consul consul-server-0 | grep Running | wc -l)" ]; do echo "Waiting for consul server to be running..." && sleep 30; done

sleep 5 # sleep 5 # read -p "Press enter to continue"

### Set all variables on consul
kubectl exec -t -n consul consul-server-0 -- /bin/consul kv put backend/db_address $DB_ADDRESS
kubectl exec -t -n consul consul-server-0 -- /bin/consul kv put backend/db_user $DB_USER
kubectl exec -t -n consul consul-server-0 -- /bin/consul kv put backend/db_pass $DB_PASSWD
kubectl exec -t -n consul consul-server-0 -- /bin/consul kv put voice/local_subscribers_regexp $LOCAL_SUBSCRIBERS_REGEXP

# Deploy sip-proxy
echo "--> Deploy sip-proxy..."
for yaml in $(find sip-proxy/*.yaml); do kubectl apply -f $yaml; done

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Deploy sip-b2bua
echo "--> Deploy sip-b2bua..."
for yaml in $(find sip-b2bua/*.yaml); do kubectl apply -f $yaml; done

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Deploy config-server
echo "--> Deploy config-server..."
for yaml in $(find config-server/*.yaml); do kubectl apply -f $yaml; done

export SIP_PUBLIC_IP=$(aws --region $AWS_REGION ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=*sip-proxy*" | jq '.Reservations[].Instances[].PublicIpAddress' | sed 's/"//g' | grep -v null | head -n 1)

# Push Database params to consul
echo "--> Push Database params to consul..."

# Now we should have the proxy's public ip, let's set it
kubectl exec -t -n consul consul-server-0 -- /bin/consul kv put voice/proxy-public-ip $SIP_PUBLIC_IP

#DOMAIN=$(kubectl exec -t -n consul consul-server-0 -- /bin/consul kv get voice/proxy-public-ip | sed "s/\"//g")

# Variables
DB_ADDRESS=$(kubectl exec -t -n consul consul-server-0 -- /bin/consul kv get backend/db_address)
DB_USER=$(kubectl exec -t -n consul consul-server-0 -- /bin/consul kv get backend/db_user)
DB_PASSWD=$(kubectl exec -t -n consul consul-server-0 -- /bin/consul kv get backend/db_pass)
# Create CDR table in viking's database via sip-proxy (which has a mysql client)
kubectl exec -t -n default $(kubectl get pods -o json | jq ".items[]|.metadata|select(.name|test(\"sip-proxy.\"))|.name" | sed "s/\"//g") -- /bin/bash -c "/usr/bin/mysql -h $DB_ADDRESS -u $DB_USER -p$DB_PASSWD viking < /etc/kamailio/viking_schema.sql"

# Lets create a couple subscriber (72110000)
POD=$(kubectl get pods -o json | jq ".items[]|.metadata|select(.name|test(\"sip-proxy.\"))|.name" | sed "s/\"//g")
DOMAIN=$(kubectl exec -t -n consul consul-server-0 -- /bin/consul kv get voice/proxy-public-ip | sed "s/\"//g")

USER=721110000
PASS=whatever
kubectl exec -ti $POD -- kamctl add $USER@$DOMAIN $PASS

USER=721110001
PASS=whatever
kubectl exec -ti $POD -- kamctl add $USER@$DOMAIN $PASS
#############

# Output the SIP-PROXY's Public IP Address
echo "--> Output the SIP-PROXY's Public IP Address and we're done."
echo "***************************************************************"
echo "***  Congratulations! Your service should now be running.   ***"
echo "***  Your public SIP IP Address is $SIP_PUBLIC_IP           ***"
echo "***************************************************************"
