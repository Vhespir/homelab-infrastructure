# Alertmanager Setup and Configuration

## Overview
Configured Alertmanager as part of a complete monitoring and alerting infrastructure. This provides real-time notifications for system issues, security events, and service failures.

## Architecture
```
Prometheus → Alertmanager → Discord Webhook
     ↓              ↓
  Metrics      Notifications
```

## Services Deployed
- `alertmanager.service` - Alert routing and management
- `discord-relay.service` - Custom webhook integration for Discord notifications
- Integration with Prometheus for metric-based alerting

## Installation and Configuration

### Base Setup
```bash
# Install Alertmanager
sudo pacman -S prometheus-alertmanager

# Configure Alertmanager
sudo vim /etc/alertmanager/alertmanager.yml

# Enable and start service
sudo systemctl enable --now alertmanager.service
```

### Configuration File Structure
Located at: `/etc/alertmanager/alertmanager.yml`

Key components configured:
- Route definitions for alert prioritization
- Receiver configurations for Discord webhooks
- Inhibit rules to reduce alert noise
- Grouping rules for related alerts

### Custom Discord Integration
Created custom relay service (`discord-relay.service`) to:
- Format alerts for Discord's webhook API
- Add severity-based color coding
- Include clickable links to Grafana dashboards
- Provide structured alert information

## Alert Rules
Alert rules defined in `/etc/prometheus/alert_rules.yml`

### Categories Monitored
1. **System Health**
   - High CPU usage
   - Memory pressure
   - Disk space warnings
   - Service failures

2. **Security Events**
   - ClamAV threat detections
   - Failed authentication attempts
   - Unusual network activity
   - Service restart anomalies

3. **Application Monitoring**
   - Container health
   - Service availability
   - Response time degradation

## Testing Alerts

```bash
# Send test alert
amtool alert add alertname="test" severity="warning"

# Check alert status
amtool alert query

# Validate configuration
amtool check-config /etc/alertmanager/alertmanager.yml
```

## Notification Channels

### Discord Webhook Setup
1. Created dedicated monitoring channel
2. Generated webhook URL in Discord server settings
3. Configured Alertmanager receiver with webhook endpoint
4. Implemented custom relay for enhanced formatting

## Skills Demonstrated
- Alert management and routing configuration
- Webhook integration and API development
- System monitoring strategy
- Incident response automation
- Custom service creation with systemd
- YAML configuration management

## Monitoring Best Practices Applied
- Alert severity levels (critical, warning, info)
- Alert grouping to prevent notification fatigue
- Inhibit rules to suppress redundant alerts
- Clear alert descriptions with actionable information
- Integration with visualization tools (Grafana)

## Maintenance Tasks

### Regular Activities
```bash
# Check Alertmanager status
systemctl status alertmanager

# View active alerts
amtool alert query

# Test notification channels
amtool alert add alertname="test"

# Review alert history
journalctl -u alertmanager -f
```

### Configuration Updates
```bash
# Validate before applying
amtool check-config /etc/alertmanager/alertmanager.yml

# Reload configuration
sudo systemctl reload alertmanager
```

## Integration with Other Systems
- **Prometheus**: Receives alerts based on metric thresholds
- **Grafana**: Links from alerts to relevant dashboards
- **Discord**: Real-time team notifications
- **ClamAV**: Security event alerting

## Use Cases
- Production system monitoring
- Security incident notification
- Service availability tracking
- Performance degradation alerts
- Compliance monitoring

## Troubleshooting

```bash
# Check service logs
journalctl -u alertmanager -n 50

# Verify webhook connectivity
curl -X POST [WEBHOOK_URL] -d '{"test": "message"}'

# Check alert routing
amtool config routes show

# View silenced alerts
amtool silence query
```

## Professional Value
This setup demonstrates:
- Enterprise monitoring practices
- Incident response automation
- Custom integration development
- Security awareness and proactive monitoring
- DevOps/SRE methodologies

## Future Enhancements
- PagerDuty integration for critical alerts
- SMS notifications for high-severity issues
- Alert trend analysis
- Automated remediation for common issues
- Integration with ticketing systems

## References
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Alert Routing Best Practices](https://prometheus.io/docs/practices/alerting/)
