SHELL := /usr/bin/env bash

#NDEF = $(if $(value $(1)),,$(error $(1) not set))

NO_COLOR=$(shell echo -e "\e[m")
WARN_COLOR=$(shell echo -e "\e[1;7m")
ERROR_COLOR=$(shell echo -e "\e[1;31m")
OK_COLOR=$(shell echo -e "\e[1;34m")
HIGHLIGHT_COLOR=$(shell echo -e "\e[93;1m")

report_success = "$(OK_COLOR)RESULT:$(NO_COLOR) $(HIGHLIGHT_COLOR)$1$(NO_COLOR) $2 Success"

report_failure = "$(ERROR_COLOR)RESULT: $(HIGHLIGHT_COLOR)$1$(NO_COLOR) $2 Failed, exiting...$(ERROR_COLOR)"

.PHONY: init validate apply clean

help:
	@echo ""
	@echo "This makefile:"
	@echo "    - "make init-backend": Will initialize the backend (S3 bucket and DynamoDB Table for terraform state)."
	@echo "    - "make apply-backend": Will initialize + build the backend (S3 bucket and DynamoDB Table for terraform state)."
	@echo "    - "make init-main": Will initialize the main project (This will prepare the project to build)."
	@echo "    - "make apply-main": Will initialize + build the whole voip platform (Will create all required resource on AWS)."
	@echo "    - "make destroy-backend": Will destroy all backend resources."
	@echo "    - "make destroy-main": Will destroy the whole voip platform resources."
	@echo "    - "make destroy-all": Will destroy all resources."
	@echo "    - "make clean": Will remove all terraform files (.terraform, etc)."
	@echo "    - "make init-script": deploy all images and services"
	@echo ""

all: apply-main

init-backend:
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Initializing terraform backend"
	@cd terraform/project/s3_backend && $(MAKE) init && echo $(call report_success,"Backend","Initialize") || (echo $(call report_failure,"Backend","Initialize") && exit -1)

apply-backend: #init-backend
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Applying Backend will create the S3 bucket and DynamoDB Table."
	@cd terraform/project/s3_backend && $(MAKE) apply && echo $(call report_success,"Backend","Apply") || (echo $(call report_failure,"Backend","Apply") && exit -1)

list-backend: #init-backend
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Showing Backend will create the S3 bucket and DynamoDB Table."
	@cd terraform/project/s3_backend && $(MAKE) list && echo $(call report_success,"Backend","Show") || (echo $(call report_failure,"Backend","Show") && exit -1)

init-main: #apply-backend
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Initializing $(OK_COLOR)Main$(NO_COLOR) project."
	@cd terraform/project/main && $(MAKE) init && echo $(call report_success,"Main","Initialize") || (echo $(call report_failure,"Main","Initialize") && exit -1)

apply-main: #init-main
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Applying $(OK_COLOR)main$(NO_COLOR) project -- Tnis will create all required resources on AWS."
	@cd terraform/project/main && $(MAKE) apply && echo $(call report_success,"Main","Apply") || (echo $(call report_failure,"Main","Apply") && exit -1)
	#cd scripts; bash ./init.sh && echo $(call report_success,"Scripts","Execute") || (echo $(call report_failure,"Scripts","Execute") && exit -1)

list-main: #init-backend
	@echo "$(WARN_COLOR)WARNING:$(NO_COLOR) Showing Backend will create the S3 bucket and DynamoDB Table."
	@cd terraform/project/main && $(MAKE) list && echo $(call report_success,"Main","Show") || (echo $(call report_failure,"Main","Show") && exit -1)

init-script:
	cd scripts; bash ./init.sh && echo $(call report_success,"Scripts","Execute") || (echo $(call report_failure,"Scripts","Execute") && exit -1)

destroy-backend:
	@echo '$(ERROR_COLOR)***** WARNING: This will DESTROY all resources!$(ERROR_COLOR) *****'

	@# Let' ask the user if we should continue, since this is going to destroy everything

	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "Type anything but Y or y to exit. [y/N] " CONTINUE; \
	done ; \
	if [ ! $$CONTINUE == "y" ]; then \
	if [ ! $$CONTINUE == "Y" ]; then \
		echo "Exiting." ; exit 1 ; \
	fi \
	fi
	@cd terraform/project/s3_backend && $(MAKE) destroy && echo "$(OK_COLOR)RESULT:$(NO_COLOR) $(HIGHLIGHT_COLOR)Backend$(NO_COLOR) Destroy Success" || echo "$(ERROR_COLOR)RESULT:$(ERROR_COLOR) $(HIGHLIGHT_COLOR)Backend$(NO_COLOR) Destroy Failed, exiting..."
	
destroy-main:
	@echo '$(ERROR_COLOR)***** WARNING: This will DESTROY all resources!$(ERROR_COLOR) *****'

	@# Let' ask the user if we should continue, since this is going to destroy everything

	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "Type anything but Y or y to exit. [y/N] " CONTINUE; \
	done ; \
	if [ ! $$CONTINUE == "y" ]; then \
	if [ ! $$CONTINUE == "Y" ]; then \
		echo "Exiting." ; exit 1 ; \
	fi \
	fi
	#@kubectl delete -f scripts/config-server/config-server-deployment.yaml
	@cd terraform/project/main && $(MAKE) destroy && echo "$(OK_COLOR)RESULT:$(NO_COLOR) $(HIGHLIGHT_COLOR)Main$(NO_COLOR) Destroy Success" || echo "$(ERROR_COLOR)RESULT:$(ERROR_COLOR) $(HIGHLIGHT_COLOR)Main$(NO_COLOR) Destroy Failed, exiting..."

destroy-all: destroy-main destroy-backend
	

clean:
	@cd terraform/project/main && rm -rf .terraform/ terraform.tfstate* .terraform*
	@cd terraform/project/s3_backend && rm -rf .terraform/ terraform.tfstate* .terraform*
