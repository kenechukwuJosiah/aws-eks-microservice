#!/usr/bin/env bash

set -euo pipefail

setup_ingress_controller() {
  echo "🔧 Starting AWS ALB Ingress Controller Setup"

  # Prompt for cluster name
  read -rp "👉 Enter your EKS Cluster Name: " CLUSTER_NAME
  REGION="eu-west-1"
  POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
  SERVICE_ACCOUNT_NAME="alb-ingress-controller"
  NAMESPACE="kube-system"
  POLICY_FILE="iam-policy.json"

  echo "Associating IAM OIDC provider with cluster..."
  eksctl utils associate-iam-oidc-provider \
    --region "$REGION" \
    --cluster "$CLUSTER_NAME" \
    --approve

  # Fetch IAM policy JSON
  if [[ ! -f $POLICY_FILE ]]; then
    echo "⬇Downloading IAM policy..."
    curl -s -o "$POLICY_FILE" https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
  fi

  # Check if policy exists
  echo "Checking if IAM policy '$POLICY_NAME' exists..."
  if ! aws iam get-policy --policy-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME" >/dev/null 2>&1; then
    echo "Creating IAM policy..."
    aws iam create-policy \
      --policy-name "$POLICY_NAME" \
      --policy-document "file://$POLICY_FILE"
  else
    echo "IAM policy already exists. Skipping creation."
  fi

  # Create IAM Service Account
  echo "Creating IAM Service Account..."
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  eksctl create iamserviceaccount \
    --cluster "$CLUSTER_NAME" \
    --namespace "$NAMESPACE" \
    --name "$SERVICE_ACCOUNT_NAME" \
    --attach-policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME" \
    --region "$REGION" \
    --override-existing-serviceaccounts \
    --approve

  # Set up Helm and repo
  echo "Adding EKS Helm repo..."
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update

  # Get VPC ID
  echo "Retrieving VPC ID for cluster..."
  VPC_ID=$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)

  # Install the AWS Load Balancer Controller via Helm
  echo "Installing AWS Load Balancer Controller with Helm..."
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n "$NAMESPACE" \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set region="$REGION" \
    --set vpcId="$VPC_ID" \
    --set serviceAccount.name="$SERVICE_ACCOUNT_NAME"

  echo "Load Balancer Controller deployment status:"
  kubectl get deployment -n "$NAMESPACE" aws-load-balancer-controller
}
