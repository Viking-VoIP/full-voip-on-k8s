SHELL := /usr/bin/env bash

#NDEF = $(if $(value $(1)),,$(error $(1) not set))

.PHONY: init validate apply clean

all: init validate apply

init: 
	@terraform init

validate: 
	@terraform validate

apply:
	@terraform apply -auto-approve
	$(shell sed "s/{{ BUCKET_NAME }}/$$(terraform output -json | jq '.S3_Bucket.value')/g; s/{{ DYNAMODB_LOCK }}/$$(terraform output -json | jq '.dynamo_db_lock.value')/g" ../s3_backend/variables.tf.template > ../s3_backend/variables.tf)

destroy:
	@terraform destroy -auto-approve

clean:
	@rm -rf .terraform/ terraform.tfstate*