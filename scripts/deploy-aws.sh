#!/bin/sh
set -eu

ENVIRONMENT=${1:?Usage: deploy-aws.sh <environment> <image-tag>}
IMAGE_TAG=${2:?Usage: deploy-aws.sh <environment> <image-tag>}

: "${AWS_REGION:?Set AWS_REGION}"
: "${EKS_CLUSTER_NAME:?Set EKS_CLUSTER_NAME}"
: "${ECR_REGISTRY:?Set ECR_REGISTRY, for example 123456789012.dkr.ecr.us-east-1.amazonaws.com}"
: "${ECR_REPOSITORY:?Set ECR_REPOSITORY}"

NAMESPACE=${K8S_NAMESPACE:-ecommerce}
REGISTRY_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}"

echo "Deploying ${ENVIRONMENT} image ${IMAGE_TAG} to EKS cluster ${EKS_CLUSTER_NAME}"
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER_NAME}"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/config/configmap.yaml
kubectl apply -f kubernetes/backend
kubectl apply -f kubernetes/frontend
kubectl apply -f kubernetes/autoscaling
kubectl apply -f kubernetes/ingress

kubectl -n "${NAMESPACE}" set image deployment/backend backend="${REGISTRY_IMAGE}/backend:${IMAGE_TAG}"
kubectl -n "${NAMESPACE}" set image deployment/frontend frontend="${REGISTRY_IMAGE}/frontend:${IMAGE_TAG}"
kubectl -n "${NAMESPACE}" rollout status deployment/backend --timeout=5m
kubectl -n "${NAMESPACE}" rollout status deployment/frontend --timeout=5m
