#!/usr/local/bin/bash

setup_jenkins() {
  echo "Setting up Jenkins"

  CONFIG_DIR="./configs/jenkins/"

  if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Error: Configuration file $CONFIG_DIR dose not exist"
    exit 1
  fi

  set -e
  kubectl create namespace jenkins || { echo "Failed to create namespace"; exit 1; }
  kubectl apply -f $CONFIG_DIR || { echo "Error occured while tying to apply jenkins config"; exit 1; }

  echo "Run command to get all resources in namespace jenkins"
  echo "kubeclt get all -n jenkins"

}