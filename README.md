# Linux System Administration Portfolio

This repository documents my Linux system administration work, security implementations, and automation projects. It serves as both a personal knowledge base and a professional portfolio demonstrating hands-on technical capabilities.

**Author:** Shane Nichols
**System:** Arch Linux
**Focus Areas:** System Administration, Security Analysis, Help Desk Support

---

## Overview

This documentation showcases real-world implementations of:
- Enterprise monitoring and alerting infrastructure
- Security hardening and threat detection
- Network services configuration
- Container orchestration and management
- Automation and scripting
- Incident response procedures

---

## Repository Structure

### [`security/`](security/) - Security Implementation & Hardening
- **[ClamAV Setup](security/clamav-setup.md)** - Real-time antivirus with on-access scanning
- **[Alertmanager Configuration](security/alertmanager-setup.md)** - Security event monitoring and Discord webhook integration
- **[System Hardening](security/system-hardening.md)** - Hardware authentication (FIDO2/U2F), fail2ban, comprehensive security practices

### [`setup/`](setup/) - Infrastructure & Services
- **[Prometheus & Grafana Stack](setup/prometheus-grafana-stack.md)** - Complete observability platform with custom dashboards
- **[Docker & Containerization](setup/docker-containerization.md)** - Container management, security, and monitoring
- **[Network Services](setup/network-services.md)** - Samba file sharing and NoMachine remote desktop

### [`scripts/`](scripts/) - Automation & Tools
- **[system-health-check.sh](scripts/system-health-check.sh)** - Comprehensive system monitoring script
- **[backup-configs.sh](scripts/backup-configs.sh)** - Automated configuration backup with rotation
- **[docker-cleanup.sh](scripts/docker-cleanup.sh)** - Docker resource management utility
- **[Scripts Documentation](scripts/README.md)** - Detailed usage and automation examples

### `troubleshooting/` - Problem-Solving Documentation
*Future section for troubleshooting guides and incident post-mortems*

---

## Key Skills Demonstrated

### System Administration
- Service deployment and configuration (Prometheus, Grafana, Docker, Samba)
- Systemd service management
- Network service configuration
- Backup and disaster recovery
- Performance monitoring and optimization
- Log analysis and troubleshooting

### Security Analysis
- Hardware-based authentication (FIDO2/U2F security keys)
- Intrusion prevention (fail2ban)
- Endpoint protection (ClamAV)
- Security monitoring and alerting
- Incident detection and response
- Defense in depth strategy
- Compliance awareness (NIST, CIS Benchmarks)

### Automation & Scripting
- Bash scripting with error handling
- Automated monitoring and health checks
- Configuration backup automation
- Resource management scripts
- Cron job scheduling

### Help Desk Support
- Remote access solutions (NoMachine)
- Cross-platform file sharing (Samba)
- User authentication troubleshooting
- Documentation and knowledge sharing
- Multi-platform environment support

---

## Technical Environment

### Infrastructure Stack
```
┌─────────────────────────────────────────┐
│         Monitoring & Alerting           │
│  Prometheus → Grafana → Alertmanager   │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│            Security Layer               │
│  ClamAV • fail2ban • FIDO2 Auth        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Services & Apps                │
│  Docker • Samba • NoMachine • cAdvisor │
└─────────────────────────────────────────┘
```

### Services Running
- **Security**: ClamAV (antivirus), fail2ban (IPS), hardware security key auth
- **Monitoring**: Prometheus, Grafana, Alertmanager, Node Exporter, Blackbox Exporter, cAdvisor
- **Containers**: Docker Engine, containerd, multiple containerized applications
- **Network**: Samba file server, NoMachine remote desktop
- **Automation**: Custom Bash scripts, cron jobs, automated backups

---

## Highlighted Projects

### 1. Complete Observability Stack
Deployed Prometheus + Grafana + Alertmanager for comprehensive system monitoring:
- Custom dashboards for system health, container metrics, and security events
- Real-time alerting via Discord webhooks
- Multi-exporter configuration (node, blackbox, cAdvisor)
- PromQL queries for advanced metrics analysis

**Skills**: Monitoring, data visualization, alerting, SRE practices

### 2. Hardware-Based Security Authentication
Implemented FIDO2/U2F security key for sudo privileges:
- PAM module configuration for hardware authentication
- Phishing-resistant authentication
- Compliance-ready security standards
- Modern cryptographic authentication

**Skills**: Advanced authentication, PAM configuration, security protocols, compliance

### 3. Automated Security Monitoring
Configured multi-layered security with automated response:
- Real-time malware detection with ClamAV
- Brute-force protection with fail2ban
- Automated alerting for security events
- Comprehensive audit logging

**Skills**: Intrusion prevention, threat detection, incident response

### 4. Infrastructure Automation
Created Bash scripts for operational tasks:
- System health monitoring with threshold-based alerts
- Automated configuration backups with rotation
- Docker resource cleanup and management
- Modular, reusable, well-documented code

**Skills**: Bash scripting, automation, DevOps practices

---

## Professional Value

This repository demonstrates capabilities relevant to:

**System Administrator Roles:**
- Linux server deployment and management
- Service configuration and hardening
- Monitoring and performance tuning
- Backup and disaster recovery
- Automation and scripting

**Security Analyst Roles:**
- Security monitoring and alerting
- Threat detection and prevention
- Incident response procedures
- Security tool configuration
- Compliance and best practices

**Help Desk Roles:**
- Remote support tools
- User authentication systems
- Cross-platform troubleshooting
- Documentation and knowledge base
- Problem-solving methodology

---

## Best Practices Applied

- **Infrastructure as Code**: Documented configurations for reproducibility
- **Security by Design**: Multiple layers of defense, hardware authentication
- **Monitoring First**: Comprehensive observability before issues arise
- **Automation**: Reduce manual tasks through scripting
- **Documentation**: Clear, detailed guides for knowledge sharing
- **Backup Strategy**: Regular automated backups with tested recovery

---

## Getting Started

### Exploring the Documentation
1. Review [security/system-hardening.md](security/system-hardening.md) for security implementation overview
2. Check [setup/prometheus-grafana-stack.md](setup/prometheus-grafana-stack.md) for monitoring architecture
3. Explore [scripts/](scripts/) directory for automation examples

### Running the Scripts
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run system health check
./scripts/system-health-check.sh --full

# Backup configurations (requires sudo)
sudo ./scripts/backup-configs.sh

# Clean up Docker resources
./scripts/docker-cleanup.sh --containers --images
```

---

## Continuous Learning

### Current Focus
- Expanding security monitoring capabilities
- Learning advanced Prometheus/Grafana features
- Exploring container orchestration (Kubernetes)
- Studying for security certifications

### Future Enhancements
- File integrity monitoring (AIDE)
- Centralized SIEM solution
- Automated penetration testing
- Infrastructure as Code with Ansible/Terraform
- Kubernetes cluster deployment

---

## Contact

**Shane Nichols**
Email: shane@shanenichols.dev
GitHub: [github.com/vhespir](https://github.com/vhespir)

---

## References & Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

---

**Last Updated:** October 2025
