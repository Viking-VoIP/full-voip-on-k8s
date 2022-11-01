SHELL := /usr/bin/env bash

NDEF = $(if $(value $(1)),,$(error $(1) not set))

.PHONY: init validate apply clean

all: init validate apply

init: 
	terraform init -reconfigure 

validate: 
	@terraform validate

apply: init
	@terraform apply -auto-approve
	@BUCKET=$$(terraform output -json | jq '.S3_Bucket.value'); \
     DYNAMODB=$$(terraform output -json | jq '.dynamo_db_lock.value'); \
     echo $${BUCKET} "/" $${DYNAMODB}; \
	 $$(sed "s/{{ BUCKET_NAME }}/$${BUCKET}/g; s/{{ DYNAMODB_LOCK }}/$${DYNAMODB}/g" ../main/main.tf.template > ../main/main.tf); \
	 terraform state pull | jq --raw-output '.outputs.ssh_keypair.value.private_key_pem' | sed 's/\\n/\n/g' > ../../../ssh_keypair.pem; \
	 echo "done."

destroy: init
	@terraform destroy -auto-approve

clean:
	@rm -rf .terraform* terraform.tfstate*
