#!/usr/local/bin/bash

setup_appcharts() {
  read -rp "Please Enter Action to perform (install/update/delete): "  action

  if [[ "$action" != "install" && "$action" != "update" && "$action" != "delete" ]]; then
    echo "Invalid action: $action"
    echo "Usage: setup_appcharts [install|update|delete]"
    return 1
  fi

  declare -A charts
  charts=( 
    ["admin"]="./helm/admin-chart"
    ["user"]="./helm/user-chart"
    ["auth"]="./helm/auth-chart"
  )

  read -rp "Which namespace would you like to use? (stage|prod): " namespace

  if [[ "$namespace" != "stage" && "$namespace" != "prod" ]]; then
    echo "Invalid namespace: $namespace"
    echo "Usage: setup_appcharts [stage|prod]"
    return 1
  fi

  for chart in "${!charts[@]}"; do
    chart_path="${charts[$chart]}"
    values_file="$chart_path/values.yaml"

    case "$action" in
      install)
        echo "Installing $chart..."
        helm install "$chart" "$chart_path" -n $namespace --values "$values_file" -f "./helm/values/$namespace.yaml"
        ;;
      update)
        echo "Updating $chart..."
        helm upgrade "$chart" "$chart_path" -n $namespace --values "$values_file" -f "./helm/values/$namespace.yaml"
        ;;
      delete)
        echo "Deleting $chart..."
        helm uninstall "$chart"
        ;;
      *) 
        echo "Invalid input; Accpeted values are (install/update/delete)"
        exit 1
        ;;
    esac
  done
}
