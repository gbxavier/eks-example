pipeline {

  options {
    disableConcurrentBuilds()
  }

  agent any
  
  environment {
    AWS_ACCESS_KEY_ID = credentials("aws-access-key-id")
    AWS_SECRET_ACCESS_KEY = credentials("aws-secret-access-key")
    AWS_DEFAULT_REGION = "eu-west-1"
    TF_IN_AUTOMATION = "true"
    DOCKER_REGISTRY = "315380288412.dkr.ecr.eu-west-1.amazonaws.com"
    DOCKER_IMAGE_NAME = "${DOCKER_REGISTRY}/eks-example"
  }

  stages {

    stage('Build') {
      steps {
        sh "npm install"
      }
    }

    stage('Test') {
      steps {
        sh "npm test"
      }
    }

    stage('Packaging') {
      steps {
        sh "IMAGE_NAME=${DOCKER_IMAGE_NAME} IMAGE_TAG=${GIT_COMMIT} make docker-build"
      }
    }

    stage('Publish') {
      steps {
        sh "DOCKER_REGISTRY=${DOCKER_REGISTRY} IMAGE_NAME=${DOCKER_IMAGE_NAME} IMAGE_TAG=${GIT_COMMIT} make docker-publish"
      }
    }

    stage('Deploy') {
      environment {
        KUBE_NAMESPACE = "eks-example"
        HELM_CHART_PATH = "./deploy"
      }
      steps {

        sh """
          IMAGE_NAME=${DOCKER_IMAGE_NAME} \
          IMAGE_TAG=${GIT_COMMIT} \
          KUBE_NAMESPACE=${KUBE_NAMESPACE} \
          HELM_CHART_PATH=${HELM_CHART_PATH} \
          make helm-upgrade
        """

      }
    }

  }

}