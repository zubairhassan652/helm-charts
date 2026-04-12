# Node Exporter Setup Guide for Prometheus

## Overview

Node Exporter is a Prometheus exporter for hardware and OS metrics. It collects system-level metrics from each node in your Kubernetes cluster and exposes them for Prometheus to scrape.

## What is Node Exporter?

Node Exporter exposes metrics such as:
- CPU usage
- Memory usage
- Disk I/O
- Network I/O
- Process metrics
- System temperature
- And many more hardware/OS metrics

---

## Prerequisites

- Kubernetes cluster running (minikube is fine)
- Helm 3.0+
- Prometheus already deployed in the `monitoring` namespace

---

## Installation

### 1. Deploy Node Exporter

```bash
helm install node-exporter ./node-exporter \
  --namespace monitoring \
  --create-namespace
```

### 2. Verify Node Exporter is Running

```bash
# Check DaemonSet status
kubectl get daemonset -n monitoring
kubectl describe daemonset node-exporter -n monitoring

# Check pods
kubectl get pods -n monitoring | grep node-exporter

# Check service
kubectl get svc -n monitoring | grep node-exporter
```

### 3. Port Forward to Node Exporter

```powershell
kubectl port-forward svc/node-exporter 9100:9100 -n monitoring
```

Then visit: **http://localhost:9100/metrics** to see the raw metrics.

---

## Configuration

### Custom Node Selection

To deploy node-exporter only on specific nodes, add node labels:

```bash
# Label a node
kubectl label nodes minikube node-role=worker

# Deploy with node selector
helm install node-exporter ./node-exporter \
  --namespace monitoring \
  --set nodeSelector.node-role=worker
```

### Custom Collectors

Enable/disable specific metric collectors by modifying the args in `values.yaml`:

```yaml
args:
  - "--path.procfs=/host/proc"
  - "--path.rootfs=/rootfs"
  - "--path.sysfs=/host/sys"
  - "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
  # Disable specific collectors
  - "--no-collector.wifi"
  - "--no-collector.hwmon"
```

---

## Prometheus Integration

The Node Exporter chart is already configured for Prometheus scraping. Your Prometheus instance will automatically discover and scrape node-exporter metrics.

### Verify Prometheus is Scraping Node Exporter

1. Port forward to Prometheus:
```bash
kubectl port-forward svc/prometheus 9090:80 -n monitoring
```

2. Open: **http://localhost:9090**

3. Go to **Status** → **Targets**

4. Look for the `node-exporter` job - it should show as `UP`

### Query Node Metrics in Prometheus

```
# CPU usage
node_cpu_seconds_total

# Memory usage
node_memory_MemFree_bytes
node_memory_MemTotal_bytes

# Disk usage
node_filesystem_avail_bytes

# Network traffic
node_network_transmit_bytes_total
node_network_receive_bytes_total
```

---

## Grafana Dashboards

### Add Node Exporter Dashboard to Grafana

Once Grafana is running:

1. Port forward to Grafana:
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

2. Open: **http://localhost:3000**
   - Username: `admin`
   - Password: `admin123`

3. Go to **+** (Create) → **Import**

4. Enter dashboard ID: **1860** (Node Exporter Full)

5. Select Prometheus data source and click **Import**

### Popular Node Exporter Dashboards

| Dashboard ID | Name | Description |
|--------------|------|-------------|
| 1860 | Node Exporter Full | Complete system overview |
| 11074 | Node Exporter for Prometheus | Detailed node metrics |
| 8919 | Node Exporter Server Metrics | CPU, memory, disk, network |

---

## Troubleshooting

### Node Exporter pods not running

```bash
# Check pod status
kubectl describe pod node-exporter-xxxxx -n monitoring

# Check logs
kubectl logs -f pod/node-exporter-xxxxx -n monitoring
```

### Prometheus not scraping node-exporter

```bash
# Check Prometheus configuration
kubectl exec -it deployment/prometheus-release -n monitoring -- sh

# Inside pod, check prometheus.yml
cat /etc/prometheus/prometheus.yml

# Restart Prometheus
kubectl rollout restart deployment/prometheus-release -n monitoring
```

### Metrics not appearing in Prometheus

1. Verify node-exporter service exists:
```bash
kubectl get svc node-exporter -n monitoring
kubectl get endpoints node-exporter -n monitoring
```

2. Check Prometheus targets at: http://localhost:9090/targets

3. If target is down, check DNS resolution:
```bash
kubectl exec -it svc/prometheus -n monitoring -- nslookup node-exporter.monitoring.svc.cluster.local
```

---

## Advanced Configuration

### Enable Textfile Collector

For custom metrics, enable textfile collection:

```yaml
args:
  - "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"
```

### Add Custom Metrics

Mount custom metric files into the textfile directory and they'll be exposed by node-exporter.

### High Cardinality Metrics

If you have high cardinality metrics causing performance issues:

```yaml
args:
  - "--no-collector.netdev"
  - "--collector.netdev.device-exclude=^(veth.*)$"
```

---

## Uninstallation

```bash
helm uninstall node-exporter --namespace monitoring
```

---

## Quick Reference Commands

```powershell
# Deploy
helm install node-exporter ./node-exporter -n monitoring

# Check status
kubectl get daemonset -n monitoring
kubectl get pods -n monitoring | grep node-exporter

# View metrics
kubectl port-forward svc/node-exporter 9100:9100 -n monitoring
# Visit: http://localhost:9100/metrics

# Check Prometheus targets
kubectl port-forward svc/prometheus 9090:80 -n monitoring
# Visit: http://localhost:9090/targets

# View logs
kubectl logs -l app.kubernetes.io/name=node-exporter -n monitoring -f

# Uninstall
helm uninstall node-exporter -n monitoring
```

---

## Integration with Other Exporters

The same pattern works for other exporters:
- **kube-state-metrics** - Kubernetes object metrics
- **cAdvisor** - Container metrics
- **Alertmanager** - Alert handling
- **Custom exporters** - Any Prometheus-compatible exporter

Just follow the same process:
1. Create a chart with a Service exposing metrics
2. Add scrape config to Prometheus
3. Query metrics in Prometheus/Grafana

---

## Resources

- [Node Exporter Documentation](https://github.com/prometheus/node_exporter)
- [Prometheus Scrape Config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config)
- [Grafana Node Dashboards](https://grafana.com/grafana/dashboards/)
