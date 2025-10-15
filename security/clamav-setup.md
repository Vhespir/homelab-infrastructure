# ClamAV Antivirus Setup on Arch Linux

## Overview
Implemented real-time antivirus scanning using ClamAV with on-access scanning capabilities. This provides enterprise-grade malware protection suitable for security-conscious environments.

## Components Configured

### Services Running
- `clamav-daemon.service` - Main antivirus scanning daemon
- `clamav-freshclam.service` - Automatic virus definition updates
- `clamav-clamonacc.service` - On-access scanning for real-time protection

### Key Features
- Real-time file system monitoring
- Automatic virus definition updates
- System-wide malware protection
- Integration with system monitoring stack

## Installation Steps

```bash
# Install ClamAV packages
sudo pacman -S clamav

# Configure freshclam for virus definition updates
sudo cp /etc/clamav/freshclam.conf.sample /etc/clamav/freshclam.conf
sudo sed -i 's/^Example/#Example/' /etc/clamav/freshclam.conf

# Configure clamd daemon
sudo cp /etc/clamav/clamd.conf.sample /etc/clamav/clamd.conf
sudo sed -i 's/^Example/#Example/' /etc/clamav/clamd.conf

# Update virus definitions
sudo freshclam

# Enable and start services
sudo systemctl enable --now clamav-freshclam.service
sudo systemctl enable --now clamav-daemon.service
sudo systemctl enable --now clamav-clamonacc.service
```

## Configuration Highlights

### On-Access Scanning
Configured clamonacc to monitor critical directories in real-time:
- User home directories
- Temporary directories
- Download locations

### Performance Optimization
- Excluded development directories to reduce false positives
- Configured appropriate scan depth limits
- Tuned memory usage for desktop environment

## Verification

```bash
# Check service status
systemctl status clamav-daemon
systemctl status clamav-clamonacc

# Test scanning functionality
clamscan -r /path/to/test

# Check virus definition version
sigtool --info /var/lib/clamav/main.cvd
```

## Monitoring Integration
ClamAV logs are monitored through the Alertmanager stack for immediate notification of:
- Detected threats
- Service failures
- Definition update issues

## Skills Demonstrated
- Antivirus deployment and configuration
- Real-time security monitoring
- Service management with systemd
- Security best practices for endpoint protection
- Integration with monitoring infrastructure

## Use Cases
- Desktop workstation hardening
- File server protection
- Security compliance requirements
- Malware detection and prevention

## Maintenance

### Regular Tasks
- Monitor virus definition updates (automated)
- Review scan logs weekly
- Update exclusion rules as needed
- Test detection capabilities monthly

### Troubleshooting
```bash
# Check logs for issues
journalctl -u clamav-daemon -f
journalctl -u clamav-clamonacc -f

# Manually update definitions
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam
```

## References
- [ClamAV Documentation](https://docs.clamav.net/)
- [Arch Linux ClamAV Wiki](https://wiki.archlinux.org/title/ClamAV)
