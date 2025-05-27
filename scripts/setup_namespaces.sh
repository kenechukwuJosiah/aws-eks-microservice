
setup_namespace(){
  echo "Setting up namespaces..."

  if ! kubectl get namespace stage >/dev/null 2>&1; then
    kubectl create namespace stage || { echo "Failed to create stage namespace"; exit 1; }
  else
    echo "Namespace 'stage' already exists. Skipping creation."
  fi
  if ! kubectl get namespace prod >/dev/null 2>&1; then
    kubectl create namespace prod || { echo "Failed to create prod namespace"; exit 1; }
  else
    echo "Namespace 'prod' already exists. Skipping creation."
  fi
  if ! kubectl get namespace mongo >/dev/null 2>&1; then
    kubectl create namespace mongo || { echo "Failed to create mongo namespace"; exit 1; }
  else
    echo "Namespace 'mongo' already exists. Skipping creation."
  fi

  echo "Namespaces setup completed successfully."
}