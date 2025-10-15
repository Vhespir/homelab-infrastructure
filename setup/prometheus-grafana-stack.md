# Prometheus and Grafana Monitoring Stack

## Overview
Deployed a complete observability stack using Prometheus for metrics collection and Grafana for visualization. This provides comprehensive system monitoring, performance analytics, and operational insights.

## Stack Components

### Core Services
- **Prometheus** - Time-series database and metrics collection
- **Grafana** - Visualization and dashboard platform
- **Node Exporter** - System-level metrics
- **Blackbox Exporter** - Endpoint monitoring and health checks
- **cAdvisor** - Container metrics (Docker)
- **Alertmanager** - Alert routing and notification

### Architecture
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Exporters  │────→│  Prometheus  │────→│   Grafana   │
└─────────────┘     └──────────────┘     └─────────────┘
                            │
                            ↓
                    ┌──────────────┐
                    │ Alertmanager │
                    └──────────────┘
```

## Installation

### Base Packages
```bash
# Install Prometheus stack
sudo pacman -S prometheus prometheus-node-exporter prometheus-blackbox-exporter

# Install Grafana
sudo pacman -S grafana

# Install cAdvisor (via Docker)
docker run -d \
  --name=cadvisor \
  --restart=always \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  gcr.io/cadvisor/cadvisor:latest
```

### Service Enablement
```bash
# Enable all monitoring services
sudo systemctl enable --now prometheus
sudo systemctl enable --now prometheus-node-exporter
sudo systemctl enable --now prometheus-blackbox-exporter
sudo systemctl enable --now grafana
```

## Prometheus Configuration

### Main Configuration
File: `/etc/prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alert rule files
rule_files:
  - /etc/prometheus/alert_rules.yml

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # System metrics
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  # Container metrics
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['localhost:8080']

  # Service health checks
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://localhost:3000  # Grafana
          - http://localhost:9090  # Prometheus
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115
```

### Alert Rules
File: `/etc/prometheus/alert_rules.yml`

Key alerts configured:
- High CPU usage (>80% for 5 minutes)
- Low disk space (<10% free)
- High memory usage (>90%)
- Service down alerts
- Container restart monitoring
- Network anomaly detection

## Grafana Configuration

### Access and Setup
- **Default URL**: http://localhost:3000
- **Initial Login**: admin/admin (changed immediately)

### Dashboards Configured
1. **System Overview**
   - CPU, Memory, Disk, Network usage
   - System load and uptime
   - Process statistics

2. **Container Monitoring**
   - Docker container metrics
   - Resource usage per container
   - Container health status

3. **Service Health**
   - Endpoint availability
   - Response times
   - HTTP status codes

4. **Security Dashboard**
   - ClamAV scan results
   - Failed login attempts
   - Service restart events

### Data Source Configuration
```bash
# Add Prometheus data source in Grafana
Name: Prometheus
Type: Prometheus
URL: http://localhost:9090
Access: Server (default)
```

## Metrics Collected

### System Metrics (Node Exporter)
- CPU utilization and load
- Memory and swap usage
- Disk I/O and space
- Network traffic and errors
- System temperature
- Systemd service status

### Container Metrics (cAdvisor)
- Container CPU/Memory usage
- Network I/O per container
- Filesystem usage
- Container lifecycle events

### Application Metrics
- Service availability
- Response times
- Error rates
- Custom application metrics

## Skills Demonstrated
- Time-series database management
- Metrics collection and aggregation
- Data visualization and dashboard design
- PromQL query language
- Service monitoring and observability
- Performance tuning and optimization
- Infrastructure as Code principles
- SRE/DevOps practices

## Monitoring Best Practices Implemented

### 1. The Four Golden Signals
- **Latency** - Response time monitoring
- **Traffic** - Request rate tracking
- **Errors** - Error rate monitoring
- **Saturation** - Resource utilization

### 2. Alert Design
- Clear, actionable alerts
- Appropriate thresholds based on baselines
- Severity levels (critical, warning, info)
- Runbook links for common issues

### 3. Dashboard Design
- Logical grouping of related metrics
- Appropriate visualization types
- Consistent time ranges
- Drill-down capabilities

## Maintenance and Operations

### Regular Tasks
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq

# Validate configuration
promtool check config /etc/prometheus/prometheus.yml

# Check alert rules
promtool check rules /etc/prometheus/alert_rules.yml

# Reload Prometheus configuration
sudo systemctl reload prometheus

# Backup Grafana dashboards
curl -H "Authorization: Bearer [API_KEY]" \
  http://localhost:3000/api/search?query= > grafana_dashboards_backup.json
```

### Performance Tuning
- Configured appropriate retention periods
- Optimized scrape intervals based on metric importance
- Implemented metric relabeling for efficiency
- Set up recording rules for complex queries

## Troubleshooting

```bash
# Check service status
systemctl status prometheus grafana

# View Prometheus logs
journalctl -u prometheus -f

# View Grafana logs
journalctl -u grafana -f

# Check scrape targets
curl localhost:9090/api/v1/targets

# Query specific metric
curl 'localhost:9090/api/v1/query?query=up'
```

## Use Cases
- Infrastructure monitoring for production systems
- Capacity planning and resource optimization
- Performance troubleshooting and root cause analysis
- SLA monitoring and reporting
- Anomaly detection
- Predictive alerting

## Professional Value
This setup demonstrates proficiency in:
- Modern observability practices
- SRE principles (monitoring, SLIs, SLOs)
- Open-source enterprise tools
- System administration at scale
- Data-driven decision making
- Proactive system management

## Security Considerations
- Grafana accessible only on localhost (or behind reverse proxy)
- API authentication configured
- Sensitive metrics access controlled
- Alert data sanitized before external notification
- Regular security updates applied

## Future Enhancements
- Implement long-term metrics storage (Thanos/Cortex)
- Add distributed tracing (Jaeger/Tempo)
- Set up log aggregation (Loki)
- Create custom exporters for proprietary applications
- Implement service mesh monitoring (if applicable)
- Set up federated Prometheus for multi-node environments

## References
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboard Design](https://grafana.com/docs/grafana/latest/best-practices/)
