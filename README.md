# Argocd Password
`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }; echo ""`

# Minikube docker shell
`minikube docker-env | Invoke-Expression`

# Enable ingress addons
`minikube addons enable ingress`

