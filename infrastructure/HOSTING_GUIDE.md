# DevOps Infrastructure Hosting Deployment Guide

## Overview
This guide covers deploying your DevOps infrastructure in various hosting scenarios, from local development to cloud production environments.

## 🏠 Local Development Hosting

### Quick Start
```bash
# 1. Generate SSL certificates
cd infrastructure/nginx
generate-ssl.bat

# 2. Start infrastructure services
docker-compose -f docker-compose.infrastructure.dev.yml up -d

# 3. Access via Nginx reverse proxy
# HTTP: http://localhost (port 80)
# HTTPS: https://localhost (port 443)
# Management: http://localhost:8090
```

### Hosts File Configuration
Add to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 auth.local keycloak.local
127.0.0.1 git.local gitlab.local  
127.0.0.1 ci.local jenkins.local
127.0.0.1 nexus.local artifacts.local
127.0.0.1 storage.local minio.local
127.0.0.1 rabbit.local rabbitmq.local
127.0.0.1 prometheus.local metrics.local
127.0.0.1 grafana.local dashboards.local
```

## ☁️ Cloudflare Hosting

### Prerequisites
- Domain registered with Cloudflare DNS
- Server with Docker and Docker Compose
- Ports 80, 443 open on server

### Step 1: Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Step 2: Cloudflare Configuration
1. **DNS Records** (in Cloudflare Dashboard):
   ```
   Type  Name                Value           Proxied
   A     auth.yourdomain.com YOUR_SERVER_IP   Yes
   A     git.yourdomain.com  YOUR_SERVER_IP   Yes
   A     ci.yourdomain.com   YOUR_SERVER_IP   Yes
   A     nexus.yourdomain.com YOUR_SERVER_IP  Yes
   A     storage.yourdomain.com YOUR_SERVER_IP Yes
   A     monitoring.yourdomain.com YOUR_SERVER_IP Yes
   ```

2. **SSL Settings**:
   - SSL/TLS mode: "Full (strict)" or "Full"
   - Edge Certificates: Enable "Always Use HTTPS"
   - Origin Server: Create origin certificate

### Step 3: Production Docker Compose
Create `docker-compose.cloudflare.yml`:
```yaml
version: '3.8'

networks:
  devops_network:
    driver: bridge

volumes:
  postgres_data:
  keycloak_data:
  gitlab_data:
  jenkins_data:
  nexus_data:
  minio_data:
  rabbitmq_data:
  prometheus_data:
  grafana_data:

services:
  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infrastructure/nginx/prod-nginx.conf:/etc/nginx/nginx.conf
      - ./infrastructure/nginx/conf.d:/etc/nginx/conf.d
      - ./infrastructure/nginx/ssl:/etc/nginx/ssl
      - ./infrastructure/nginx/logs:/var/log/nginx
    networks:
      - devops_network
    restart: unless-stopped
    depends_on:
      - keycloak
      - gitlab
      - jenkins
      - nexus
      - minio
      - rabbitmq
      - prometheus
      - grafana

  # ... (include all other services from infrastructure.dev.yml)
  # with production-optimized settings
```

### Step 4: Nginx Production Configuration
Update nginx configuration for production domains:
```nginx
# Replace localhost/local domains with your production domains
server_name auth.yourdomain.com;
server_name git.yourdomain.com;
# etc.
```

### Step 5: SSL Certificate Setup
```bash
# Option 1: Use Cloudflare Origin Certificate
# Download from Cloudflare Dashboard → SSL/TLS → Origin Server

# Option 2: Use Let's Encrypt with Certbot
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d auth.yourdomain.com -d git.yourdomain.com
```

## 🖥️ Self-Hosted Server

### Hardware Requirements
- **Minimum**: 8GB RAM, 4 CPU cores, 100GB storage
- **Recommended**: 16GB RAM, 8 CPU cores, 250GB SSD
- **Production**: 32GB RAM, 16 CPU cores, 500GB SSD

### Network Setup
1. **Router Configuration**:
   - Port forwarding: 80 → server:80, 443 → server:443
   - Static IP for server
   - DMZ (optional for dedicated server)

2. **Firewall Rules**:
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp  # SSH
   sudo ufw enable
   ```

3. **Dynamic DNS** (if no static IP):
   - Use DuckDNS, No-IP, or similar
   - Set up automatic IP updates

### Domain Configuration
1. **Purchase Domain**: From any registrar (Namecheap, GoDaddy, etc.)
2. **DNS Settings**:
   ```
   Type  Name                Value           TTL
   A     auth.yourdomain.com YOUR_PUBLIC_IP  3600
   A     git.yourdomain.com  YOUR_PUBLIC_IP  3600
   A     ci.yourdomain.com   YOUR_PUBLIC_IP  3600
   A     @                   YOUR_PUBLIC_IP  3600
   ```

### SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Generate certificates
sudo certbot certonly --standalone \
  -d auth.yourdomain.com \
  -d git.yourdomain.com \
  -d ci.yourdomain.com \
  -d nexus.yourdomain.com \
  -d storage.yourdomain.com \
  -d monitoring.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Production Optimizations

### Security Hardening
1. **Firewall**: Only allow necessary ports
2. **SSH**: Key-based authentication only
3. **Updates**: Automatic security updates
4. **Monitoring**: Failed login attempts
5. **Backup**: Regular automated backups

### Performance Tuning
```yaml
# Production Docker Compose additions
services:
  nginx:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    
  postgres:
    environment:
      - POSTGRES_SHARED_BUFFERS=256MB
      - POSTGRES_EFFECTIVE_CACHE_SIZE=1GB
```

### Monitoring Setup
```bash
# Enable comprehensive monitoring
# Resource monitoring
./resource-monitor.bat

# Log monitoring
docker logs --follow nginx-proxy

# Health checks
curl -f http://localhost/health || exit 1
```

## 📊 Resource Requirements by Environment

### Development (Local)
- **RAM**: 8-12GB
- **CPU**: 4 cores
- **Storage**: 50GB
- **Network**: Local only

### Staging (Cloud)
- **RAM**: 16GB
- **CPU**: 8 cores  
- **Storage**: 100GB SSD
- **Network**: Limited access

### Production (Cloud/Self-hosted)
- **RAM**: 32GB+
- **CPU**: 16+ cores
- **Storage**: 250GB+ SSD
- **Network**: High availability

## 🚀 Deployment Commands

### Local Development
```bash
# Start all services
docker-compose -f docker-compose.infrastructure.dev.yml up -d

# Scale specific services
docker-compose -f docker-compose.infrastructure.dev.yml up -d --scale jenkins=2

# Update services
docker-compose -f docker-compose.infrastructure.dev.yml pull
docker-compose -f docker-compose.infrastructure.dev.yml up -d
```

### Production Deployment
```bash
# Initial deployment
docker-compose -f docker-compose.cloudflare.yml up -d

# Zero-downtime updates
docker-compose -f docker-compose.cloudflare.yml pull
docker-compose -f docker-compose.cloudflare.yml up -d --no-deps service_name

# Health verification
./scripts/health-check.sh
```

## 🔍 Troubleshooting

### Common Issues
1. **SSL Certificate Errors**: Check certificate validity and nginx configuration
2. **Service Connectivity**: Verify network configuration and firewall rules
3. **Resource Constraints**: Monitor with `./resource-monitor.bat`
4. **DNS Resolution**: Check domain configuration and propagation

### Debugging Commands
```bash
# Check service status
docker-compose -f docker-compose.infrastructure.dev.yml ps

# View logs
docker-compose -f docker-compose.infrastructure.dev.yml logs service_name

# Network debugging
docker network ls
docker network inspect devops_network

# Resource usage
docker stats

# Nginx configuration test
docker exec nginx-proxy nginx -t
```

## 📋 Checklist

### Pre-deployment
- [ ] Hardware/VPS requirements met
- [ ] Domain configured
- [ ] SSL certificates ready
- [ ] Firewall configured
- [ ] Docker installed
- [ ] Configuration files updated

### Post-deployment
- [ ] All services healthy
- [ ] SSL certificates valid
- [ ] Monitoring active
- [ ] Backups configured
- [ ] Performance optimized
- [ ] Security hardened

## 🆘 Support

### Documentation
- Docker: https://docs.docker.com/
- Nginx: https://nginx.org/en/docs/
- Cloudflare: https://developers.cloudflare.com/

### Monitoring Dashboards
- **Local**: http://localhost:3001 (Grafana)
- **Production**: https://monitoring.yourdomain.com

This guide provides comprehensive hosting options from development to production. Choose the approach that best fits your requirements and infrastructure.
