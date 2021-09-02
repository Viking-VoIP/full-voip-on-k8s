SHELL := /usr/bin/env bash

#NDEF = $(if $(value $(1)),,$(error $(1) not set))

.PHONY: init validate apply clean

all: init validate apply

init: 
	@terraform show 2> /dev/null || terraform init

validate: 
	@terraform validate

apply:
	@terraform apply -var-file=dev.vars.json

destroy:
	@terraform destroy -auto-approve

clean:
	@rm -rf .terraform/ terraform.tfstate*