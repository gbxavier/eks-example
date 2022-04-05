IMAGE_NAME?=eks-example
IMAGE_TAG?=1.0.0
LOCAL_IMAGE_NAME=${IMAGE_NAME}:${IMAGE_TAG}
LOCAL_DOCKER_CONTAINER_NAME=eks-example

docker-build:
	docker build \
	    -t ${LOCAL_IMAGE_NAME} \
	    .

docker-run:
	docker run \
	    -p  8080:8080 \
		-d \
		--name ${LOCAL_DOCKER_CONTAINER_NAME} \
		${LOCAL_IMAGE_NAME}

docker-stop:
	docker stop \
		${LOCAL_DOCKER_CONTAINER_NAME}