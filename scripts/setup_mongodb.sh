
setup_mongodb() {
  echo "Setting up MongoDB..."

  helm install mongo bitnami/mongodb -n mongo \
  --create-namespace \
  --set auth.enabled=true \
  --set auth.rootUser=root \
  --set auth.rootPassword=u2LKSJLDIW98209JLSKJ \
  --set auth.username=admin \
  --set auth.password=u9028209LDIW98209JLSKJ \
  --set auth.database=eksdemo \
  --set externalAccess.enabled=true \
  --set externalAccess.service.type=NodePort \
  --set serviceAccount.create=true \
  --set automountServiceAccountToken=true \
  --set rbac.create=true \
  --set persistence.enabled=true \
  --set persistence.storageClass="gp2" \
  --set persistence.size=2Gi \
  --set resources.limits.cpu=200m \
  --set resources.limits.memory=512Mi \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=206Mi \
  --set readinessProbe.timeoutSeconds=15 \
  --set readinessProbe.failureThreshold=10 \
  --set livenessProbe.timeoutSeconds=15 \
  --set livenessProbe.failureThreshold=10

  echo "MongoDB setup completed successfully."
}