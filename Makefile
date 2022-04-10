IMAGE_NAME?=eks-example
IMAGE_TAG?=1.0.0
AWS_DEFAULT_REGION?=eu-west-1
TF_BACKEND_STACK_NAME?=tf-backend
TF_BACKEND_TEMPLATE_FILE?=infrastructure/tf-backend/tf-backend.cfn.yaml
TF_BACKEND_BUCKET_STATE_NAME?=eks-example-tf-backend-001
TF_BACKEND_BUCKET_STATE_LOG_NAME?=eks-example-tf-backend-logs-001
TF_BACKEND_LOCK_TABLE_NAME?=eks-example-tf-backend-lock
TF_BACKENV_CONFIG_FILE?=backend-config/eu-west-1-production.tfvars
TF_ENV_FILE?=env/eu-west-1-production.tfvars
TF_ROOT_DIR?=infrastructure/cluster
DOCKER_REGISTRY?=315380288412.dkr.ecr.eu-west-1.amazonaws.com
KUBE_NAMESPACE?=eks-example
HELM_CHART_PATH?=./deploy

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
		--platform linux/amd64 \
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

docker-publish: ecr-get-login-password ## Publishes the newly built image to the registry
	@docker push \
		${LOCAL_IMAGE_NAME}

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

tf-init: ## Initialize terraform with S3 backend
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	terraform \
		init \
		-backend-config=${TF_BACKENV_CONFIG_FILE} && \
	cd - > /dev/null
tf-plan: ## Plan changes on the infrastructure
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	terraform \
		plan \
		-var-file=${TF_ENV_FILE} && \
	cd - > /dev/null

tf-apply: ## Apply changes on the infrastructure
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	terraform \
		apply \
		-auto-approve \
		-var-file=${TF_ENV_FILE} && \
	cd - > /dev/null

tf-destroy: ## Nuke the infrastructure
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	terraform \
		destroy \
		-auto-approve \
		-var-file=${TF_ENV_FILE} && \
	cd - > /dev/null

tf-console: ## Open TF Console
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	terraform \
		console \
		-var-file=${TF_ENV_FILE} && \
	cd - > /dev/null

eks-get-credentials: ## Get eks credentials
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	aws \
		eks \
		--region $$(terraform output -raw region) \
		update-kubeconfig \
		--name $$(terraform output -raw cluster_name)  && \
	cd - > /dev/null

ecr-get-login-password: ## Get ECR credentials
	@cd ${TF_ROOT_DIR} && echo "Temporarily changed to directory '${TF_ROOT_DIR}'" && \
	aws \
		ecr \
		get-login-password \
		--region eu-west-1 \
		| docker \
			login \
			--username AWS \
			--password-stdin ${DOCKER_REGISTRY} && \
	cd - > /dev/null

helm-template: ## Runs Helm's template engine (Development Only)
	@helm -n ${KUBE_NAMESPACE} \
		template \
		eks-example \
		${HELM_CHART_PATH} \
		--set image.name=${IMAGE_NAME} \
		--set image.tag=${IMAGE_TAG}

helm-upgrade: ## Deploys the application
	helm -n ${KUBE_NAMESPACE} \
		upgrade \
		eks-example \
		${HELM_CHART_PATH} \
		--install \
		--set image.name=${IMAGE_NAME} \
		--set image.tag=${IMAGE_TAG}