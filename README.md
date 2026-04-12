# Kube-State-Metrics Helm Chart

This repository contains a Helm chart for deploying **kube-state-metrics**, a service that generates metrics about the state of various Kubernetes objects.

## Overview

Kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. It exposes these metrics via an HTTP endpoint that can be scraped by Prometheus.

## What is Kube-State-Metrics?

Kube-state-metrics generates metrics about:
- **Pods**: Status, restarts, resource usage
- **Deployments**: Replicas, status, conditions
- **Services**: Endpoints, types
- **Nodes**: Conditions, capacity, allocatable
- **Persistent Volumes**: Status, capacity, claims
- **Jobs/CronJobs**: Status, completion time
- **ConfigMaps/Secrets**: Count and metadata
- **And many more Kubernetes objects**

## Installation

### Prerequisites

- Kubernetes cluster (1.16+)
- Helm 3.0+

### Deploy Kube-State-Metrics

```bash
helm install kube-state-metrics ./kube-state-metrics \
  --namespace kube-system \
  --create-namespace
```

### Verify Installation

```bash
# Check deployment
kubectl get deployment kube-state-metrics -n kube-system

# Check service
kubectl get service kube-state-metrics -n kube-system

# Check pods
kubectl get pods -l app.kubernetes.io/name=kube-state-metrics -n kube-system
```

## Accessing Metrics

### Port Forward to Access Metrics

```bash
kubectl port-forward svc/kube-state-metrics 8080:8080 -n kube-system
```

Then visit: **http://localhost:8080/metrics**

### Sample Metrics

```
# Pods
kube_pod_info{namespace="default",pod="nginx-12345",node="minikube"}
kube_pod_status_phase{namespace="default",phase="Running"} 1

# Deployments
kube_deployment_spec_replicas{namespace="default",deployment="nginx"} 3
kube_deployment_status_replicas_available{namespace="default",deployment="nginx"} 3

# Services
kube_service_info{namespace="default",service="nginx-service",type="ClusterIP"}
kube_service_spec_type{namespace="default",service="nginx-service",type="ClusterIP"} 1

# Nodes
kube_node_info{node="minikube",kernel_version="5.15.0",os_image="Ubuntu 20.04.5 LTS"}
kube_node_status_capacity_cpu_cores 2
kube_node_status_capacity_memory_bytes 8.3e+09
```

## Configuration

### Enable/Disable Collectors

Edit `values.yaml` to customize which resource collectors to enable:

```yaml
collectors:
  - pods
  - deployments
  - services
  - nodes
  - persistentvolumes
  # Add or remove collectors as needed

disabledCollectors:
  - secrets  # Disable if you don't want secret metrics
```

### Resource Limits

Adjust resource requests and limits in `values.yaml`:

```yaml
resources:
  limits:
    cpu: 100m
    memory: 150Mi
  requests:
    cpu: 10m
    memory: 64Mi
```

## Integration with Prometheus

### Manual Scrape Configuration

Add to your Prometheus configuration:

```yaml
scrape_configs:
  - job_name: 'kube-state-metrics'
    static_configs:
      - targets: ['kube-state-metrics.kube-system.svc.cluster.local:8080']
```

### Using Service Discovery

```yaml
scrape_configs:
  - job_name: 'kube-state-metrics'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_endpoints_name]
        regex: 'kube-state-metrics'
        action: keep
      - source_labels: [__meta_kubernetes_endpoint_port_name]
        regex: 'http-metrics'
        action: keep
```

## Troubleshooting

### Check Pod Logs

```bash
kubectl logs -l app.kubernetes.io/name=kube-state-metrics -n kube-system
```

### Check Service Endpoints

```bash
kubectl get endpoints kube-state-metrics -n kube-system
```

### Common Issues

1. **RBAC Permissions**: Ensure the service account has proper cluster permissions
2. **Resource Limits**: Increase memory limits if metrics collection is slow
3. **Network Policies**: Ensure kube-state-metrics can access the Kubernetes API

## Uninstallation

```bash
helm uninstall kube-state-metrics -n kube-system
```

## Resources

- [Kube-State-Metrics GitHub](https://github.com/kubernetes/kube-state-metrics)
- [Available Metrics Documentation](https://github.com/kubernetes/kube-state-metrics/blob/master/docs/metrics.md)
- [Prometheus Integration](https://prometheus.io/docs/guides/kube-state-metrics/)

## Chart Details

- **Chart Version**: 1.0.0
- **App Version**: 2.10.0
- **Kubernetes**: >= 1.16.0
- **Helm**: >= 3.0.0