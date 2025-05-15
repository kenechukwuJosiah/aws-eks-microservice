#!/usr/local/bin/bash

setup_argo() {

  RED="\e[31m"
  ENDCOLOR="\e[0m"

  set -e
  kubectl create namespace argocd || { echo "Failed to create namespace"; exit 1; }
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || { echo "Failed to apply ArgoCD manifest"; exit 1; }


  echo "Do you want to expose Argo via LoadBalancer Service Type? Enter Yes Or No"
  read -r ANS 

  case "$ANS" in
    Yes)
      echo "Setting up LoadBalancer..."
      kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' || { echo -e "${RED}Failed to add LoadBalancer; Run kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}' to add LB ${ENDCOLOR}"; exit 1; }
      ;;
    No)
      echo "Skipping LoadBalancer setup..."
      ;;
    *)
      echo "Usage: Please Enter Yes or No"
      exit 1
      ;;
  esac
}
