#!/bin/bash

create_or_update_cluster() {
  CONFIG_FILE="./configs/aws/eks-cluster.yml"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file $CONFIG_FILE does not exist."
    exit 1
  fi

  echo "Do you want to create or update the EKS cluster? (create/update/delete)"

  read -r ACTION

  if [[ "$ACTION" == "create" ]]; then
    echo "Creating EKS cluster..."
    eksctl create cluster -f "$CONFIG_FILE"
  elif [[ "$ACTION" == "update" ]]; then
    echo "Updating EKS cluster..."
    eksctl upgrade cluster -f "$CONFIG_FILE"
  elif [[ "$ACTION" == "delete" ]]; then
    echo "Deleting EKS cluster..."
    eksctl delete cluster -f "$CONFIG_FILE"
  else
    echo "Invalid input. Please enter 'create' or 'update'."
    exit 1
  fi
}

create_or_update_cluster

