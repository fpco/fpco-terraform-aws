.PHONY: init ssh-key plan-vpc plan-subnets plan-gateway plan apply destroy clean

.DEFAULT_GOAL = help

TERRAFORM = "aws-env terraform"

# Hardcoding value of 3 minutes when we check if the plan file is stale
STALE_PLAN_FILE := `find "tf.out" -mmin -3 | grep -q tf.out`

## Check if tf.out is stale (Older than 2 minutes)
check-plan-file:
	@if ! ${STALE_PLAN_FILE} ; then \
		echo "ERROR: Stale tf.out plan file (older than 3 minutes)!"; \
		exit 1; \
	fi

## Runs terraform get and terraform init for env
init:
	$terraform init

## Create ssh key
ssh-key:
	@ssh-keygen -q -N "" -b 4096 -C "SSH key for vpc-scenario-1 example" -f ./id_rsa

## use 'terraform plan' to 'target' the vpc in the vpc module
plan-vpc:
	@terraform plan \
		-target="module.vpc.module.vpc" \
		-out=tf.out

## use 'terraform plan' to 'target' the public subnets in the vpc module
plan-subnets:
	@terraform plan \
		-target="module.vpc.module.public-subnets" \
		-out=tf.out

## use 'terraform plan' to 'target' the public gateway in the vpc module
plan-gateway:
	@terraform plan \
		-target="module.vpc.module.public-gateway" \
		-out=tf.out

## use 'terraform plan' to map out updates to apply
plan:
	@terraform plan -out=tf.out

## use 'terraform apply' to apply updates in a 'tf.out' plan file
apply: check-plan-file
	@terraform apply tf.out

## use 'terraform destroy' to remove all resources from AWS
destroy:
	@terraform destroy

## rm -rf all files and state
clean:
	@rm -f tf.out
	@rm -f id_rsa
	@rm -f id_rsa.pub
	@rm -f terraform.tfvars
	@rm -f terraform.*.backup
	@rm -f terraform.tfstate

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
