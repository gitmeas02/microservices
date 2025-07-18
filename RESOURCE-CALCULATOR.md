# 📊 DEVELOPMENT ENVIRONMENT RESOURCE CALCULATOR

## 🔧 INFRASTRUCTURE SERVICES RESOURCE REQUIREMENTS

### **Core Infrastructure Services**

| Service | CPU (Cores) | RAM (MB) | Storage (GB) | Startup Time |
|---------|-------------|----------|--------------|--------------|
| 🛡️ **Keycloak** | 0.5-1.0 | 512-1024 | 2-5 | 30-60s |
| 🗄️ **Keycloak DB** | 0.2-0.5 | 128-256 | 1-3 | 10-20s |
| 🐰 **RabbitMQ** | 0.2-0.5 | 256-512 | 1-2 | 15-30s |
| 💾 **MinIO** | 0.2-0.5 | 128-256 | 5-20 | 10-20s |
| 📦 **Nexus** | 0.5-1.0 | 1024-2048 | 5-15 | 60-120s |

### **Heavy Infrastructure Services**

| Service | CPU (Cores) | RAM (MB) | Storage (GB) | Startup Time |
|---------|-------------|----------|--------------|--------------|
| 🦊 **GitLab** | 1.0-2.0 | 2048-4096 | 10-30 | 300-600s |
| 🏗️ **Jenkins** | 0.5-1.0 | 512-1024 | 3-10 | 60-120s |

### **Monitoring Services**

| Service | CPU (Cores) | RAM (MB) | Storage (GB) | Startup Time |
|---------|-------------|----------|--------------|--------------|
| 📈 **Prometheus** | 0.2-0.5 | 256-512 | 2-10 | 20-30s |
| 📊 **Grafana** | 0.2-0.5 | 128-256 | 1-3 | 30-60s |

## 🚀 APPLICATION SERVICES RESOURCE REQUIREMENTS

| Service | CPU (Cores) | RAM (MB) | Storage (GB) | Startup Time |
|---------|-------------|----------|--------------|--------------|
| 🚀 **NestJS App** | 0.3-0.8 | 256-512 | 0.5-2 | 15-30s |
| 🗄️ **PostgreSQL** | 0.2-0.5 | 256-512 | 2-10 | 10-20s |
| ⚡ **Redis** | 0.1-0.3 | 64-128 | 0.5-2 | 5-10s |

## 📊 TOTAL RESOURCE CALCULATIONS

### **Scenario 1: LITE Infrastructure Only**
```
Services: Keycloak + DB + RabbitMQ + MinIO + Nexus + Prometheus + Grafana

CPU: 2.3-4.5 cores
RAM: 2,816-5,888 MB (2.8-5.9 GB)
Storage: 17-58 GB
Startup Time: 4-7 minutes
```

### **Scenario 2: FULL Development Infrastructure**
```
Services: All Lite + GitLab + Jenkins

CPU: 3.8-7.5 cores  
RAM: 5,376-11,008 MB (5.4-11 GB)
Storage: 30-98 GB
Startup Time: 8-15 minutes
```

### **Scenario 3: Application Only**
```
Services: NestJS + PostgreSQL + Redis

CPU: 0.6-1.6 cores
RAM: 576-1,152 MB (0.6-1.2 GB) 
Storage: 3-14 GB
Startup Time: 1-2 minutes
```

### **Scenario 4: FULL DEV (Infrastructure + Application)**
```
Services: All Infrastructure + All Application

CPU: 4.4-9.1 cores
RAM: 5,952-12,160 MB (6-12.2 GB)
Storage: 33-112 GB  
Startup Time: 9-17 minutes
```

## 💻 MINIMUM SYSTEM REQUIREMENTS

### **For Lite Development**
- **CPU:** Intel i5 4-core / AMD Ryzen 5 4-core minimum
- **RAM:** 8 GB minimum, 16 GB recommended
- **Storage:** 60 GB free space (SSD recommended)
- **Network:** High-speed internet for image downloads

### **For Full Development** 
- **CPU:** Intel i7 6-core / AMD Ryzen 7 6-core minimum
- **RAM:** 16 GB minimum, 32 GB recommended  
- **Storage:** 120 GB free space (SSD highly recommended)
- **Network:** High-speed internet for image downloads

## ⚡ PERFORMANCE OPTIMIZATION TIPS

### **Memory Optimization**
```yaml
# Reduce GitLab memory usage
postgresql['shared_buffers'] = "64MB"
sidekiq['max_concurrency'] = 10

# Reduce Nexus memory usage  
INSTALL4J_ADD_VM_PARAMS: "-Xms512m -Xmx1024m"

# Reduce Jenkins memory usage
JAVA_OPTS: "-Xmx512m -XX:MaxPermSize=256m"
```

### **CPU Optimization**
```yaml
# Limit container CPU usage
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1024M
```

### **Storage Optimization**
- Use **SSD storage** for better I/O performance
- Mount **data volumes** on separate drives if possible
- Enable **Docker BuildKit** for faster builds
- Use **image layers caching** to reduce download time

## 🚨 RESOURCE MONITORING COMMANDS

### **Check Docker Resource Usage**
```cmd
# Overall system usage
docker stats

# Specific containers
docker stats keycloak-dev gitlab-dev jenkins-dev

# Memory usage by container
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Disk usage
docker system df -v
```

### **System Resource Check**
```cmd
# Windows Task Manager equivalent
wmic cpu get loadpercentage /value
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value

# PowerShell memory check
powershell "Get-WmiObject -Class Win32_ComputerSystem | Select TotalPhysicalMemory"
```

## 📈 SCALING RECOMMENDATIONS

### **Development Team Size vs Resources**

| Team Size | Recommended Setup | CPU | RAM | Storage |
|-----------|-------------------|-----|-----|---------|
| 1-2 devs | Lite + App | 4-6 cores | 8-12 GB | 60-80 GB |
| 3-5 devs | Full Dev | 6-8 cores | 16-24 GB | 100-150 GB |
| 5+ devs | Full + Load Balancer | 8+ cores | 32+ GB | 200+ GB |

### **Environment-Specific Scaling**

| Environment | Purpose | Resource Multiplier |
|-------------|---------|-------------------|
| **Development** | Coding, testing | 1x (base) |
| **Staging** | Pre-production testing | 1.5x |
| **Production** | Live environment | 3-5x |

## 🎯 COST ESTIMATION (Cloud Deployment)

### **AWS EC2 Instance Recommendations**

| Scenario | Instance Type | vCPU | RAM | Cost/Month* |
|----------|---------------|------|-----|-------------|
| Lite Dev | t3.large | 2 | 8 GB | ~$60 |
| Full Dev | t3.xlarge | 4 | 16 GB | ~$120 |
| Production | m5.2xlarge | 8 | 32 GB | ~$280 |

*Estimated costs in US East region, may vary

### **Local Development Cost**
- **One-time setup:** Free (using local machine)
- **Power consumption:** ~$10-20/month additional electricity
- **Hardware upgrade:** $500-2000 (if needed)

## 🛠️ TROUBLESHOOTING RESOURCE ISSUES

### **High CPU Usage**
```cmd
# Identify heavy containers
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}" | sort -k2 -nr

# Restart heavy services
docker restart gitlab-dev jenkins-dev
```

### **High Memory Usage**
```cmd
# Check memory by container
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" | sort -k2 -nr

# Clean up unused resources
docker system prune -a --volumes
```

### **Disk Space Issues**
```cmd
# Check Docker disk usage
docker system df

# Clean up old images
docker image prune -a

# Remove unused volumes
docker volume prune
```

## ⚙️ AUTOMATED RESOURCE MANAGEMENT

### **Auto-cleanup Script**
```cmd
# Weekly cleanup (add to Task Scheduler)
docker system prune -f
docker volume prune -f
docker image prune -a -f
```

### **Resource Monitoring Alerts**
- Set up Grafana alerts for CPU > 80%
- Monitor disk usage < 10% free space
- Alert on container restart loops
- Memory usage > 90% for 5 minutes

---

## 📋 QUICK REFERENCE CARD

| **Service** | **CPU** | **RAM** | **Disk** | **Port** |
|-------------|---------|---------|----------|----------|
| Keycloak | 0.5 | 512MB | 2GB | 8080 |
| RabbitMQ | 0.3 | 256MB | 1GB | 15672 |
| GitLab | 2.0 | 4GB | 20GB | 8082 |
| Jenkins | 1.0 | 1GB | 5GB | 8081 |
| NestJS | 0.5 | 256MB | 1GB | 3000 |

**Total Recommended:** 8 cores, 16GB RAM, 100GB disk space
