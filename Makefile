.DEFAULT_GOAL := help
.PHONY: help
TEST_TARGET := something
TARGET_TENANT := capthree
LOG_LEVEL := INFO

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

clean: ## Remove terraform/terragrunt cache
	@find . -name .terragrunt-cache -type d -exec rm -rf {} +
	@find . -name .terraform -type d -exec rm -rf {} +

# Bootstrap
plan-platform: ## plan bootstrap targets
	terragrunt run-all plan  --terragrunt-working-dir "resources/platform" --terragrunt-log-level ${LOG_LEVEL}

apply-platform: ## apply bootstrap targets
	terragrunt run-all apply  --terragrunt-working-dir "resources/platform" --terragrunt-log-level ${LOG_LEVEL}

destroy-platform: ## destroy bootstrap targets
	terragrunt run-all destroy --terragrunt-working-dir "resources/platform" --terragrunt-log-level ${LOG_LEVEL} 

output-all:
	terragrunt output-all -json > plan-all.json

plan-test: ## plan target under test
	@echo terragrunt run-all plan --terragrunt-non-interactive --terragrunt-working-dir "${TEST_TARGET}"
	terragrunt run-all plan --terragrunt-non-interactive --terragrunt-working-dir "${TEST_TARGET}"

apply-test: ## apply target under test
	@echo terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir "${TEST_TARGET}"
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir "${TEST_TARGET}"

validate-single-tenant: ## Execute inspec core_tenant suite on target tenant
	# TODO add a target for validating a tenant as an argument for automated validation
	@echo inspec exec test/integration/core_tenant/ -t gcp:// --input-file=test/integration/core_tenant/inputs/tenant_name.yml
	@read -p "Enter tenant name:" tenant; \
	inspec exec test/integration/core_tenant/ -t gcp:// --input-file=test/integration/core_tenant/inputs/$$tenant.yml

migrate-local-state: # Migrate local pipeline state to GCS
	scripts/migrate-local-state.sh

add-tenant: # add a tenant using templates
	@read -p "Enter tenant name:" tenant; \
	scripts/add-tenant.sh $$tenant

add-tenant-state: # Adds a pair of new GCS state buckets for a new tenant
	@read -p "Enter tenant name:" tenant; \
	scripts/add-tenant-state.sh $$tenant
	#plan-bootstrap

