
setup_cert_manager(){
  echo "Setting up Cert Manager..."

  CONFIG_PATH="./configs/certs"

  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

  echo "Do you want to continue deploying Certificate and Cert Issuer? "
  read -rp "To continue Enter (Yes/No): " ANS

  if [ "$ANS" == "Yes" ]; then
    echo "Applying Certificate and Cert Issuer..."
    kubectl apply -f $CONFIG_PATH --validate=false
  else
    echo "Skipping step..."
  fi

  echo "Setup Done."
}
