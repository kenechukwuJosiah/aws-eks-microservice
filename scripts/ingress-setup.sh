#!/usr/bin/env bash

set -euo pipefail

setup_ingress_controller() {
  echo "Starting AWS ALB Ingress Controller Setup"

  CONFIG_PATH="./configs/ingress"
  REGION="eu-west-1"
  POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
  SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
  NAMESPACE="kube-system"
  POLICY_FILE="iam-policy.json"

  # Prompt for cluster name
  read -rp "Enter your EKS Cluster Name: " CLUSTER_NAME

  echo "Creating namespace if it doesn't exist..."
  kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

  echo "Associating IAM OIDC provider with cluster..."
  eksctl utils associate-iam-oidc-provider \
    --region "$REGION" \
    --cluster "$CLUSTER_NAME" \
    --approve

  # Download IAM policy JSON if missing
  if [[ ! -f $POLICY_FILE ]]; then
    echo "⬇ Downloading IAM policy..."
    curl -o "$POLICY_FILE" https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.0/docs/install/iam_policy.json
  fi

  # Check if policy exists
  echo "Checking if IAM policy '$POLICY_NAME' exists..."
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME"

  if ! aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1; then
    echo "Creating IAM policy..."
    aws iam create-policy \
      --policy-name "$POLICY_NAME" \
      --policy-document "file://$POLICY_FILE"
  else
    echo "✔️ IAM policy already exists. Skipping creation."
  fi

  echo "Creating IAM Service Account..."
  eksctl create iamserviceaccount \
    --cluster "$CLUSTER_NAME" \
    --namespace "$NAMESPACE" \
    --name "$SERVICE_ACCOUNT_NAME" \
    --attach-policy-arn "$POLICY_ARN" \
    --region "$REGION" \
    --override-existing-serviceaccounts \
    --approve

  echo "Adding Helm repo and updating..."
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update

  echo "Retrieving VPC ID for cluster..."
  VPC_ID=$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)

  echo "Installing AWS Load Balancer Controller via Helm..."
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n "$NAMESPACE" \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set region="$REGION" \
    --set vpcId="$VPC_ID" \
    --set enableShield=false \
    --set serviceAccount.name="$SERVICE_ACCOUNT_NAME"

  if [[ -d "$CONFIG_PATH" ]]; then
    echo "Applying ingress configuration files from $CONFIG_PATH..."
    kubectl apply -f "$CONFIG_PATH"
  else
    echo "Warning: Config path '$CONFIG_PATH' does not exist or is not a directory. Skipping apply."
  fi

  echo "AWS ALB Ingress Controller Setup Complete"
  echo "You can now create Ingress resources using the 'alb' IngressClass."
}
