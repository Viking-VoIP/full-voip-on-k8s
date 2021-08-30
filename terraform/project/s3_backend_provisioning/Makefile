SHELL := /usr/bin/env bash -e

#NDEF = $(if $(value $(1)),,$(error $(1) not set))

.PHONY: init validate apply clean

all: init validate apply

init: 
	@terraform init

validate: 
	@terraform validate

apply:
	echo @terraform apply -auto-approve
	echo "davd"
	S3_BUCKET_NAME_STATE=$(shell terraform output -json | jq '.S3_Bucket.value')
	DYNAMODB_LOCK=$(shell terraform output -json | jq '.dynamo_db_lock.value')
	RET=$(shell sed "s/{{ BUCKET_NAME }}/$$S3_BUCKET_NAME_STATE/g;" ../s3_backend/variables.tf.template > ../s3_backend/variables.tf)
	echo "RET=$${RET}"
	## s|{{ DYNAMODB_LOCK }}|$$(DYNAMODB_LOCK)|g' 

destroy:
	@terraform destroy -auto-approve

clean:
	@rm -rf .terraform/ terraform.tfstate*