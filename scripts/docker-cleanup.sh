#!/bin/bash

###############################################################################
# Docker Cleanup Script
#
# Purpose: Safely clean up Docker resources including stopped containers,
#          unused images, volumes, and networks
#
# Features:
#   - Interactive and non-interactive modes
#   - Disk space reporting before/after
#   - Selective cleanup options
#   - Safety checks before removal
#
# Usage: ./docker-cleanup.sh [--all|--containers|--images|--volumes|--dry-run]
# Author: Shane Nichols
# Date: 2025
###############################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DRY_RUN=false
CLEAN_CONTAINERS=false
CLEAN_IMAGES=false
CLEAN_VOLUMES=false
CLEAN_NETWORKS=false

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
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

show_disk_usage() {
    print_header "Docker Disk Usage"
    docker system df
}

cleanup_stopped_containers() {
    print_header "Cleaning Stopped Containers"

    local stopped_containers=$(docker ps -aq -f status=exited)

    if [ -z "$stopped_containers" ]; then
        print_success "No stopped containers to remove"
        return
    fi

    local count=$(echo "$stopped_containers" | wc -l)
    print_warning "Found $count stopped container(s)"

    if [ "$DRY_RUN" = true ]; then
        echo "Would remove:"
        docker ps -a -f status=exited --format "  - {{.Names}} ({{.Image}})"
    else
        docker container prune -f
        print_success "Removed $count stopped container(s)"
    fi
}

cleanup_unused_images() {
    print_header "Cleaning Unused Images"

    local dangling_images=$(docker images -f "dangling=true" -q)

    if [ -z "$dangling_images" ]; then
        print_success "No dangling images to remove"
    else
        local count=$(echo "$dangling_images" | wc -l)
        print_warning "Found $count dangling image(s)"

        if [ "$DRY_RUN" = true ]; then
            echo "Would remove:"
            docker images -f "dangling=true" --format "  - {{.Repository}}:{{.Tag}} ({{.Size}})"
        else
            docker image prune -f
            print_success "Removed $count dangling image(s)"
        fi
    fi

    # Check for unused images (not just dangling)
    local unused_images=$(docker images --filter "dangling=false" -q)
    local used_images=$(docker ps -a --format "{{.Image}}")

    if [ -n "$unused_images" ]; then
        print_warning "To remove ALL unused images (not just dangling), run with --images flag"
    fi
}

cleanup_unused_volumes() {
    print_header "Cleaning Unused Volumes"

    local unused_volumes=$(docker volume ls -qf dangling=true)

    if [ -z "$unused_volumes" ]; then
        print_success "No unused volumes to remove"
        return
    fi

    local count=$(echo "$unused_volumes" | wc -l)
    print_warning "Found $count unused volume(s)"

    if [ "$DRY_RUN" = true ]; then
        echo "Would remove:"
        docker volume ls -f dangling=true --format "  - {{.Name}}"
        print_warning "This will permanently delete volume data!"
    else
        echo -e "${RED}WARNING: This will permanently delete volume data!${NC}"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            docker volume prune -f
            print_success "Removed $count unused volume(s)"
        else
            print_warning "Volume cleanup cancelled"
        fi
    fi
}

cleanup_unused_networks() {
    print_header "Cleaning Unused Networks"

    if [ "$DRY_RUN" = true ]; then
        echo "Would remove unused networks (excluding default networks)"
    else
        docker network prune -f
        print_success "Removed unused networks"
    fi
}

full_cleanup() {
    print_warning "Performing full system cleanup..."

    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN - No changes will be made"
        docker system df
        echo ""
        echo "Would run: docker system prune -a --volumes"
    else
        echo -e "${RED}WARNING: This will remove:${NC}"
        echo "  - All stopped containers"
        echo "  - All networks not used by at least one container"
        echo "  - All images without at least one container"
        echo "  - All build cache"
        echo ""
        read -p "Continue? (yes/no): " confirm

        if [ "$confirm" = "yes" ]; then
            docker system prune -a -f
            print_success "Full cleanup complete"
        else
            print_warning "Cleanup cancelled"
        fi
    fi
}

show_usage() {
    cat << EOF
Docker Cleanup Script

Usage: $0 [OPTIONS]

Options:
    --all           Perform full cleanup (interactive confirmation)
    --containers    Clean up stopped containers only
    --images        Clean up unused images
    --volumes       Clean up unused volumes (with confirmation)
    --networks      Clean up unused networks
    --dry-run       Show what would be removed without removing
    --help          Show this help message

Examples:
    $0 --containers          # Remove stopped containers
    $0 --dry-run --all       # See what would be cleaned
    $0 --containers --images # Clean containers and images

EOF
}

main() {
    echo "============================================"
    echo "     Docker Cleanup Utility"
    echo "============================================"

    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running or not accessible"
        exit 1
    fi

    # Parse arguments
    if [ $# -eq 0 ]; then
        # Interactive mode
        show_disk_usage
        echo ""
        cleanup_stopped_containers
        cleanup_unused_images
        cleanup_unused_networks
        echo ""
        show_disk_usage
    else
        for arg in "$@"; do
            case $arg in
                --all)
                    show_disk_usage
                    full_cleanup
                    show_disk_usage
                    ;;
                --containers)
                    CLEAN_CONTAINERS=true
                    ;;
                --images)
                    CLEAN_IMAGES=true
                    ;;
                --volumes)
                    CLEAN_VOLUMES=true
                    ;;
                --networks)
                    CLEAN_NETWORKS=true
                    ;;
                --dry-run)
                    DRY_RUN=true
                    ;;
                --help)
                    show_usage
                    exit 0
                    ;;
                *)
                    print_error "Unknown option: $arg"
                    show_usage
                    exit 1
                    ;;
            esac
        done

        # Execute selected cleanups
        [ "$DRY_RUN" = true ] && print_warning "DRY RUN MODE - No changes will be made"

        show_disk_usage

        [ "$CLEAN_CONTAINERS" = true ] && cleanup_stopped_containers
        [ "$CLEAN_IMAGES" = true ] && cleanup_unused_images
        [ "$CLEAN_VOLUMES" = true ] && cleanup_unused_volumes
        [ "$CLEAN_NETWORKS" = true ] && cleanup_unused_networks

        echo ""
        show_disk_usage
    fi

    print_header "Cleanup Complete"
    echo ""
}

main "$@"
