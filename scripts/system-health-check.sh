#!/bin/bash

###############################################################################
# System Health Check Script
#
# Purpose: Performs comprehensive system health checks including:
#          - Service status monitoring
#          - Disk usage checks
#          - Memory and CPU usage
#          - Docker container health
#          - Security service status
#
# Usage: ./system-health-check.sh [--brief|--full]
# Author: Shane Nichols
# Date: 2025
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DISK_WARN_THRESHOLD=80
MEMORY_WARN_THRESHOLD=85
CPU_WARN_THRESHOLD=90

# Critical services to monitor
CRITICAL_SERVICES=(
    "docker"
    "prometheus"
    "grafana"
    "alertmanager"
    "clamav-daemon"
    "clamav-freshclam"
)

print_header() {
    echo -e "\n${GREEN}==================== $1 ====================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_services() {
    print_header "Service Status Check"

    local failed_services=0

    for service in "${CRITICAL_SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            print_success "$service is running"
        else
            print_error "$service is NOT running"
            ((failed_services++))
        fi
    done

    echo -e "\nSummary: $failed_services service(s) failed"
    return $failed_services
}

check_disk_usage() {
    print_header "Disk Usage Check"

    local warning_count=0

    while IFS= read -r line; do
        filesystem=$(echo "$line" | awk '{print $1}')
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mountpoint=$(echo "$line" | awk '{print $6}')

        if [ "$usage" -ge "$DISK_WARN_THRESHOLD" ]; then
            print_warning "$mountpoint is at ${usage}% capacity (${filesystem})"
            ((warning_count++))
        else
            print_success "$mountpoint is at ${usage}% capacity"
        fi
    done < <(df -h | grep '^/dev/' | grep -v '/boot')

    return $warning_count
}

check_memory() {
    print_header "Memory Usage Check"

    local mem_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')

    if [ "$mem_usage" -ge "$MEMORY_WARN_THRESHOLD" ]; then
        print_warning "Memory usage is at ${mem_usage}%"
        return 1
    else
        print_success "Memory usage is at ${mem_usage}%"
        return 0
    fi
}

check_cpu_load() {
    print_header "CPU Load Check"

    local cpu_count=$(nproc)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local load_percent=$(echo "scale=0; ($load_avg / $cpu_count) * 100" | bc)

    if [ "$load_percent" -ge "$CPU_WARN_THRESHOLD" ]; then
        print_warning "CPU load is at ${load_percent}% (${load_avg} on ${cpu_count} cores)"
        return 1
    else
        print_success "CPU load is at ${load_percent}% (${load_avg} on ${cpu_count} cores)"
        return 0
    fi
}

check_docker_containers() {
    print_header "Docker Container Health"

    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed"
        return 0
    fi

    local unhealthy_count=0
    local containers=$(docker ps --format "{{.Names}}")

    if [ -z "$containers" ]; then
        print_warning "No running containers found"
        return 0
    fi

    while IFS= read -r container; do
        local status=$(docker inspect --format='{{.State.Status}}' "$container")
        local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no healthcheck{{end}}' "$container")

        if [ "$status" = "running" ] && ([ "$health" = "healthy" ] || [ "$health" = "no healthcheck" ]); then
            print_success "Container $container: $status ($health)"
        else
            print_error "Container $container: $status ($health)"
            ((unhealthy_count++))
        fi
    done <<< "$containers"

    return $unhealthy_count
}

check_security_services() {
    print_header "Security Services Status"

    local issues=0

    # Check ClamAV virus definitions age
    if [ -f /var/lib/clamav/main.cvd ]; then
        local def_age=$(find /var/lib/clamav/main.cvd -mtime +7 2>/dev/null | wc -l)
        if [ "$def_age" -gt 0 ]; then
            print_warning "ClamAV virus definitions are older than 7 days"
            ((issues++))
        else
            print_success "ClamAV virus definitions are up to date"
        fi
    fi

    # Check if Alertmanager has active alerts
    if command -v amtool &> /dev/null; then
        local alert_count=$(amtool alert query 2>/dev/null | grep -c 'Alertname' || true)
        if [ "$alert_count" -gt 0 ]; then
            print_warning "There are $alert_count active alert(s) in Alertmanager"
        else
            print_success "No active alerts in Alertmanager"
        fi
    fi

    return $issues
}

check_system_updates() {
    print_header "System Updates Check"

    if command -v checkupdates &> /dev/null; then
        local update_count=$(checkupdates 2>/dev/null | wc -l || echo 0)
        if [ "$update_count" -gt 0 ]; then
            print_warning "$update_count package update(s) available"
            return 1
        else
            print_success "System is up to date"
            return 0
        fi
    else
        print_warning "Cannot check for updates (checkupdates not available)"
        return 0
    fi
}

show_summary() {
    print_header "Health Check Summary"

    local total_issues=$1

    if [ "$total_issues" -eq 0 ]; then
        print_success "All systems operational!"
    elif [ "$total_issues" -le 3 ]; then
        print_warning "System health: FAIR - $total_issues issue(s) detected"
    else
        print_error "System health: POOR - $total_issues issue(s) detected"
    fi

    echo -e "\nSystem uptime: $(uptime -p)"
    echo -e "Check completed: $(date '+%Y-%m-%d %H:%M:%S')\n"
}

main() {
    local mode="${1:-full}"
    local total_issues=0

    echo "============================================"
    echo "    System Health Check - $(hostname)"
    echo "============================================"

    check_services || ((total_issues += $?))
    check_disk_usage || ((total_issues += $?))
    check_memory || ((total_issues += $?))
    check_cpu_load || ((total_issues += $?))

    if [ "$mode" = "--full" ] || [ "$mode" = "full" ]; then
        check_docker_containers || ((total_issues += $?))
        check_security_services || ((total_issues += $?))
        check_system_updates || ((total_issues += $?))
    fi

    show_summary $total_issues

    # Exit with error code if issues found
    [ "$total_issues" -eq 0 ]
}

# Run main function
main "$@"
