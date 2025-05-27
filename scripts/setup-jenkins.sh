#!/usr/local/bin/bash

setup_jenkins() {
  echo "Setting up Jenkins"

  CONFIG_DIR="./configs/jenkins/"

  if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Error: Configuration file $CONFIG_DIR dose not exist"
    exit 1
  fi

  set -e
  if ! kubectl get namespace jenkins >/dev/null 2>&1; then
    kubectl create namespace jenkins || { echo "Failed to create namespace"; exit 1; }
  else
    echo "Namespace 'jenkins' already exists. Skipping creation."
  fi
  kubectl apply -f $CONFIG_DIR || { echo "Error occured while tying to apply jenkins config"; exit 1; }

  echo "Run command to get all resources in namespace jenkins"
  echo "kubectl get all -n jenkins"

}