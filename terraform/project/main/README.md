# Terraform deployment

### Cluster configuration
- Edit `dev.vars.json` and set the params as you want it.
- To bring up the complete cluster, just launch it like:
```
$ terraform init
$ terraform apply -var-file dev.vars.json
```

This terraform will:
- Create a completely new VPC
- Create a MySQL RDS
- Create an EKS with:
  - 3 worker node groups:
    - 1 for the Backend and Consul - 1 node (http/nginx for xml_curl)
    - 1 for Kamailio - 1 node
    - 1 for freeSWITCH
