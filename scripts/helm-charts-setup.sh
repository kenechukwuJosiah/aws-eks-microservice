#!/usr/local/bin/bash

setup_appcharts() {
  echo "Please Enter Action to perform (install/update/delete)"
  read action

  # Validate action
  if [[ "$action" != "install" && "$action" != "update" && "$action" != "delete" ]]; then
    echo "Invalid action: $action"
    echo "Usage: setup_appcharts [install|update|delete]"
    return 1
  fi

  # Define charts
  declare -A charts
  charts=( 
    ["admin"]="./helm/admin-chart"
    ["user"]="./helm/user-chart"
    ["auth"]="./helm/auth-chart"
  )

  for chart in "${!charts[@]}"; do
    chart_path="${charts[$chart]}"
    values_file="$chart_path/values.yaml"

    case "$action" in
      install)
        echo "Installing $chart..."
        helm install "$chart" "$chart_path" --values "$values_file"
        ;;
      update)
        echo "Updating $chart..."
        helm upgrade "$chart" "$chart_path" --values "$values_file"
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
