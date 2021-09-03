#!/bin/bash

checkutil () {
    if [ -z "$(which $@)" ]; then
        echo "Could not find \"$@\" anywhere, please install it\!"
        exit 1
    fi
}

echo "--> Starting intialization script..."
AWS_REGION=$(jq '.region' ../terraform/project/main/dev.vars.json | sed 's/"//g')

echo "--> Resolving DB params..."
export CLUSTER_NAME=$(cat ../terraform/project/main/dev.vars.json | jq '.eks_cluster_name' | sed 's/"//g')
export DB_ID=$(cat ../terraform/project/main/dev.vars.json | jq '.db_instance_name' | sed 's/"//g')
export DB_USER=$(cat ../terraform/project/main/dev.vars.json | jq '.db_username' | sed 's/"//g')
export DB_ADDRESS=$(aws rds describe-db-instances --db-instance-identifier $DB_ID | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g')
export DB_PASSWD=$(cat ../terraform/project/main/dev.vars.json | jq '.db_password' | sed 's/"//g')
export LOCAL_SUBSCRIBERS_REGEXP=$(cat ../terraform/project/main/dev.vars.json | jq '.local_subscribers_regexp' | sed 's/"//g')

echo "--> Configuring access to EKS..."
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Check if aws command is available
checkutil "aws"

# Check if kubectl command is available
checkutil "kubectl"

# Check if heml command is available
checkutil "helm"

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
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
    kubectl apply -f dashboard/dashboard-admin.yaml
fi

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Install consul
echo "--> Install consul..."
if [ "$(helm list --all-namespaces | grep 'consul' | wc -l)" -eq "1" ]; then
    echo "Consul chart already installed, skipping."
else
    helm repo add hashicorp https://helm.releases.hashicorp.com
    #helm install -f consul/helm-consul-values.yaml hashicorp hashicorp/consul
    helm install consul hashicorp/consul -f consul/helm-consul-values.yaml
    sleep 5 # sleep 5 # read -p "Press enter to continue"
    # Get kubernetes' DNS IP, configure the configMap and apply it
    export CONSUL_DNS_IP=$(kubectl get svc consul-consul-dns -o jsonpath='{.spec.clusterIP}')
    # Replace and apply the confuigmap for consul-dns
    sed "s/{{ CONSUL_DNS_IP }}/$CONSUL_DNS_IP/g" consul/dns-configMap-template.yaml > consul/dns-configMap.yaml 
    kubectl apply -f consul/dns-configMap.yaml
    sleep 5 # sleep 5 # read -p "Press enter to continue"
    # Add the forwarding of all .consul resolve requests to consul-dns and apply
    kubectl get -n kube-system cm/coredns -o yaml | python update-configmap.py | kubectl apply -f -
    sleep 5 # sleep 5 # read -p "Press enter to continue"
fi

# Just in case the svc is not yet deployed...
echo "--> Just in case the svc is not yet deployed, we'll query for it..."
until [ "$(kubectl get svc | grep 'consul-consul-ui' | wc -l)" -eq "1" ]; do
    echo "Waiting for consul service to be up... (3 seconds)"
    sleep 3
done

sleep 5 # sleep 5 # read -p "Press enter to continue"

# Wait for consul-server is running
echo "--> Wait for consul-server is running..."
until [ "1" -eq "$(kubectl get pod consul-consul-server-0 | grep Running | wc -l)" ]; do echo "Waiting for consul server to be running..." && sleep 30; done

# Push Database params to consul
echo "--> Push Database params to consul..."

### Get a consul pod (we haven't yet deployed anything)
kubectl exec -t consul-consul-server-0 -- /bin/consul kv put backend/db_address $DB_ADDRESS
kubectl exec -t consul-consul-server-0 -- /bin/consul kv put backend/db_user $DB_USER
kubectl exec -t consul-consul-server-0 -- /bin/consul kv put backend/db_pass $DB_PASSWD
kubectl exec -t consul-consul-server-0 -- /bin/consul kv put voice/local_subscribers_regexp $LOCAL_SUBSCRIBERS_REGEXP

sleep 5 # sleep 5 # read -p "Press enter to continue"

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

# Output the SIP-PROXY's Public IP Address
echo "--> Output the SIP-PROXY's Public IP Address and we're done."
SIP_PUBLIC_IP=$(aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=*sip-proxy*" | jq '.Reservations[].Instances[].PublicIpAddress')
echo "***************************************************************"
echo "***  Congratulations! Your service should now be running.   ***"
echo "***  Your public SIP IP Address is $SIP_PUBLIC_IP           ***"
echo "***************************************************************"

