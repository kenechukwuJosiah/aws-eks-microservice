

setup_monitoring() {

  echo "Setting up Prometheus and Grafana for monitoring..."

  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

  helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace
    
  echo "To access Grafana, run the following command to get the admin password and username:"

  echo "kubectl get secret --namespace default kube-prometheus-stack-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode; echo"

  echo "kubectl get secret --namespace default kube-prometheus-stack-grafana -o jsonpath="{.data.admin-user}" | base64 --decode; echo"

  echo "You can access Grafana at http://localhost:3000"
  echo "kubectl port-forward svc/prometheus-stack-grafana -n monitoring 3000:80"
  echo "Grafana is now running on port 3000. You can access it via your web browser."

  kubectl apply -n monitoring -f ./configs/monitor || { echo "Failed to apply Ingress"; exit 1; }

  echo "Prometheus and Grafana setup completed successfully."
}