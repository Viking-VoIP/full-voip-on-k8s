# Full VoIP service on kubernetes.

The goal of this project is to provide people with a complete, fully-fledge VoIP platform based on Kubernetes.

It is based on AWS EKS and consists of two parts:

The first is the Terraform project, which will create all resources needed to implement:
- 1 EKS cluster with the following nodes:
  - 1 backend (1 node in a private subnet): this will run the Consul service and the Routing Service (based on FS XML_CURL) pods
  - 1 Proxy (1 node in a public subnet): this will run Kamailio in a pod.
  - 2 B2BUA (2 nodes in a public subnet): These will run freeSWITCH. Signaling will run on the private IPs while RTP will use a public IP.

The clients will register (if configured) on the Proxy's public IP address. When they make/receive calls via this address. The Proxy will forward all calls to the FS's on the private IPs, then negotiate with the clien an RTP connection via FS's public IPs.

# Architecture:
![Deployment Architecture](voip-full-k8s-network-diagram.jpg)

---
# Requirements
## 

- You need to have an AWS account properly configured in your CLI.
- The AWS account secret_access_key and accrss_key_id should already be properly configured in your ~/.aws/credential file.
- Said account must have all permissions to create a VPC, routing tables, EKS cluster, ASGs, etc.
- You must have installed and properly configured the following:
  - helm (https://helm.sh/docs/intro/install/)
  - kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
  - AWS cli utility (https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

# Prepare your deployment
##

Clone the repo

```git clone git@github.com:Viking-VoIP/full-voip-on-k8s.git viking-voip```

cd into the project folder:

```cd viking-voip```

*IMPORTANT*: The variable file contains all the information needed to deploy the complete solution. There are parameters you will probably want to change.

Use your favorite edit to edit the variables file:

`terraform/project/main/dev.vars.json`

---
# Deploy
## Makefile

- ```make help```: Will give you all possible directives, i.e.:
- ```make init-backend```: Will initialize the s3_backend, meaning preparing all plugins needed by terraform.
- ```make apply-backend```: Will apply the s3_backend terraform. This will create an S3 bucket and a DynamoDB table which are used to keep track of the state of terraform deployments in relation to resrouces in AWS. (Includes all previous directives)
- ```make init-main```: Will initialize the main projecyt, meaning preparing all plugins needed by that terraform project.
- ```make apply-backend```: Will apply the main terraform project. This will create all needed resources to deploy the whole eks platform.
- ```make destroy-main```: Will delete all resources previously created by the main project. (it is possible the destroy doesn't work because sometimes a previsouly created ELB is not destroyed. If this happens, you will need to manually delete the ELB and execute the destroy agaon. We're investigating into that.)
- ```make destroy-backend```: Will delete the backend resources created for state management.


To build the whole project simply execute:

```make apply-main``` 

This will launch the deployment process.

If everything goes OK, you will get an output of your setup, you should save this somewhere safe.

*NOTE*: If you don't change dev.vars.json, but I'd recommend at least chnaging the admin db password.
