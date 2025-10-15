# Automation Scripts

This directory contains Bash scripts I've created for system administration, monitoring, and maintenance tasks.

## Scripts Overview

### system-health-check.sh
Comprehensive system health monitoring script that checks:
- Critical service status (Docker, Prometheus, Grafana, Alertmanager, ClamAV)
- Disk usage with configurable thresholds
- Memory and CPU utilization
- Docker container health
- Security service status
- Available system updates

**Usage:**
```bash
# Quick check (services, disk, memory, CPU only)
./system-health-check.sh --brief

# Full check (includes Docker containers and security checks)
./system-health-check.sh --full

# Can be run via cron for automated monitoring
0 */6 * * * /path/to/system-health-check.sh --full >> /var/log/health-checks.log 2>&1
```

**Skills Demonstrated:**
- Bash scripting best practices
- System monitoring and health checks
- Service management with systemd
- Threshold-based alerting logic
- Error handling and exit codes
- Colored terminal output

---

### backup-configs.sh
Automated configuration backup script with rotation.

**Features:**
- Backs up critical system and service configurations
- Creates timestamped, compressed archives
- Generates SHA256 checksums for integrity verification
- Automatic backup rotation (keeps last 7 days)
- Organized directory structure for easy restoration

**Usage:**
```bash
# Backup to default location (/var/backups/system-configs)
sudo ./backup-configs.sh

# Backup to custom location
sudo ./backup-configs.sh /mnt/backup/configs

# Automate with cron (daily at 2 AM)
0 2 * * * /path/to/backup-configs.sh >> /var/log/config-backup.log 2>&1
```

**What gets backed up:**
- Prometheus, Alertmanager, and Grafana configs
- Samba configuration
- Docker daemon settings
- ClamAV configuration
- Custom systemd services
- System files (fstab, hosts, hostname)
- Firewall rules

**Skills Demonstrated:**
- Disaster recovery planning
- Backup and restore procedures
- File archiving and compression
- Checksum verification
- Backup rotation logic
- Root privilege handling

---

### docker-cleanup.sh
Docker resource management and cleanup utility.

**Features:**
- Interactive and non-interactive modes
- Selective cleanup (containers, images, volumes, networks)
- Dry-run mode to preview changes
- Disk space reporting before/after
- Safety confirmations for destructive operations

**Usage:**
```bash
# Interactive mode (safe cleanup)
./docker-cleanup.sh

# Clean specific resources
./docker-cleanup.sh --containers
./docker-cleanup.sh --images
./docker-cleanup.sh --containers --images --networks

# Preview what would be removed (dry run)
./docker-cleanup.sh --dry-run --all

# Full cleanup with confirmation
./docker-cleanup.sh --all

# Clean unused volumes (with confirmation)
./docker-cleanup.sh --volumes
```

**Skills Demonstrated:**
- Docker resource management
- Command-line argument parsing
- Interactive user prompts
- Safe deletion with confirmations
- Disk space analysis
- Script flexibility with options

---

## Making Scripts Executable

```bash
# Make all scripts executable
chmod +x *.sh

# Or individually
chmod +x system-health-check.sh
chmod +x backup-configs.sh
chmod +x docker-cleanup.sh
```

## Automation with Cron

Example crontab entries for automated execution:

```bash
# Edit crontab
crontab -e

# Add these lines:

# System health check every 6 hours
0 */6 * * * /home/user/scripts/system-health-check.sh --full >> /var/log/health-checks.log 2>&1

# Daily configuration backup at 2 AM
0 2 * * * /home/user/scripts/backup-configs.sh >> /var/log/config-backup.log 2>&1

# Weekly Docker cleanup on Sunday at 3 AM
0 3 * * 0 /home/user/scripts/docker-cleanup.sh --containers --images >> /var/log/docker-cleanup.log 2>&1
```

## Best Practices Demonstrated

### Error Handling
- Use of `set -euo pipefail` for safe script execution
- Proper exit codes for success/failure
- Graceful handling of missing files/commands

### Code Quality
- Clear documentation and comments
- Modular functions for reusability
- Consistent formatting and style
- Meaningful variable names

### User Experience
- Colored output for readability
- Progress indicators (✓, ⚠, ✗)
- Clear error messages
- Help/usage information

### Security
- Root privilege checks where needed
- Safe file operations
- Confirmation prompts for destructive actions
- No hardcoded credentials

## Professional Value

These scripts demonstrate:
- **System Administration Skills**: Monitoring, backup/recovery, resource management
- **Automation Capabilities**: Reducing manual tasks through scripting
- **Problem-Solving**: Addressing real operational needs
- **Best Practices**: Following industry standards for script development
- **Documentation**: Clear usage instructions and examples

## Future Enhancements

Potential additions to this script collection:
- Log rotation and analysis script
- User account auditing script
- SSL certificate expiration monitoring
- Automated system update script with rollback
- Network connectivity monitoring
- Database backup automation

## Testing

Before deploying to production:
1. Test scripts in a safe environment
2. Use `--dry-run` flags when available
3. Verify backup restoration procedures
4. Check log output for errors
5. Validate cron job execution

## References
- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool
