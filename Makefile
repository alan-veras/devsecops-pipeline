APP_DIR  := app
IMAGE    := devsecops-pipeline:local
TF_DIR   := terraform/envs/dev

SEMGREP_IMG  := returntocorp/semgrep@sha256:f1f7b71861c7b28b6e0f661225a2c4f58a484f5d0f182465c6d6b3b22f972ade
HADOLINT_IMG := hadolint/hadolint@sha256:32dac94127fd60b7b7e3fbfc65e1383b9b5e25c9bfd7b8536de7a539fe68a12d
CHECKOV_IMG  := bridgecrew/checkov@sha256:c5fb7154bed784fc19a69779c308fddba564f19a37c25d306c0e9765c4f0aa1d

.PHONY: help build test scan up down bootstrap

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

build:
	docker build -t $(IMAGE) $(APP_DIR)

test:
	cd $(APP_DIR) && python -m pytest tests -q

scan:
	gitleaks detect --source .
	docker run --rm -v $$(pwd):/src $(SEMGREP_IMG) scan --config p/python --config p/sql-injection --config p/default --error /src/$(APP_DIR)
	docker run --rm -v $$(pwd)/app:/mnt hadolint/hadolint hadolint /mnt/Dockerfile
	docker run --rm -v $$(pwd):/tf $(CHECKOV_IMG) -d /tf/terraform --compact

up:
	cd $(TF_DIR) && terraform init && terraform apply -var-file=dev.tfvars

down:
	cd $(TF_DIR) && terraform destroy -var-file=dev.tfvars

bootstrap:
	bash scripts/bootstrap-state.sh
