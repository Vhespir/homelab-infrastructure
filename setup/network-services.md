# Network Services Configuration

## Overview
Configured Samba file sharing and NoMachine remote desktop server on Arch Linux. These services provide cross-platform file sharing capabilities and secure remote access for system administration tasks.

## Services Configured

### Samba File Sharing
- **nmb.service** - NetBIOS name resolution
- **smb.service** - SMB/CIFS file sharing protocol
- Cross-platform file sharing (Windows/Linux/macOS)

### Remote Access
- **nxserver.service** - NoMachine remote desktop server
- Secure remote system access
- Full desktop remote control

## Samba File Sharing Setup

### Installation and Configuration
```bash
# Install Samba
sudo pacman -S samba

# Create Samba configuration
sudo vim /etc/samba/smb.conf

# Enable and start services
sudo systemctl enable --now nmb.service
sudo systemctl enable --now smbd.service
```

### Basic Samba Configuration
```ini
[global]
   workgroup = WORKGROUP
   server string = Arch Linux File Server
   security = user
   map to guest = Bad User
   log file = /var/log/samba/%m.log
   max log size = 50

[shared]
   path = /srv/samba/shared
   browseable = yes
   writable = yes
   guest ok = no
   valid users = @sambashare
   create mask = 0660
   directory mask = 0770
```

### User Management
```bash
# Create Samba user
sudo smbpasswd -a username

# Enable Samba user
sudo smbpasswd -e username

# List Samba users
sudo pdbedit -L -v

# Test Samba configuration
testparm
```

### Accessing Shares from Different Platforms

**Windows:**
```
\\<server-ip>\shared
```

**Linux:**
```bash
# Mount Samba share
sudo mount -t cifs //server-ip/shared /mnt/share -o username=user

# Or use file manager (Nautilus, Dolphin, etc.)
smb://server-ip/shared
```

**macOS:**
```
smb://server-ip/shared
```

### Troubleshooting Samba

```bash
# Check service status
sudo systemctl status smbd nmbd

# View Samba connections
smbstatus

# Test shares locally
smbclient -L localhost -N
smbclient //localhost/share -U username

# Check logs
sudo journalctl -u smbd -f
sudo journalctl -u nmbd -f

# Validate configuration
testparm
```

## NoMachine Remote Desktop

### Setup and Configuration
```bash
# NoMachine installed and configured
# Service runs automatically

# Check service status
sudo systemctl status nxserver

# View NoMachine status
sudo /usr/NX/bin/nxserver --status

# Restart service if needed
sudo systemctl restart nxserver
```

### Connection Information
- **Default Port**: 4000/tcp
- **Protocol**: NX protocol (proprietary, encrypted)
- **Authentication**: System user credentials

### Client Setup
1. Download NoMachine client from [nomachine.com](https://www.nomachine.com/)
2. Install on remote device (Windows, Mac, Linux, mobile)
3. Create new connection to server IP/hostname
4. Authenticate with system username and password
5. Select desktop session

### Security Configuration

```bash
# Configure firewall to allow NoMachine
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --reload

# Or with iptables
sudo iptables -A INPUT -p tcp --dport 4000 -j ACCEPT
```

### NoMachine Server Management

```bash
# Start/stop/restart server
sudo /usr/NX/bin/nxserver --start
sudo /usr/NX/bin/nxserver --stop
sudo /usr/NX/bin/nxserver --restart

# Check server status
sudo /usr/NX/bin/nxserver --status

# List active connections
sudo /usr/NX/bin/nxserver --list

# View logs
sudo tail -f /usr/NX/var/log/nxserver.log
```

## Skills Demonstrated

### System Administration
- Network service configuration and deployment
- Cross-platform file sharing implementation
- Remote access solution setup
- Service monitoring and management
- Systemd service administration

### Help Desk Support
- Remote desktop support capabilities
- Multi-platform troubleshooting
- User access management
- Connection troubleshooting
- End-user support documentation

### Security Awareness
- User authentication configuration
- Network service hardening
- Firewall configuration
- Access control implementation
- Encrypted remote connections

## Use Cases

### Samba File Sharing
- Sharing files between Linux and Windows workstations
- Centralized document storage
- Home directory sharing
- Printer sharing
- Cross-platform collaboration

### NoMachine Remote Access
- Remote technical support
- System administration from home
- Server management without physical access
- Remote troubleshooting
- Off-site work capabilities

## Common Troubleshooting Scenarios

### Samba: Cannot Access Share
```bash
# Verify services are running
sudo systemctl status smbd nmbd

# Check firewall
sudo firewall-cmd --list-services
sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --reload

# Verify share permissions
ls -la /path/to/share

# Check user exists in Samba
sudo pdbedit -L
```

### Samba: Authentication Failed
```bash
# Reset user password
sudo smbpasswd -a username

# Verify user is enabled
sudo pdbedit -L -v | grep username

# Check valid users in smb.conf
testparm -s
```

### NoMachine: Cannot Connect
```bash
# Verify service is running
sudo systemctl status nxserver
sudo /usr/NX/bin/nxserver --status

# Check if port is listening
sudo ss -tlnp | grep 4000

# Verify firewall allows connections
sudo firewall-cmd --list-ports
sudo iptables -L INPUT -n | grep 4000

# Check logs for errors
sudo tail -50 /usr/NX/var/log/nxserver.log
```

### NoMachine: Slow Performance
- Check network bandwidth (use iperf3)
- Adjust display quality in NoMachine settings
- Verify no other bandwidth-intensive processes
- Check system resource usage on server

## Maintenance Tasks

### Daily
- Monitor service status via monitoring stack
- Check for failed authentication attempts
- Verify services are accessible

### Weekly
- Review Samba access logs
- Check NoMachine connection logs
- Verify backups of configuration files

### Monthly
- Test backup and restore procedures
- Review and update user access lists
- Apply security updates
- Rotate log files

## Security Best Practices

### Implemented Measures

1. **Samba Security**
   - User-level authentication required
   - No guest access to sensitive shares
   - Strong password requirements
   - Regular password rotation
   - Access logging enabled

2. **NoMachine Security**
   - Encrypted connections (NX protocol)
   - System-level authentication
   - Monitor active sessions
   - Session timeouts configured
   - Access restricted by firewall

3. **General Network Security**
   - Firewall rules limiting access
   - Services bound to specific interfaces
   - Regular security updates
   - Log monitoring via Alertmanager

## Professional Value

This configuration demonstrates:
- **System Administrator Skills**: Service deployment, configuration management, troubleshooting
- **Help Desk Capabilities**: Remote support tools, user assistance, cross-platform support
- **Security Awareness**: Access control, authentication, encrypted communications
- **Documentation**: Clear technical writing for knowledge sharing

## Integration with Monitoring Stack

Both services are monitored through the Prometheus/Grafana/Alertmanager stack:
- Service availability alerts
- Failed authentication monitoring
- Resource usage tracking
- Connection count metrics

## Future Enhancements
- Two-factor authentication for NoMachine
- VPN integration for secure remote access
- LDAP/Active Directory integration for centralized auth
- Automated backup of Samba shares
- Bandwidth throttling for fair usage

## References
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Arch Linux Samba Wiki](https://wiki.archlinux.org/title/Samba)
- [NoMachine Documentation](https://www.nomachine.com/documentation)
- [NoMachine Server Guide](https://www.nomachine.com/AR02R01074)
