# Complete Kubernetes Monitoring Stack

This repository contains Helm charts for a complete Kubernetes monitoring solution with **kube-state-metrics**, **Prometheus**, and **Grafana**.

## Overview

This monitoring stack provides comprehensive observability for your Kubernetes cluster:

- **kube-state-metrics**: Generates metrics about Kubernetes object states
- **Prometheus**: Collects and stores metrics from various sources
- **Grafana**: Visualizes metrics with dashboards and alerts

## Components

### 1. Kube-State-Metrics
Generates metrics about the state of various Kubernetes objects including:
- Pods, Deployments, Services, Nodes
- Persistent Volumes, ConfigMaps, Secrets
- Jobs, CronJobs, DaemonSets, StatefulSets
- Ingresses, NetworkPolicies, and more

### 2. Prometheus
Collects metrics from:
- kube-state-metrics (Kubernetes object states)
- Kubernetes API server
- Kubernetes nodes and pods
- Custom application metrics

### 3. Grafana
Provides visualization with:
- Pre-configured dashboards for Kubernetes monitoring
- Prometheus as default data source
- Custom panels and alerts

## Quick Start

### Prerequisites
- Kubernetes cluster (1.16+)
- Helm 3.0+
- Minikube or any Kubernetes environment

### 1. Deploy Kube-State-Metrics

```bash
helm install kube-state-metrics ./kube-state-metrics \
  --namespace kube-system \
  --create-namespace
```

### 2. Deploy Prometheus

```bash
helm install prometheus ./prometheus \
  --namespace monitoring \
  --create-namespace
```

### 3. Deploy Grafana

```bash
helm install grafana ./grafana \
  --namespace monitoring
```

### 4. Access the Services

```bash
# Port forward services
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
kubectl port-forward svc/grafana 3000:80 -n monitoring
kubectl port-forward svc/kube-state-metrics 8080:8080 -n kube-system

# Access URLs:
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3000 (admin/admin123)
# KSM Metrics: http://localhost:8080/metrics
```

## Detailed Installation

### Kube-State-Metrics

```bash
helm install kube-state-metrics ./kube-state-metrics \
  --namespace kube-system \
  --set collectors[0]=pods \
  --set collectors[1]=deployments \
  --set collectors[2]=services
```

### Prometheus

```bash
helm install prometheus ./prometheus \
  --namespace monitoring \
  --set persistence.enabled=true \
  --set persistence.size=20Gi
```

### Grafana

```bash
helm install grafana ./grafana \
  --namespace monitoring \
  --set persistence.enabled=true \
  --set grafana.admin.password="your-secure-password"
```

## Configuration

### Custom Domains

Update `values.yaml` files to use your domains:

```yaml
# grafana/values.yaml
ingress:
  hosts:
    - host: grafana.yourdomain.com

# prometheus/values.yaml
ingress:
  hosts:
    - host: prometheus.yourdomain.com
```

### Enable TLS

```yaml
ingress:
  tls:
    - secretName: grafana-tls
      hosts:
        - grafana.yourdomain.com
```

### Resource Limits

Adjust resources based on your cluster size:

```yaml
resources:
  limits:
    cpu: 500m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 512Mi
```

## Accessing Services

### Grafana
- **URL**: http://localhost:3000 or your configured domain
- **Username**: admin
- **Password**: admin123 (change in production!)
- **Pre-loaded Dashboards**:
  - Kubernetes Cluster Monitoring (ID: 315)
  - Kubernetes API Server (ID: 12006)
  - Node Exporter (ID: 1860)
  - Persistent Volumes (ID: 673)

### Prometheus
- **URL**: http://localhost:9090 or your configured domain
- **Targets**: Check `/targets` to see scraped endpoints
- **Query**: Use PromQL to query metrics

### Kube-State-Metrics
- **URL**: http://localhost:8080/metrics
- **Raw Metrics**: Direct access to all generated metrics

## Sample Queries

### Prometheus Queries

```
# Pod status
kube_pod_status_phase{namespace="default",phase="Running"}

# Deployment replicas
kube_deployment_spec_replicas{namespace="default"}
kube_deployment_status_replicas_available{namespace="default"}

# Node resources
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes

# Service endpoints
kube_service_spec_type
```

### Grafana Dashboards

1. **Cluster Overview**: CPU, memory, and network usage
2. **Pods**: Status, restarts, resource usage
3. **Nodes**: Capacity, allocatable resources
4. **Persistent Volumes**: Usage and status

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n monitoring
kubectl get pods -n kube-system | grep kube-state-metrics
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=prometheus -n monitoring
kubectl logs -l app.kubernetes.io/name=grafana -n monitoring
kubectl logs -l app.kubernetes.io/name=kube-state-metrics -n kube-system
```

### Prometheus Targets

Visit `http://localhost:9090/targets` to check if all targets are healthy.

### Grafana Data Sources

In Grafana, go to **Configuration** → **Data Sources** to verify Prometheus connection.

## Production Considerations

### Security
- Change default Grafana password
- Enable TLS/HTTPS
- Use RBAC for access control
- Secure Prometheus endpoints

### Persistence
- Enable persistence for Prometheus and Grafana
- Configure appropriate storage classes
- Set up backup strategies

### Scaling
- Adjust resource limits based on cluster size
- Consider Prometheus federation for large clusters
- Use Grafana high availability setup

### Monitoring
- Set up alerts in Grafana/Prometheus
- Monitor the monitoring stack itself
- Configure log aggregation

## Uninstallation

```bash
helm uninstall grafana -n monitoring
helm uninstall prometheus -n monitoring
helm uninstall kube-state-metrics -n kube-system
```

## Chart Versions

- **kube-state-metrics**: 2.10.0
- **Prometheus**: 2.45.0
- **Grafana**: 10.2.0

## Resources

- [Kube-State-Metrics Documentation](https://github.com/kubernetes/kube-state-metrics)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)