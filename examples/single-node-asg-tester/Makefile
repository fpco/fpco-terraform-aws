.PHONY: init ssh-key apply destroy clean

.DEFAULT_GOAL = help

## Runs terraform get and terraform init for env
init:
	@terraform get
	@terraform init

## Create ssh key
ssh-key:
	@ssh-keygen -q -N "" -C "SSH key for vpc-scenario-1 example" -f ./id_rsa

## use 'terraform apply' to apply the setup.
apply:
	@terraform apply

## use 'terraform destroy' to remove all resources from AWS
destroy:
	@terraform destroy

## rm -rf all files and state
clean:
	@rm -f id_rsa
	@rm -f id_rsa.pub
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
