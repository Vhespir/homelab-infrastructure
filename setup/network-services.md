# Network Services Configuration

## Overview
Configured Samba file sharing and TigerVNC remote desktop on Arch Linux. These services provide cross-platform file sharing capabilities and secure remote access for troubleshooting and system administration tasks.

## Services Configured

### Samba File Sharing
- **nmb.service** - NetBIOS name resolution
- **smb.service** - SMB/CIFS file sharing protocol
- Cross-platform file sharing (Windows/Linux/macOS)

### Remote Desktop Access
- **TigerVNC** - Lightweight VNC server for remote desktop
- Used for remote troubleshooting and technical support
- Cross-platform compatibility (Windows, Mac, Linux)

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

## TigerVNC Remote Desktop

### Installation and Setup
```bash
# Install TigerVNC
sudo pacman -S tigervnc

# Set VNC password
vncpasswd

# Start VNC server on display :1
vncserver :1

# View running VNC sessions
vncserver -list
```

### Configuration
**Location:** `~/.vnc/config`

```bash
# VNC server configuration
geometry=1920x1080
dpi=96
localhost=no
alwaysshared
```

### Connection Information
- **Default Port**: 5901 (for display :1), 5902 (for display :2), etc.
- **Protocol**: RFB (Remote Framebuffer Protocol)
- **Authentication**: VNC password

### Client Setup

**macOS:**
1. Built-in Screen Sharing app
2. Connect to: `vnc://server-ip:5901`
3. Enter VNC password

**Windows:**
1. Download TigerVNC Viewer or RealVNC Viewer
2. Connect to: `server-ip:5901` or `server-ip::5901`
3. Enter VNC password

**Linux:**
```bash
# Using vncviewer
vncviewer server-ip:1

# Or with tigervnc
vncviewer server-ip:5901
```

### Security Configuration

```bash
# Configure firewall to allow VNC
sudo iptables -A INPUT -p tcp --dport 5901 -j ACCEPT

# For SSH tunneling (recommended for security)
ssh -L 5901:localhost:5901 user@server-ip
# Then connect VNC client to localhost:5901
```

### Server Management

```bash
# Start VNC server
vncserver :1

# Stop VNC server
vncserver -kill :1

# List active sessions
vncserver -list

# View logs
cat ~/.vnc/*.log
```

### SSH Tunneling for Security

For secure connections over the internet, use SSH tunneling:

```bash
# On local machine, create SSH tunnel
ssh -L 5901:localhost:5901 user@remote-server

# In VNC client, connect to:
localhost:5901

# This encrypts all VNC traffic through SSH
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

### TigerVNC Remote Access
- Remote troubleshooting for friends and family
- Technical support for macOS users
- Cross-platform desktop access
- Lightweight alternative to heavier remote desktop solutions
- SSH tunneling for secure connections

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

### TigerVNC: Cannot Connect
```bash
# Check if VNC server is running
vncserver -list

# Verify port is listening
sudo ss -tlnp | grep 5901

# Check firewall
sudo iptables -L INPUT -n | grep 5901

# Review VNC logs
cat ~/.vnc/*.log

# Restart VNC server
vncserver -kill :1
vncserver :1
```

### TigerVNC: Slow Performance
- Reduce resolution in `~/.vnc/config`
- Use SSH tunneling to reduce overhead
- Check network bandwidth with iperf3
- Lower color depth in VNC client settings
- Verify system resource usage on server

### TigerVNC: Authentication Issues
```bash
# Reset VNC password
vncpasswd

# Check VNC server is accessible
vncviewer localhost:1  # Test locally first

# For macOS connections, ensure format is correct:
# vnc://server-ip:5901
```

## Maintenance Tasks

### Daily
- Monitor service status via monitoring stack
- Check for failed authentication attempts
- Verify services are accessible

### Weekly
- Review Samba access logs
- Check VNC session logs
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

2. **TigerVNC Security**
   - VNC password authentication
   - SSH tunneling for encrypted connections
   - Firewall rules limiting access
   - Session monitoring
   - Recommended use through SSH tunnel for internet access

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
- Systemd service for automatic VNC server startup
- VPN integration for secure remote access
- LDAP/Active Directory integration for centralized auth
- Automated backup of Samba shares
- Bandwidth throttling for fair usage

## References
- [Samba Documentation](https://www.samba.org/samba/docs/)
- [Arch Linux Samba Wiki](https://wiki.archlinux.org/title/Samba)
- [TigerVNC Documentation](https://tigervnc.org/)
- [Arch Linux TigerVNC Wiki](https://wiki.archlinux.org/title/TigerVNC)
