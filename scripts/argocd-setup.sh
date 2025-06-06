#!/usr/local/bin/bash

echo "Setting up Argo CD..."

setup_argo() {

  RED="\e[31m"
  ENDCOLOR="\e[0m"

  set -e
  if ! kubectl get namespace argocd >/dev/null 2>&1; then
    kubectl create namespace argocd || { echo "Failed to create namespace"; exit 1; }
  else
    echo "Namespace 'argocd' already exists. Skipping creation."
  fi


  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || { echo "Failed to apply ArgoCD manifest"; exit 1; }


  # echo "Do you want to expose Argo via LoadBalancer Service Type? Enter Yes Or No"
  # read -r ANS 

  # case "$ANS" in
  #   Yes)
  #     echo "Setting up LoadBalancer..."
  #     kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' || { echo -e "${RED}Failed to add LoadBalancer; Run kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}' to add LB ${ENDCOLOR}"; exit 1; }
  #     ;;
  #   No)
  #     echo "Skipping LoadBalancer setup..."
  #     ;;
  #   *)
  #     echo "Usage: Please Enter Yes or No"
  #     exit 1
  #     ;;
  # esac

  kubectl apply -n argocd -f ./configs/argocd || { echo "Failed to apply Ingress"; exit 1; }
}
