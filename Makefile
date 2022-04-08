IMAGE_NAME?=eks-example
IMAGE_TAG?=1.0.0
AWS_DEFAULT_REGION?=eu-west-1
TF_BACKEND_STACK_NAME?=tf-backend
TF_BACKEND_TEMPLATE_FILE?=infrastructure/tf-backend/tf-backend.cfn.yaml
TF_BACKEND_BUCKET_STATE_NAME?=eks-example-tf-backend-001
TF_BACKEND_BUCKET_STATE_LOG_NAME?=eks-example-tf-backend-logs-001
TF_BACKEND_LOCK_TABLE_NAME?=eks-example-tf-backend-lock

LOCAL_IMAGE_NAME=${IMAGE_NAME}:${IMAGE_TAG}
LOCAL_DOCKER_CONTAINER_NAME=eks-example

default: help

help:
	@echo 'Usage: make [target] ...'
	@echo
	@echo 'Targets:'
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep  \
	| sed -e 's/^\(.*\):[^#]*#\(.*\)/\1 \2/' | tr '#' "\t"

docker-build: ## Build the service's docker image
	docker build \
	    -t ${LOCAL_IMAGE_NAME} \
	    .

docker-run: ## Runs the image locally
	docker run \
	    -p  8080:8080 \
		-d \
		--name ${LOCAL_DOCKER_CONTAINER_NAME} \
		${LOCAL_IMAGE_NAME}

docker-stop: ## Stops the running container
	docker stop \
		${LOCAL_DOCKER_CONTAINER_NAME}

aws-cfn-tf-backend-provision: ## Deploy TF's backend infrastructure
	aws \
		--region ${AWS_DEFAULT_REGION} \
		cloudformation \
		deploy \
		--template-file ${TF_BACKEND_TEMPLATE_FILE} \
		--stack-name ${TF_BACKEND_STACK_NAME} \
		--parameter-overrides StateBucketName=${TF_BACKEND_BUCKET_STATE_NAME} \
			StateLogBucketName=${TF_BACKEND_BUCKET_STATE_LOG_NAME} \
			LockTableName=${TF_BACKEND_LOCK_TABLE_NAME}

aws-cfn-tf-backend-delete: ## Delete TF's backend infrastructure
	aws \
		--region ${AWS_DEFAULT_REGION} \
		cloudformation \
		delete-stack \
		--stack-name ${TF_BACKEND_STACK_NAME} \
