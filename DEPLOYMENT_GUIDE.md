# Helm Charts for Grafana, Prometheus, and Sentry

This directory contains three Helm charts for deploying monitoring and error tracking applications with domain-based access.

## Charts Overview

### 1. **Grafana** - Visualization & Dashboards
- **Domain:** `grafana.example.com`
- **Port:** 3000
- **Default Credentials:** admin/admin123
- **Repository:** grafana/grafana

### 2. **Prometheus** - Metrics Monitoring
- **Domain:** `prometheus.example.com`
- **Port:** 9090
- **Purpose:** Metrics collection and alerting
- **Repository:** prom/prometheus

### 3. **Sentry** - Error Tracking
- **Domain:** `sentry.example.com`
- **Port:** 9000
- **Purpose:** Real-time error monitoring and event tracking
- **Repository:** sentry
- **Dependencies:** PostgreSQL, Redis

---

## Prerequisites

Before deploying these charts, ensure you have:

1. **Kubernetes Cluster** - Running Kubernetes 1.20+
2. **Helm** - Version 3.0+
3. **Ingress Controller** - NGINX Ingress Controller recommended
4. **DNS Configuration** - Update your DNS or /etc/hosts with your domain names

```bash
# Example /etc/hosts entries for local development
127.0.0.1   grafana.example.com
127.0.0.1   prometheus.example.com
127.0.0.1   sentry.example.com
```

---

## Installation

### 1. Install Grafana

```bash
helm install grafana ./grafana \
  --namespace monitoring \
  --create-namespace \
  --set ingress.hosts[0].host=grafana.example.com
```

**Access Grafana:**
```
http://grafana.example.com (or https if TLS is configured)
Username: admin
Password: admin123
```

### 2. Install Prometheus

```bash
helm install prometheus ./prometheus \
  --namespace monitoring \
  --set ingress.hosts[0].host=prometheus.example.com
```

**Access Prometheus:**
```
http://prometheus.example.com/graph
```

### 3. Install Sentry (with dependencies)

For Sentry, first update the dependencies:

```bash
cd sentry
helm dependency update
cd ..

helm install sentry ./sentry \
  --namespace monitoring \
  --set ingress.hosts[0].host=sentry.example.com \
  --set sentry.environment.SENTRY_SECRET_KEY="your-secret-key-here"
```

**Access Sentry:**
```
http://sentry.example.com
```

---

## Configuration

### Customize Domain Names

Each chart has domain configuration in its `values.yaml` file. You can override these during installation or afterward:

**For Grafana:**
```bash
helm upgrade grafana ./grafana \
  --set ingress.hosts[0].host=grafana.yourdomain.com \
  --reuse-values
```

**For Prometheus:**
```bash
helm upgrade prometheus ./prometheus \
  --set ingress.hosts[0].host=prometheus.yourdomain.com \
  --reuse-values
```

**For Sentry:**
```bash
helm upgrade sentry ./sentry \
  --set ingress.hosts[0].host=sentry.yourdomain.com \
  --reuse-values
```

### Enable TLS/HTTPS

To enable SSL/TLS certificates using cert-manager:

```bash
# Update values.yaml or use --set during install
--set ingress.annotations."cert-manager\.io/cluster-issuer"=letsencrypt-prod \
--set ingress.tls[0].secretName=grafana-tls \
--set ingress.tls[0].hosts[0]=grafana.example.com
```

Or edit the respective `values.yaml` files:

```yaml
ingress:
  tls:
    - secretName: grafana-tls
      hosts:
        - grafana.example.com
```

### Enable Persistence

To enable data persistence (recommended for production):

**Grafana:**
```bash
helm upgrade grafana ./grafana \
  --set persistence.enabled=true \
  --set persistence.size=20Gi \
  --reuse-values
```

**Prometheus:**
```bash
helm upgrade prometheus ./prometheus \
  --set persistence.enabled=true \
  --set persistence.size=50Gi \
  --reuse-values
```

**Sentry:**
```bash
helm upgrade sentry ./sentry \
  --set persistence.enabled=true \
  --set persistence.size=30Gi \
  --reuse-values
```

### Configure Sentry Database and Redis

Edit `sentry/values.yaml` to configure database and Redis connections:

```yaml
sentry:
  environment:
    SENTRY_SECRET_KEY: "your-unique-secret-key"
    SENTRY_POSTGRES_HOST: "sentry-postgresql"
    SENTRY_POSTGRES_PASSWORD: "your-secure-password"
    SENTRY_EMAIL_HOST: "your-smtp-host"
    SENTRY_EMAIL_PASSWORD: "your-email-password"
```

---

## Verification

### Check Installation Status

```bash
# List all releases in monitoring namespace
helm list --namespace monitoring

# Get status of a deployment
helm status grafana --namespace monitoring
helm status prometheus --namespace monitoring
helm status sentry --namespace monitoring
```

### Check Pod Status

```bash
kubectl get pods --namespace monitoring
kubectl describe pod <pod-name> --namespace monitoring
```

### View Logs

```bash
# Grafana logs
kubectl logs -f deployment/grafana-release -n monitoring

# Prometheus logs
kubectl logs -f deployment/prometheus-release -n monitoring

# Sentry logs
kubectl logs -f deployment/sentry-release -n monitoring
```

---

## Integration Guide

### Connect Prometheus to Grafana

1. Open Grafana: `http://grafana.example.com`
2. Go to **Configuration** → **Data Sources**
3. Click **Add data source**
4. Select **Prometheus**
5. Set URL to: `http://prometheus-release:80`
6. Click **Save & Test**

### Configure Grafana with Sentry

1. Install Sentry datasource plugin (if needed)
2. Add Sentry as a datasource
3. Create dashboards using Sentry metrics

---

## Uninstallation

To remove the charts:

```bash
helm uninstall grafana --namespace monitoring
helm uninstall prometheus --namespace monitoring
helm uninstall sentry --namespace monitoring
```

To remove the namespace:

```bash
kubectl delete namespace monitoring
```

---

## Troubleshooting

### Ingress not accessible

```bash
# Check ingress status
kubectl get ingress --namespace monitoring
kubectl describe ingress grafana-release --namespace monitoring

# Check ingress controller
kubectl get pods --namespace ingress-nginx
```

### Pods not starting

```bash
# Check events
kubectl describe pod <pod-name> --namespace monitoring

# Check resource limits
kubectl top pods --namespace monitoring
```

### Database connection errors (Sentry)

Ensure PostgreSQL and Redis are running:
```bash
kubectl get pods --namespace monitoring | grep postgres
kubectl get pods --namespace monitoring | grep redis
```

---

## Important Notes

- **Security:** Update default passwords and secrets in production
- **Persistence:** Enable persistence for production deployments
- **Resource Limits:** Adjust resource requests/limits based on your cluster capacity
- **TLS Certificates:** Install cert-manager for automatic HTTPS
- **Email Configuration:** For Sentry notifications, configure SMTP settings

---

## Quick Start Commands

```bash
# Deploy all three charts with custom domains
helm install grafana ./grafana --namespace monitoring --create-namespace \
  --set ingress.hosts[0].host=grafana.example.com

helm install prometheus ./prometheus --namespace monitoring \
  --set ingress.hosts[0].host=prometheus.example.com

cd sentry && helm dependency update && cd ..
helm install sentry ./sentry --namespace monitoring \
  --set ingress.hosts[0].host=sentry.example.com \
  --set sentry.environment.SENTRY_SECRET_KEY="your-secret-key"
```

---

## Support & Documentation

- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Sentry Documentation](https://docs.sentry.io/)
