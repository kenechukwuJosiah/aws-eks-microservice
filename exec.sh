#!/usr/local/bin/bash

COMMAND=$1
SUBCOMMAND=$2

shift 2

case "$COMMAND" in
  cluster)
    source  "$(dirname "$0")/scripts/cluster-setup.sh"
    manage_cluster
    ;;

  chart)

    ;;

  ingress)

    ;;

  argocd)
    echo "$(dirname "$0")/scripts/argocd-setup.sh"
    source "$(dirname "$0")/scripts/argocd-setup.sh"
    setup_argo
    ;;

  *)
    echo "Commands: "$@""
    echo "Usage: $0 {cluster|chart|ingress} <subcommands> [options]"
    exit 1
    ;;

esac