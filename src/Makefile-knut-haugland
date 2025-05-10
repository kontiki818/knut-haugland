# GITHUB_TOKEN is used for git clone https and github_actions_secret authentication
ifndef GITHUB_TOKEN
    $(error Please specify GITHUB_TOKEN)
endif
# GH_TOKEN is used for gh within GitHub Actions https://cli.github.com/manual/gh_auth_login
GH_TOKEN=${GITHUB_TOKEN}

################################################################
# KnutHaugland: Makefile for building Kon-Tiki sites
# https://github.com/cliffano/knut-haugland
################################################################

# KnutHaugland's version number
KNUT_HAUGLAND_VERSION = 1.2.0

################################################################
# User configuration variables
# These variables should be stored in knut-haugland.yml config file,
# and they will be parsed using yq https://github.com/mikefarah/yq
# Example:
# ---
# aws_region: ap-southeast-2
# bucket_name: www.knuthaugland.com

# AWS_REGION is the name of the AWS region where the S3 bucket is located
AWS_REGION=$(shell yq .aws_region knut-haugland.yml)

# BUCKET_NAME is the name of the AWS S3 bucket where the site is deployed
BUCKET_NAME ?= $(shell yq .bucket_name knut-haugland.yml)

$(info ################################################################)
$(info Building Kon-Tiki site using Knut Haugland with user configurations:)
$(info - AWS region: ${AWS_REGION})
$(info - Bucket name: ${BUCKET_NAME})

TF_VARS=config/terraform.tfvars
TF_BACKEND=config/backend.tf
export TF_VAR_github_token=${GITHUB_TOKEN}
export AWS_DEFAULT_REGION=${AWS_REGION}

################################################################
# Base targets

# CI target to be executed by CI/CD tool
ci: clean deps lint build infra-init

# All target involves creating infra from scratch and then deploy the site
all: clean deps infra-init infra-destroy infra-apply build deploy

# Ensure stage directory exists
stage:
	mkdir -p stage

# Remove all temporary (staged, generated, cached) files
clean:
	bob clean
	rm -rf .terraform/ .terraform.lock.hcl stage/

# Retrieve Studio customisation of Terraform Kon-Tiki
# and node package dependencies
deps: stage
	cd stage && rm -rf terraform-kon-tiki-studio && gh repo clone cliffano/terraform-kon-tiki-studio
	bob dep

lint:
	find data/ -type f -name "*.json" | while IFS= read -r file; do echo "> $$file"; python3 -m json.tool "$$file"; done

# Placeholder for now - needed by checkmake
test:
	echo "PLACEHOLDER test target"

# Update Makefile to the latest version tag
update-to-latest: TARGET_KNUT_HAUGLAND_VERSION = $(shell curl -s https://api.github.com/repos/cliffano/knut-haugland/tags | jq -r '.[0].name')
update-to-latest: update-to-version

# Update Makefile to the main branch
update-to-main:
	curl https://raw.githubusercontent.com/cliffano/knut-haugland/main/src/Makefile-knut-haugland -o Makefile

# Update Makefile to the version defined in TARGET_KNUT_HAUGLAND_VERSION parameter
update-to-version:
	curl https://raw.githubusercontent.com/cliffano/knut-haugland/$(TARGET_KNUT_HAUGLAND_VERSION)/src/Makefile-knut-haugland -o Makefile

################################################################
# Build and deploy targets

build:
	bob site

deploy:
	aws s3 cp --recursive --region $(AWS_REGION) .bob/site/ae86/ s3://$(BUCKET_NAME)

x-build:
	make -f Makefile-extras x-build

x-deploy:
	make -f Makefile-extras x-deploy AWS_REGION=$(AWS_REGION) BUCKET_NAME=$(BUCKET_NAME)

################################################################
# Publishing targets

publish: clean deps init build deploy

################################################################
# Infrastructure targets

infra-init:
	terraform init -var-file="$(TF_VARS)" -backend-config="$(TF_BACKEND)" -backend=true -force-copy
	terraform graph

infra-destroy:
	terraform destroy -auto-approve -var-file $(TF_VARS)

infra-refresh:
	terraform refresh -var-file $(TF_VARS)

infra-plan:
	terraform plan -var-file $(TF_VARS)

infra-apply:
	terraform apply -auto-approve -var-file $(TF_VARS)

infra-import:
	terraform import -var-file $(TF_VARS) $(IMPORT_ARGS)

################################################################

.PHONY: ci all stage clean deps lint test update-to-latest update-to-main update-to-version build deploy x-build x-deploy publish infra-init infra-destroy infra-refresh infra-plan infra-apply infra-import
