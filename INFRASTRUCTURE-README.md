# DevOps Infrastructure Setup

This repository contains a comprehensive DevOps infrastructure setup for NestJS applications with complete CI/CD pipelines.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    DevOps Infrastructure                       │
├─────────────────────────────────────────────────────────────────┤
│  🔐 Keycloak    │  📨 RabbitMQ   │  💾 MinIO      │  📊 Monitoring│
│  (Auth & IAM)   │  (Message Bus) │  (Object Store)│  (Prometheus) │
├─────────────────────────────────────────────────────────────────┤
│  🦊 GitLab      │  🏗️ Jenkins    │  📦 Nexus      │  🗄️ PostgreSQL│
│  (Git & CI/CD)  │  (Build Server)│  (Artifacts)   │  (Database)   │
├─────────────────────────────────────────────────────────────────┤
│                      🐳 Docker Ecosystem                       │
│              Local → Development → Production                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git
- Windows (scripts provided for Windows, adaptable to Linux/Mac)

### 1. Start Local Development Environment
```bash
# Run the infrastructure manager
infrastructure-manager.bat

# Choose option 1: Local Development (All services)
```

### 2. Access Services
After startup, the following services will be available:

| Service | URL | Credentials |
|---------|-----|-------------|
| **NestJS App** | http://localhost:3000 | - |
| **Keycloak** | http://localhost:8080 | admin/dev123 |
| **RabbitMQ** | http://localhost:15672 | dev/dev123 |
| **MinIO** | http://localhost:9001 | devadmin/dev123456 |
| **GitLab** | http://localhost:8082 | root/dev123456 |
| **Jenkins** | http://localhost:8081 | admin/admin123 |
| **Nexus** | http://localhost:8083 | admin/admin123 |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3001 | admin/admin123 |

## 📁 Project Structure

```
├── infrastructure/                 # Infrastructure configurations
│   ├── keycloak/                  # Keycloak realm & client configs
│   ├── rabbitmq/                  # RabbitMQ queue definitions
│   ├── jenkins/                   # Jenkins plugins & job configs
│   ├── gitlab-runner/             # GitLab runner configurations
│   ├── prometheus/                # Monitoring configurations
│   └── grafana/                   # Dashboard configurations
├── docker-compose.*.yml           # Environment-specific compose files
├── infrastructure-manager.bat     # Management script
├── lesson1/                       # NestJS application
│   ├── .gitlab-ci.yml            # GitLab CI/CD pipeline
│   ├── Jenkinsfile.dev           # Jenkins development pipeline
│   └── .env.*                    # Environment configurations
└── README.md                     # This file
```

## 🔧 Services Configuration

### 🔐 Keycloak (Identity & Access Management)
- **Purpose**: Authentication and authorization for all services
- **Realms**: `nestjs-dev` (development), `nestjs-prod` (production)
- **Clients**: Pre-configured for NestJS app and Vue.js frontend
- **Users**: admin, developer, testuser with different roles

### 📨 RabbitMQ (Message Broker)
- **Purpose**: Asynchronous messaging and event-driven architecture
- **Exchanges**: `nestjs.events.exchange`, `nestjs.notifications.exchange`
- **Queues**: Pre-configured with TTL and dead letter queues
- **Management**: Web UI for monitoring and management

### 💾 MinIO (S3-Compatible Object Storage)
- **Purpose**: File storage, backup, and artifact storage
- **Buckets**: Auto-created for different environments
- **Integration**: Used by GitLab runners for cache storage

### 🦊 GitLab (Git Repository & CI/CD)
- **Purpose**: Source code management and CI/CD pipelines
- **Features**: Built-in Docker registry, package registry
- **Pipelines**: Multi-stage pipelines with security scanning

### 🏗️ Jenkins (Build Automation)
- **Purpose**: Alternative CI/CD solution with advanced plugin ecosystem
- **Configuration**: Configuration as Code (CasC) with Keycloak integration
- **Agents**: Docker and Kubernetes agents for scalable builds

### 📦 Nexus Repository Manager
- **Purpose**: Artifact repository for npm, Docker images, and Maven
- **Repositories**: Proxy, hosted, and group repositories
- **Integration**: Used by build pipelines for dependency management

## 🌍 Environment Configurations

### Local Development
```bash
# Start all services locally
docker-compose -f docker-compose.dev.yml -f docker-compose.infrastructure.dev.yml up -d
```

### Development Environment
```bash
# Infrastructure only for remote development
docker-compose -f docker-compose.infrastructure.dev.yml up -d
```

### Production Environment
```bash
# Production-ready configuration with security
docker-compose -f docker-compose.infrastructure.prod.yml up -d
```

## 🔄 CI/CD Pipeline

### GitLab CI Pipeline
```mermaid
graph TD
    A[Prepare] --> B[Test]
    B --> C[Build]
    C --> D[Security Scan]
    D --> E[Deploy Dev]
    E --> F[Deploy Staging]
    F --> G[Deploy Production]
```

**Stages:**
1. **Prepare**: Install dependencies and cache
2. **Test**: Unit tests, integration tests, linting
3. **Build**: Docker image creation
4. **Security**: Dependency and image vulnerability scanning
5. **Deploy**: Environment-specific deployments

### Jenkins Pipeline
- **Parallel execution** for faster builds
- **Quality gates** with SonarQube integration
- **Security scanning** with Trivy and npm audit
- **Deployment automation** with approval workflows

## 🔒 Security Features

### Authentication & Authorization
- **Keycloak integration** for all services
- **RBAC** (Role-Based Access Control)
- **SSO** (Single Sign-On) across all tools

### Container Security
- **Non-root containers** where possible
- **Security scanning** with Trivy
- **Dependency auditing** with npm audit
- **Secret management** with Docker secrets

### Network Security
- **Isolated networks** for different environments
- **TLS/SSL termination** at load balancer
- **Internal service communication** only

## 📊 Monitoring & Observability

### Metrics Collection
- **Prometheus** for metrics aggregation
- **Grafana** for visualization
- **Application metrics** from NestJS
- **Infrastructure metrics** from all services

### Health Monitoring
- **Health check endpoints** for all services
- **Automated alerts** via RabbitMQ
- **Service discovery** integration

## 🛠️ Management Scripts

### Infrastructure Manager (Windows)
```bash
infrastructure-manager.bat
```

**Features:**
- ✅ Start/stop environments
- ✅ Health checks
- ✅ Log viewing
- ✅ Backup/restore
- ✅ Cleanup operations

### Common Operations

#### Start Development Environment
```bash
docker-compose -f docker-compose.dev.yml -f docker-compose.infrastructure.dev.yml up -d
```

#### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nestjs-app
```

#### Health Check
```bash
# NestJS App
curl http://localhost:3000/health

# RabbitMQ
curl http://localhost:15672/api/overview -u dev:dev123
```

#### Backup Data
```bash
# PostgreSQL
docker exec postgres pg_dump -U postgres nestjs_db > backup/db_$(date +%Y%m%d).sql

# GitLab data
docker run --rm -v gitlab_data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/gitlab_$(date +%Y%m%d).tar.gz -C /data .
```

## 🔧 Configuration

### Environment Variables

#### Development (.env.development)
```bash
# Database
DATABASE_URL=postgresql://postgres:password@postgres:5432/nestjs_db

# Keycloak
KEYCLOAK_URL=http://keycloak:8080
KEYCLOAK_REALM=nestjs-dev

# RabbitMQ
RABBITMQ_URL=amqp://dev:dev123@rabbitmq:5672/dev

# MinIO
MINIO_ENDPOINT=minio
MINIO_ACCESS_KEY=devadmin
```

#### Production (.env.production)
```bash
# Database
DATABASE_URL=postgresql://${DB_USERNAME}:${DB_PASSWORD}@postgres:5432/${DB_NAME}

# Keycloak
KEYCLOAK_URL=https://${KC_HOSTNAME}
KEYCLOAK_REALM=${KC_REALM}

# RabbitMQ (with SSL)
RABBITMQ_URL=amqps://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5671/${RABBITMQ_VHOST}
```

### Service-Specific Configuration

#### Keycloak Realm Import
- Development realm: `infrastructure/keycloak/dev-realm.json`
- Production realm: `infrastructure/keycloak/prod-realm.json`

#### RabbitMQ Definitions
- Queue definitions: `infrastructure/rabbitmq/definitions.json`
- Configuration: `infrastructure/rabbitmq/dev.conf` / `prod.conf`

#### Jenkins Configuration as Code
- Development: `infrastructure/jenkins/dev-casc.yaml`
- Production: `infrastructure/jenkins/prod-casc.yaml`

## 🚨 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check logs
docker-compose logs service-name

# Check disk space
docker system df

# Clean up if needed
docker system prune -f
```

#### Permission Issues
```bash
# Fix file permissions
sudo chown -R $(id -u):$(id -g) ./data

# For Jenkins
sudo chown -R 1000:1000 ./jenkins_home
```

#### Network Issues
```bash
# Recreate networks
docker-compose down
docker network prune -f
docker-compose up -d
```

### Health Check Commands
```bash
# Check all container status
docker ps

# Check service health
docker-compose ps

# Test network connectivity
docker exec nestjs-app ping postgres
```

## 📈 Scaling & Production Deployment

### Horizontal Scaling
- **GitLab Runners**: Add more runner instances
- **Jenkins Agents**: Kubernetes-based auto-scaling
- **Database**: Read replicas for PostgreSQL
- **Message Queue**: RabbitMQ clustering

### Production Considerations
- **SSL/TLS certificates** for all services
- **External databases** (managed PostgreSQL)
- **Load balancers** (Nginx, HAProxy, or cloud LB)
- **Monitoring & alerting** (PagerDuty, Slack integration)
- **Backup strategies** (automated, tested restores)

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Create** a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline comments
- **Issues**: Create GitHub issues for bugs
- **Discussions**: Use GitHub Discussions for questions

---

## 🎯 Next Steps

1. **Clone** this repository
2. **Run** `infrastructure-manager.bat`
3. **Choose** option 1 for local development
4. **Wait** for all services to start (5-10 minutes)
5. **Access** the services using the URLs above
6. **Start developing** your NestJS application!

Happy coding! 🚀
