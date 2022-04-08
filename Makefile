IMAGE_NAME?=eks-example
IMAGE_TAG?=1.0.0
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