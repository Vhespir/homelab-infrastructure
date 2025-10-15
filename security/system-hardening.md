# System Hardening and Security Practices

## Overview
Documentation of security hardening measures implemented on this Arch Linux system. These practices demonstrate security awareness and defensive security capabilities relevant to security analyst and system administrator roles.

## Security Layers Implemented

### 1. Hardware-Based Authentication

#### FIDO2/U2F Security Key for Sudo
**Configuration:** `/etc/pam.d/sudo`

```
auth    sufficient pam_u2f.so cue authfile=/etc/fido2/fido2
```

**Security Benefits:**
- **Hardware-based authentication**: Physical security key required for privileged operations
- **Phishing-resistant**: Cannot be stolen through social engineering
- **No passwords to compromise**: Hardware token provides cryptographic proof
- **Compliance-ready**: Meets high security standards (FIDO2/U2F)

**How It Works:**
- Sudo commands require physical presence of security key
- Key provides cryptographic authentication
- No shared secrets that can be intercepted
- Stronger than password or software 2FA

**Skills Demonstrated:**
- Advanced authentication methods
- PAM (Pluggable Authentication Modules) configuration
- FIDO2/U2F protocol understanding
- Modern security standard implementation

### 2. Intrusion Prevention - Fail2Ban

#### Configuration
**Location:** `/etc/fail2ban/jail.local`

```ini
[sshd]
enabled = true
port = 3666
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

**Security Features:**
- **SSH Protection**: Monitors SSH login attempts on custom port 3666
- **Automatic Banning**: Blocks IPs after 3 failed attempts
- **Ban Duration**: 1 hour (3600 seconds) timeout
- **Port Security**: SSH running on non-standard port reduces automated attacks

**Management Commands:**
```bash
# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# View banned IPs
sudo fail2ban-client get sshd banned

# Unban an IP manually
sudo fail2ban-client set sshd unbanip <IP_ADDRESS>

# Check logs
sudo journalctl -u fail2ban -f
```

**Skills Demonstrated:**
- Intrusion prevention system configuration
- Brute-force attack mitigation
- Log-based security automation
- Custom port configuration for security

### 3. Endpoint Protection - ClamAV

#### Services Running
- `clamav-daemon.service` - Main antivirus scanning daemon
- `clamav-freshclam.service` - Automatic virus definition updates
- `clamav-clamonacc.service` - On-access scanning for real-time protection

**Features:**
- Real-time file system monitoring
- Automatic virus definition updates
- System-wide malware protection
- Integration with monitoring stack for threat alerts

**Detailed Documentation:** See [clamav-setup.md](clamav-setup.md)

### 4. Security Monitoring and Alerting

#### Alertmanager Integration
- Real-time security event notifications via Discord webhook
- Failed authentication monitoring
- Service anomaly detection
- Automated incident response

**Monitored Security Events:**
- ClamAV threat detections
- Service crashes and restarts
- Resource exhaustion attempts
- Fail2ban ban events
- Unusual system behavior

**Detailed Documentation:** See [alertmanager-setup.md](alertmanager-setup.md)

### 5. Service Hardening

#### SSH Hardening
```bash
# Custom configuration
Port 3666                    # Non-standard port
PermitRootLogin no          # Best practice
MaxAuthTries 3              # Limited attempts
```

**Security Benefits:**
- Non-standard port reduces automated scanning
- Fail2ban provides brute-force protection
- Limited authentication attempts
- Root login disabled

#### Docker Security

**Best Practices Applied:**
- Non-root containers when possible
- Resource limits to prevent DoS
- Read-only filesystems where appropriate
- Minimal capability sets
- Regular image updates
- Container health monitoring via cAdvisor

```bash
# Example secure container run
docker run --security-opt=no-new-privileges:true \
           --cap-drop=ALL \
           --memory="512m" \
           --cpus="1.0" \
           --pids-limit=100 \
           image:tag
```

**Detailed Documentation:** See [../setup/docker-containerization.md](../setup/docker-containerization.md)

#### Samba Security

**Configuration Highlights:**
- User-level authentication required
- SMB3 minimum protocol (no SMB1 vulnerabilities)
- Detailed logging for audit trails
- Group-based access control
- Proper file permissions (0660/0770)

```ini
[global]
    security = user
    server min protocol = SMB3
    log level = 2

[share]
    valid users = @sambashare
    guest ok = no
    create mask = 0660
    directory mask = 0770
```

**Detailed Documentation:** See [../setup/network-services.md](../setup/network-services.md)

### 6. Network Security

#### Port Configuration
- **SSH**: Port 3666 (non-standard)
- **Samba**: Port 445 (standard, protected by user auth)
- **TigerVNC**: Port 5901 (VNC password auth, SSH tunneling recommended)
- **Monitoring**: Ports on localhost only (Grafana, Prometheus)

#### Network Service Isolation
- Monitoring services bound to localhost
- Public services require authentication
- Unnecessary services disabled
- Fail2ban protecting exposed services

### 7. Logging and Auditing

#### Centralized Logging
All security-relevant events are logged via systemd journal:
- Authentication attempts (successful and failed)
- Service start/stop events
- Fail2ban ban/unban actions
- ClamAV scan results
- Docker container events
- Sudo usage with hardware key authentication

#### Log Monitoring
```bash
# Monitor authentication logs
journalctl -u sshd -f
journalctl | grep "Failed password"

# Monitor fail2ban activity
journalctl -u fail2ban -f

# Monitor sudo usage
journalctl | grep sudo

# Monitor service failures
journalctl -p err -f

# ClamAV logs
journalctl -u clamav-daemon -f
```

### 8. Update Management

#### System Updates
```bash
# Check for updates
checkupdates

# Update system
sudo pacman -Syu

# Update Docker images
docker images --format "{{.Repository}}:{{.Tag}}" | xargs -L1 docker pull
```

**Automated Monitoring:**
- Health check script monitors update availability
- Prometheus alerts for outdated packages
- Regular update schedule

### 9. Backup and Recovery

#### Automated Configuration Backups
- Daily automated backups via custom script
- Timestamped archives with SHA256 checksums
- 7-day rotation policy
- Includes all critical configurations

**Script:** [backup-configs.sh](../scripts/backup-configs.sh)

**What's Backed Up:**
- Prometheus, Alertmanager, Grafana configs
- Samba configuration
- Docker daemon settings
- ClamAV configuration
- Fail2ban configuration
- PAM configuration (authentication settings)
- Custom systemd services
- System files (fstab, hosts, hostname)

## Security Monitoring Dashboard

### Grafana Security Panels
Created dashboards monitoring:
- Failed login attempts
- Fail2ban ban activity
- ClamAV threat detections
- Service restart frequency
- Resource usage anomalies
- Container health status

### Alert Rules
Key security alerts configured in Prometheus:
- ClamAV threat detection
- Multiple failed login attempts
- Service restart loops
- Unusual CPU/memory/disk usage
- Container health failures

## Incident Response Workflow

### 1. Detection
- Alertmanager sends notification to Discord
- Alert includes event details and affected system
- Administrator reviews alert priority

### 2. Initial Response
```bash
# Check fail2ban status
sudo fail2ban-client status sshd

# Review recent authentication attempts
journalctl -u sshd --since "1 hour ago" | grep -i failed

# Check for suspicious processes
ps aux | sort -k3 -r | head -20

# Review network connections
ss -tulpn
```

### 3. Investigation
```bash
# Check banned IPs
sudo fail2ban-client get sshd banned

# Review ClamAV scan results
journalctl -u clamav-daemon --since "1 hour ago"

# Check Docker container logs
docker logs container_name --since 1h

# Review system metrics
docker stats --no-stream

# Check sudo usage
journalctl | grep sudo --since "1 hour ago"
```

### 4. Remediation
- Block malicious IPs (handled automatically by fail2ban)
- Remove or quarantine threats
- Update security rules
- Patch vulnerabilities
- Document incident

## Security Best Practices Checklist

- [x] Hardware-based authentication for privileged operations
- [x] FIDO2/U2F security key implementation
- [x] Intrusion prevention system (fail2ban) active
- [x] SSH on non-standard port
- [x] Endpoint antivirus installed and active
- [x] Real-time threat monitoring enabled
- [x] Automated security updates monitored
- [x] Strong authentication mechanisms
- [x] Principle of least privilege applied
- [x] Services hardened with security best practices
- [x] Comprehensive logging enabled
- [x] Security alerts configured
- [x] Regular backups with tested recovery
- [x] Docker containers run with security options
- [x] Network services use proper authentication
- [x] Incident response procedures documented

## Tools and Security Commands

### Hardware Key Management
```bash
# List registered FIDO2 keys
cat /etc/fido2/fido2

# Test sudo with hardware key
sudo -v
# (Requires physical presence and touch of security key)

# View PAM configuration
cat /etc/pam.d/sudo
```

### Fail2Ban Management
```bash
# Check overall status
sudo fail2ban-client status

# Check specific jail
sudo fail2ban-client status sshd

# View banned IPs
sudo fail2ban-client get sshd banned

# Unban IP
sudo fail2ban-client set sshd unbanip 1.2.3.4

# Reload configuration
sudo fail2ban-client reload
```

### Security Auditing
```bash
# Check listening ports
ss -tulpn

# Check running services
systemctl list-units --type=service --state=running

# Review recent logins
last -n 20
lastlog

# Check sudo usage
journalctl | grep sudo | tail -20

# Review authentication logs
journalctl | grep "authentication" --since "24 hours ago"
```

### System Health Check
```bash
# Run comprehensive health check
./scripts/system-health-check.sh --full

# Quick check
./scripts/system-health-check.sh --brief
```

## Skills Demonstrated

### Advanced Security Implementation
- Hardware-based authentication (FIDO2/U2F)
- PAM module configuration
- Intrusion detection and prevention
- Multi-layered security approach
- Modern security protocols

### Security Analyst Capabilities
- Threat monitoring and alerting
- Log analysis and correlation
- Incident investigation and response
- Security tool configuration and management
- Compliance-ready authentication methods

### System Administrator Skills
- Service hardening and configuration
- Access control implementation
- Network security configuration
- Automated monitoring and alerting
- Backup and disaster recovery

### Help Desk Readiness
- Security awareness and best practices
- User authentication troubleshooting
- Remote access support
- Documentation and knowledge sharing

## Professional Value

This security implementation demonstrates:
- **Enterprise-Grade Security**: Hardware authentication meets strict compliance requirements
- **Defense in Depth**: Multiple layers of protection (hardware auth, fail2ban, antivirus, monitoring)
- **Modern Standards**: FIDO2/U2F implementation shows current security knowledge
- **Proactive Monitoring**: Real-time alerting and automated response
- **Automation**: Reduced manual intervention through scripting
- **Documentation**: Clear procedures for maintenance and incident response

## Compliance and Standards

### Security Standards Met
- **FIDO2/U2F**: Modern phishing-resistant authentication
- **Defense in Depth**: Multiple security layers
- **Audit Logging**: Comprehensive event tracking
- **Access Control**: Principle of least privilege
- **Incident Response**: Documented procedures

### Applicable Frameworks
- **NIST Cybersecurity Framework**: Identify, Protect, Detect, Respond, Recover
- **CIS Benchmarks**: Linux hardening guidelines
- **Zero Trust Principles**: Hardware-based authentication, least privilege

## Integration with Monitoring Stack

Security services integrated with Prometheus/Grafana/Alertmanager:
- Fail2ban ban events tracked and alerted
- Service availability monitoring
- Resource usage anomaly detection
- Failed authentication tracking
- Container security monitoring
- ClamAV threat detection alerts

## Continuous Improvement

### Regular Activities
- Daily: Review security alerts and logs
- Weekly: Check fail2ban ban statistics and sudo usage
- Monthly: Review and update security configurations
- Quarterly: Security audit and penetration testing
- Ongoing: Security training and certification

### Future Enhancements
- Expand hardware key usage to SSH authentication
- Implement file integrity monitoring (AIDE)
- Add intrusion detection system (Snort/Suricata)
- Set up centralized SIEM solution
- Add SELinux or AppArmor mandatory access control
- Expand fail2ban to cover more services
- Implement automated security testing

## References
- [FIDO Alliance Documentation](https://fidoalliance.org/specifications/)
- [pam_u2f Documentation](https://developers.yubico.com/pam-u2f/)
- [Fail2Ban Documentation](https://fail2ban.readthedocs.io/)
- [Arch Linux Security](https://wiki.archlinux.org/title/Security)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
