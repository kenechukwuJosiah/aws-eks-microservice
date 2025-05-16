#!/usr/local/bin/bash

COMMAND=$1

shift 1

case "$COMMAND" in
  cluster)
    source  "$(dirname "$0")/scripts/cluster-setup.sh"
    manage_cluster
    ;;

  chart)

    ;;

  ingress)
    source "$(dirname "$0")/scripts/ingress-setup.sh"
    setup_ingress_controller "$@"
    ;;

  argocd)
    source "$(dirname "$0")/scripts/argocd-setup.sh"
    setup_argo
    ;;

  *)
    echo "Usage: $0 {cluster|chart|ingress} <subcommands> [options]"
    exit 1
    ;;

esac