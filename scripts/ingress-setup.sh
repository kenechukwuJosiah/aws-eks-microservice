#!/usr/local/bin/bash

setup_ingress_controller() {
  # Setup IAM OIDC provider and associate it with your cluster
  echo "Please Enter Cluster Name"
  read -r CLUSTER_NAME

  eksctl utils associate-iam-oidc-provider --region=eu-west-1 --cluster=$CLUSTER_NAME --approve

  # Setup IAM Role
  echo "Fetching iam policy..."
  curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

  aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam-policy.json


  # Get Policy ARN
  echo "Setting up iam service account..."
  echo "Please Enter Policy ARN"
  read -r PolicyARN
  eksctl create iamserviceaccount \
    --cluster=attractive-gopher \
    --namespace=kube-system \
    --name=alb-ingress-controller \
    --attach-policy-arn=$PolicyARN \
    --override-existing-serviceaccounts \
    --approve

    # Setup Helm
    echo "Setting up helm..."
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update

    # Get VPC ID and store in a variable
    echo "Retrieving VPC ID..."
    VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region eu-west-1 \
      --query "cluster.resourcesVpcConfig.vpcId" --output text)

    # Install/upgrade AWS Load Balancer Controller using Helm
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName=$CLUSTER_NAME \
      --set serviceAccount.create=false \
      --set region=eu-west-1 \
      --set vpcId=$VPC_ID \
      --set serviceAccount.name=aws-load-balancer-controller

  kubectl get deployment -n kube-system aws-load-balancer-controller

}
