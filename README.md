# Argocd Password
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }; echo ""`

# Minikube docker shell
`minikube docker-env | Invoke-Expression`

# Enable ingress addons
`minikube addons enable ingress`

# Add and update the repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Perform the fresh install
helm install argocd argo/argo-cd `
  --namespace argocd `
  --set applicationSet.enabled=true `
  --set notifications.enabled=true `
  --set crds.install=true `
  --set server.extraArgs={--insecure}
  

# Add the Grafana repo
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install the stack (Loki + Promtail)
helm upgrade --install loki grafana/loki-stack `
  --namespace argocd `
  --set promtail.enabled=true `
  --set loki.persistence.enabled=true `
  --set loki.persistence.size=5Gi `
  --set promtail.config.lokiAddress="http://loki:3100/loki/api/v1/push"

