# DevOps Infrastructure Setup & Usage Guide

## 🚀 Overview

This project provides a complete DevOps infrastructure setup using Docker Compose, featuring:
- **Authentication**: Keycloak
- **Source Control**: GitLab 
- **CI/CD**: Jenkins
- **Artifact Repository**: Nexus
- **Object Storage**: MinIO
- **Message Queue**: RabbitMQ
- **Monitoring**: Prometheus + Grafana
- **Reverse Proxy**: Nginx

## 📋 Prerequisites

### System Requirements
- **OS**: Windows 10/11, macOS, or Linux
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 50GB free space minimum
- **Docker**: Docker Desktop 4.0+ or Docker Engine 20.10+
- **Docker Compose**: v2.0+

### Software Dependencies
- **Docker Desktop**: [Download here](https://www.docker.com/products/docker-desktop/)
- **Git** (optional): For version control
- **Text Editor**: VS Code, Notepad++, or any editor

## 🛠️ Installation & Setup

### Step 1: Clone or Download Project
```bash
# If using Git
git clone <your-repository-url>
cd lesson1_nest_js

# Or download and extract the ZIP file
```

### Step 2: Verify Docker Installation
```bash
# Check Docker is running
docker --version
docker-compose --version

# Test Docker
docker run hello-world
```

### Step 3: Project Structure Overview
```
lesson1_nest_js/
├── docker-compose.infrastructure.dev.yml     # Main infrastructure setup
├── docker-compose.infrastructure.lightweight.yml  # Lightweight version
├── deploy-infrastructure.bat                 # Deployment script
├── resource-monitor.bat                      # Resource monitoring
├── grafana-dev-tester.bat                   # Grafana testing
└── infrastructure/
    ├── nginx/                               # Reverse proxy config
    │   ├── dev-nginx.conf                   # Development config
    │   ├── prod-nginx.conf                  # Production config
    │   ├── conf.d/                          # Service configurations
    │   ├── ssl/                             # SSL certificates
    │   ├── generate-ssl.bat                 # SSL generation script
    │   └── generate-ssl-simple.bat          # Docker-based SSL generation
    ├── grafana/                             # Grafana configuration
    └── HOSTING_GUIDE.md                     # Hosting deployment guide
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Run the deployment script
deploy-infrastructure.bat

# Choose option 1: Local Development (with Nginx)
```

### Option 2: Manual Setup
```bash
# Start all services with Nginx reverse proxy
docker-compose -f docker-compose.infrastructure.dev.yml up -d

# Or start lightweight version (direct ports)
docker-compose -f docker-compose.infrastructure.lightweight.yml up -d
```

## 🌐 Access URLs

### Main Dashboard
- **HTTP**: `http://localhost`
- **HTTPS**: `https://localhost` (self-signed certificate)
- **Management**: `http://localhost:8090`

### Direct Service Access
| Service | URL | Default Credentials |
|---------|-----|-------------------|
| **Keycloak** | `http://localhost:8080` | admin / dev123 |
| **GitLab** | `http://localhost:8082` | root / password123 |
| **Jenkins** | `http://localhost:8081` | admin / admin123 |
| **Nexus** | `http://localhost:8083` | admin / admin123 |
| **MinIO** | `http://localhost:9001` | minioadmin / minioadmin |
| **RabbitMQ** | `http://localhost:15672` | guest / guest |
| **Prometheus** | `http://localhost:9090` | No auth required |
| **Grafana** | `http://localhost:3001` | admin / admin |

### Reverse Proxy Access (requires hosts file setup)
| Service | Proxy URL |
|---------|-----------|
| **Keycloak** | `http://auth.local` |
| **GitLab** | `http://git.local` |
| **Jenkins** | `http://ci.local` |
| **Nexus** | `http://nexus.local` |
| **MinIO** | `http://storage.local` |
| **RabbitMQ** | `http://rabbit.local` |
| **Prometheus** | `http://prometheus.local` |
| **Grafana** | `http://grafana.local` |

## 🔧 Configuration

### Hosts File Setup (For .local domains)
Add these entries to your hosts file:

**Windows**: `C:\Windows\System32\drivers\etc\hosts`
**macOS/Linux**: `/etc/hosts`

```
# DevOps Infrastructure Development
127.0.0.1 auth.local keycloak.local
127.0.0.1 git.local gitlab.local
127.0.0.1 ci.local jenkins.local
127.0.0.1 nexus.local artifacts.local
127.0.0.1 storage.local minio.local
127.0.0.1 rabbit.local rabbitmq.local
127.0.0.1 prometheus.local metrics.local
127.0.0.1 grafana.local dashboards.local
```

### SSL Certificates
```bash
# Generate SSL certificates (if not using deployment script)
cd infrastructure/nginx

# If OpenSSL is installed
generate-ssl.bat

# If only Docker is available
generate-ssl-simple.bat
```

## 📊 Monitoring & Management

### Resource Monitoring
```bash
# Run resource monitor
resource-monitor.bat

# Options available:
# 1. Real-time monitoring
# 2. Resource usage report
# 3. Cleanup unused resources
# 4. Service health check
```

### Grafana Testing
```bash
# Test Grafana connectivity
grafana-dev-tester.bat

# Includes:
# - Service status check
# - Datasource connectivity test
# - Dashboard verification
```

### Service Management
```bash
# Check service status
docker-compose -f docker-compose.infrastructure.dev.yml ps

# View logs
docker-compose -f docker-compose.infrastructure.dev.yml logs [service_name]

# Restart specific service
docker-compose -f docker-compose.infrastructure.dev.yml restart [service_name]

# Stop all services
docker-compose -f docker-compose.infrastructure.dev.yml stop

# Remove all services and data
docker-compose -f docker-compose.infrastructure.dev.yml down -v
```

## 🎯 Usage Scenarios

### Development Environment
1. **Start Services**: Use deployment script option 1
2. **Access Dashboard**: Go to `http://localhost`
3. **Configure Services**: Use default credentials to log in
4. **Monitor Resources**: Use resource monitor script
5. **View Logs**: Use Grafana dashboards

### CI/CD Pipeline Setup
1. **GitLab**: Create repositories and configure CI/CD
2. **Jenkins**: Set up build jobs and pipelines
3. **Nexus**: Configure artifact repositories
4. **Keycloak**: Set up authentication for services

### Monitoring Setup
1. **Prometheus**: Configure metrics collection
2. **Grafana**: Create custom dashboards
3. **Alerts**: Set up alerting rules

## 🔒 Security Notes

### Development Environment
- **SSL Certificates**: Self-signed (browser warnings normal)
- **Default Passwords**: Change in production
- **Network**: Services exposed on localhost only
- **Data**: Stored in Docker volumes

### Production Considerations
- Use proper SSL certificates (Let's Encrypt, CA-signed)
- Change all default passwords
- Configure proper firewall rules
- Set up backup strategies
- Use secrets management

## 🧹 Maintenance

### Regular Tasks
```bash
# Update Docker images
docker-compose -f docker-compose.infrastructure.dev.yml pull
docker-compose -f docker-compose.infrastructure.dev.yml up -d

# Clean up unused resources
docker system prune -f
docker volume prune -f

# Backup data volumes
docker run --rm -v lesson1_nest_js_grafana_data:/data -v $(pwd):/backup alpine tar czf /backup/grafana-backup.tar.gz /data
```

### Troubleshooting
```bash
# Check service health
deploy-infrastructure.bat → Option 7

# View specific service logs
docker logs [container_name] --tail 50

# Test network connectivity
docker exec nginx-dev ping grafana

# Restart problematic services
docker restart [container_name]
```

## 📈 Performance Optimization

### Resource Limits
Edit `docker-compose.infrastructure.dev.yml` to adjust:
```yaml
services:
  service_name:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### Storage Optimization
```bash
# Monitor disk usage
docker system df

# Clean old images
docker image prune -a

# Backup and restore volumes as needed
```

## 🌍 Deployment Options

### Local Development
- Use provided Docker Compose files
- Access via localhost
- Self-signed SSL certificates

### Cloud Deployment
- See `infrastructure/HOSTING_GUIDE.md`
- Configure domain DNS
- Use proper SSL certificates
- Set up monitoring and backups

### Production Scaling
- Use Docker Swarm or Kubernetes
- Implement load balancing
- Set up high availability
- Configure auto-scaling

## 🆘 Common Issues & Solutions

### Issue: Services won't start
```bash
# Check Docker resources
docker system df

# Free up space
docker system prune -a

# Restart Docker Desktop
```

### Issue: Bad Gateway errors
```bash
# Check service connectivity
docker-compose -f docker-compose.infrastructure.dev.yml ps

# Restart nginx
docker restart nginx-dev
```

### Issue: SSL certificate warnings
- **Normal for development**: Accept browser warnings
- **For production**: Use proper certificates
- **Alternative**: Use HTTP versions (port access)

### Issue: Port conflicts
```bash
# Check what's using ports
netstat -an | findstr :8080

# Stop conflicting services or change ports in docker-compose.yml
```

## 📞 Support & Documentation

### Resources
- **Main Dashboard**: `http://localhost` - Service overview
- **Grafana Monitoring**: `http://localhost:3001` - System metrics
- **Hosting Guide**: `infrastructure/HOSTING_GUIDE.md` - Production deployment
- **Resource Monitor**: `resource-monitor.bat` - System health

### Logs Location
- **Application Logs**: `docker logs [container_name]`
- **Nginx Logs**: `infrastructure/nginx/logs/`
- **Service Data**: Docker volumes (use `docker volume ls`)

## 🔄 Update & Maintenance Schedule

### Weekly
- Check resource usage
- Review service logs
- Update Docker images if needed

### Monthly
- Backup important data
- Review security settings
- Clean unused Docker resources

### Quarterly
- Update Docker Desktop
- Review and update configurations
- Performance optimization review

---

## 🎉 Congratulations!

Your DevOps infrastructure is now ready! 

**Next Steps:**
1. Start services: `deploy-infrastructure.bat`
2. Open dashboard: `http://localhost`
3. Configure your first project
4. Set up monitoring dashboards
5. Begin your development workflow

**Happy coding!** 🚀
