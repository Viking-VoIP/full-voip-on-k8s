provider "aws" {
  region = var.region
}

resource "random_integer" "priority" {
  min = 0
  max = 2
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.17"
  subnets         = var.private_subnets_ids

  tags = {
    Environment = var.environment
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "support"
      instance_type                 = var.eks_workers.support.instance_type
      asg_desired_capacity          = var.eks_workers.support.desired_capacity
      key_name                      = var.eks_workers.support.ssh_key_name
      subnets                       = var.private_subnets_ids
      # I could not find a way of labeling the nodes in the groups, for later use with "nodeSelector",
      #    so I'm doing it via additional_userdata. We need to wait until the node has attached to the cluster
      #    before labeling.
      additional_userdata           = <<EOT
curl -o /root/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/linux/amd64/kubectl
chmod +x /root/kubectl
aws eks --region us-east-1 update-kubeconfig --name dev-cluster
until [ -f "/root/.kube/config" ]; do sleep 1; done
until [ "$(/root/kubectl --kubeconfig=/root/.kube/config get nodes | grep $(hostname) | wc -l)" == "1" ]; do sleep 1; done
/root/kubectl --kubeconfig=/root/.kube/config label nodes $(hostname) application=support
EOT
      associate_public_ip_address   = false
      additional_security_group_ids = [
        aws_security_group.sg_ssh_mgmt.id,
        aws_security_group.sg_support_sg.id,
        var.vpc_default_sg_id
      ]
      labels = {
        application = "support"
      }
      root_block_device = {
        delete_on_termination = true
      }
    },
    {
      name                          = "backend"
      instance_type                 = var.eks_workers.backend.instance_type
      asg_desired_capacity          = var.eks_workers.backend.desired_capacity
      key_name                      = var.eks_workers.backend.ssh_key_name
      subnets                       = var.private_subnets_ids
      # I could not find a way of labeling the nodes in the groups, for later use with "nodeSelector",
      #    so I'm doing it via additional_userdata. We need to wait until the node has attached to the cluster
      #    before labeling.
      additional_userdata           = <<EOT
curl -o /root/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/linux/amd64/kubectl
chmod +x /root/kubectl
aws eks --region us-east-1 update-kubeconfig --name dev-cluster
until [ -f "/root/.kube/config" ]; do sleep 1; done
until [ "$(/root/kubectl --kubeconfig=/root/.kube/config get nodes | grep $(hostname) | wc -l)" == "1" ]; do sleep 1; done
/root/kubectl --kubeconfig=/root/.kube/config label nodes $(hostname) application=backend
EOT
      associate_public_ip_address   = false
      additional_security_group_ids = [
        aws_security_group.sg_ssh_mgmt.id,
        aws_security_group.sg_backend_sg.id,
        var.vpc_default_sg_id
      ]
      labels = {
        application = "backend"
      }
      root_block_device = {
        delete_on_termination = true
      }
    },
    {
      name                          = "sip-proxy"
      instance_type                 = var.eks_workers.sip-proxy.instance_type
      asg_desired_capacity          = var.eks_workers.sip-proxy.desired_capacity
      key_name                      = var.eks_workers.sip-proxy.ssh_key_name
      subnets                       = var.public_subnets_ids
      # I could not find a way of labeling the nodes in the groups, for later use with "nodeSelector",
      #    so I'm doing it via additional_userdata. We need to wait until the node has attached to the cluster
      #    before labeling.
      additional_userdata           = <<EOT
curl -o /root/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/linux/amd64/kubectl
chmod +x /root/kubectl
aws eks --region us-east-1 update-kubeconfig --name dev-cluster
until [ -f "/root/.kube/config" ]; do sleep 1; done
until [ "$(/root/kubectl --kubeconfig=/root/.kube/config get nodes | grep $(hostname) | wc -l)" == "1" ]; do sleep 1; done
/root/kubectl --kubeconfig=/root/.kube/config label nodes $(hostname) application=proxy
EOT
      associate_public_ip_address   = true
      additional_security_group_ids = [
        aws_security_group.sg_ssh_mgmt.id,
        aws_security_group.sg_sip_proxy.id,
        var.vpc_default_sg_id
      ]
      labels = {
        application = "proxy"
      }
      root_block_device = {
        delete_on_termination = true
      }
    },
    {
      name                          = "sip-b2bua"
      instance_type                 = var.eks_workers.sip-b2bua.instance_type
      asg_desired_capacity          = var.eks_workers.sip-b2bua.desired_capacity
      key_name                      = var.eks_workers.sip-b2bua.ssh_key_name
      subnets                       = var.public_subnets_ids
      # I could not find a way of labeling the nodes in the groups, for later use with "nodeSelector",
      #    so I'm doing it via additional_userdata. We need to wait until the node has attached to the cluster
      #    before labeling.
      additional_userdata           = <<EOT
curl -o /root/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/linux/amd64/kubectl
chmod +x /root/kubectl
aws eks --region us-east-1 update-kubeconfig --name dev-cluster
until [ -f "/root/.kube/config" ]; do sleep 1; done
until [ "$(/root/kubectl --kubeconfig=/root/.kube/config get nodes | grep $(hostname) | wc -l)" == "1" ]; do sleep 1; done
/root/kubectl --kubeconfig=/root/.kube/config label nodes $(hostname) application=b2bua
EOT
      associate_public_ip_address   = true
      additional_security_group_ids = [
        aws_security_group.sg_ssh_mgmt.id,
        aws_security_group.sg_sip_b2bua.id,
        var.vpc_default_sg_id
      ]
      labels = {
        application = "b2bua"
      }
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}