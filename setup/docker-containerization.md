# Docker and Container Management

## Overview
Configured Docker and containerd for container orchestration and application deployment. Implemented monitoring, security best practices, and automated container management for a production-grade containerization platform.

## Services Configured
- **Docker Engine** - Container runtime and management
- **containerd** - Low-level container runtime
- **cAdvisor** - Container resource monitoring and performance analysis

## Installation and Setup

### Base Installation
```bash
# Install Docker and containerd
sudo pacman -S docker containerd

# Enable Docker service
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

# Add user to docker group (optional, for rootless operation)
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker run hello-world
```

## Current Container Deployments

### cAdvisor - Container Monitoring
```bash
docker run -d \
  --name=cadvisor \
  --restart=always \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest
```

**Purpose**: Provides container-level resource usage and performance metrics
**Integration**: Scraped by Prometheus for monitoring dashboard

### Navidrome - Music Streaming Server
```bash
docker run -d \
  --name=navidrome \
  --restart=always \
  --volume=/path/to/music:/music:ro \
  --volume=/path/to/data:/data \
  --publish=4533:4533 \
  --env ND_LOGLEVEL=info \
  deluan/navidrome:latest
```

**Purpose**: Self-hosted music streaming service
**Features**: Subsonic API compatible, web-based interface

## Docker Management Commands

### Container Operations
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs <container_name>
docker logs -f <container_name>  # Follow mode

# Inspect container details
docker inspect <container_name>

# Execute command in running container
docker exec -it <container_name> /bin/bash

# Stop/Start containers
docker stop <container_name>
docker start <container_name>
docker restart <container_name>

# Remove containers
docker rm <container_name>
docker rm -f <container_name>  # Force remove
```

### Image Management
```bash
# List images
docker images

# Pull image from registry
docker pull <image_name>:<tag>

# Remove unused images
docker image prune

# Remove specific image
docker rmi <image_name>

# Build custom image
docker build -t <name>:<tag> .
```

### System Maintenance
```bash
# View Docker disk usage
docker system df

# Clean up unused resources
docker system prune

# Clean up everything (use with caution)
docker system prune -a --volumes

# View real-time container stats
docker stats

# Check Docker version and info
docker version
docker info
```

## Docker Compose Setup

### Example docker-compose.yml Structure
```yaml
version: '3.8'

services:
  app:
    image: app:latest
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - ./data:/data
    environment:
      - ENV_VAR=value
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  app-network:
    driver: bridge

volumes:
  data:
    driver: local
```

## Container Security Best Practices

### Implemented Security Measures

1. **Non-Root Containers**
   - Run containers with least privilege
   - Use USER directive in Dockerfiles
   - Avoid privileged mode unless necessary

2. **Resource Limits**
   ```bash
   docker run -d \
     --memory="512m" \
     --cpus="1.0" \
     --pids-limit=100 \
     <image_name>
   ```

3. **Network Isolation**
   - Use custom networks
   - Expose only necessary ports
   - Implement proper firewall rules

4. **Image Security**
   - Use official images from trusted registries
   - Regularly update images
   - Scan images for vulnerabilities
   ```bash
   # Example with Trivy (if installed)
   trivy image <image_name>
   ```

5. **Secrets Management**
   - Use Docker secrets or environment files
   - Never commit secrets to version control
   - Use secret management tools (Vault, etc.)

## Monitoring Integration

### Prometheus Metrics
cAdvisor exposes metrics on port 8080 that are scraped by Prometheus:
- Container CPU usage
- Memory consumption
- Network I/O
- Filesystem usage
- Container lifecycle events

### Grafana Dashboards
Created dashboards showing:
- Resource usage per container
- Container health status
- Performance trends
- Anomaly detection

## Backup and Recovery

### Container Data Backup
```bash
# Backup container volumes
docker run --rm \
  --volumes-from <container_name> \
  -v $(pwd):/backup \
  alpine tar czf /backup/container-backup.tar.gz /data

# Restore from backup
docker run --rm \
  --volumes-from <container_name> \
  -v $(pwd):/backup \
  alpine tar xzf /backup/container-backup.tar.gz -C /
```

### Image Backup
```bash
# Save image to tar file
docker save -o image-backup.tar <image_name>:<tag>

# Load image from tar file
docker load -i image-backup.tar
```

## Troubleshooting

### Common Issues and Solutions

```bash
# Check Docker daemon status
systemctl status docker

# View Docker daemon logs
journalctl -u docker -f

# Inspect container logs
docker logs --tail 100 <container_name>

# Check container resource usage
docker stats <container_name>

# Network troubleshooting
docker network ls
docker network inspect <network_name>

# Debug container startup issues
docker events --filter 'container=<container_name>'

# Check if containers can reach each other
docker exec <container1> ping <container2>
```

### Performance Issues
```bash
# Check system resource usage
docker system df

# Identify resource-heavy containers
docker stats --no-stream | sort -k4 -h

# Analyze container logs for errors
docker logs <container_name> 2>&1 | grep -i error
```

## Skills Demonstrated
- Container orchestration and management
- Docker and containerd administration
- Resource monitoring and optimization
- Security hardening of containerized applications
- Backup and disaster recovery strategies
- Troubleshooting and debugging containerized services
- Integration with monitoring infrastructure
- Infrastructure automation

## Use Cases
- Microservices deployment
- Development environment consistency
- Application isolation and security
- Rapid deployment and scaling
- Testing and CI/CD pipelines
- Resource optimization

## Professional Value
This configuration demonstrates:
- Modern DevOps practices
- Container security awareness
- Monitoring and observability implementation
- System administration skills
- Problem-solving capabilities
- Infrastructure as Code principles

## Advanced Topics

### Container Networking
- Bridge networks for container isolation
- Custom networks for multi-container applications
- Port mapping and exposure strategies
- Network security and segmentation

### Storage Management
- Volume types (named, bind mounts, tmpfs)
- Data persistence strategies
- Volume backup and migration
- Storage drivers and optimization

### Orchestration Considerations
Future path to Kubernetes:
- Understanding of container concepts
- Service discovery and networking
- Resource management
- Health checks and self-healing

## Maintenance Schedule

### Daily
- Monitor container health via Grafana
- Check for unusual resource usage
- Review container logs for errors

### Weekly
- Update running containers with latest images
- Clean up unused images and volumes
- Review security scan results

### Monthly
- Full backup of critical container data
- Review and optimize resource allocations
- Update Docker and containerd

## References
- [Docker Documentation](https://docs.docker.com/)
- [containerd Documentation](https://containerd.io/docs/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [cAdvisor GitHub](https://github.com/google/cadvisor)
