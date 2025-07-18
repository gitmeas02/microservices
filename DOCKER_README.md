# NestJS Docker Production Setup

This repository contains a production-ready Docker setup for a NestJS application with PostgreSQL, Redis, and Nginx.

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │    │   NestJS    │    │ PostgreSQL  │
│ (Port 80)   │───▶│ (Port 3000) │───▶│ (Port 5432) │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                           ▼
                   ┌─────────────┐
                   │    Redis    │
                   │ (Port 6379) │
                   └─────────────┘
```

## 📋 Prerequisites

- Docker Desktop 4.0+
- Docker Compose 2.0+
- Node.js 18+ (for local development)

## 🚀 Quick Start

### Production Deployment

1. **Clone and configure:**
   ```bash
   git clone <repository-url>
   cd lesson1_nest_js
   ```

2. **Set up environment variables:**
   ```bash
   cp lesson1/.env.production.example lesson1/.env.production
   # Edit the .env.production file with your production values
   ```

3. **Deploy using the script:**
   ```bash
   # On Windows
   deploy.bat
   
   # On Linux/macOS
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. **Or deploy manually:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

### Development Setup

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f nestjs-app
```

## 📁 Project Structure

```
├── docker-compose.yml          # Main compose file
├── docker-compose.prod.yml     # Production optimized
├── docker-compose.dev.yml      # Development setup
├── deploy.sh / deploy.bat      # Deployment scripts
├── lesson1/
│   ├── setup/
│   │   ├── Dockerfile          # Multi-stage production build
│   │   ├── .dockerignore       # Docker ignore file
│   │   ├── nginx.conf          # Nginx configuration
│   │   └── init.sql            # Database initialization
│   ├── .env.production         # Production environment variables
│   ├── .env.development        # Development environment variables
│   ├── healthcheck.js          # Health check script
│   └── src/                    # NestJS source code
└── logs/                       # Application logs
```

## 🔧 Configuration

### Environment Variables

#### Production (.env.production)
```env
NODE_ENV=production
DATABASE_URL=postgresql://postgres:password@postgres:5432/nestjs_db
JWT_SECRET=your-super-secret-jwt-key
# ... other production configs
```

#### Development (.env.development)
```env
NODE_ENV=development
DATABASE_URL=postgresql://postgres:password@postgres:5432/nestjs_db
JWT_SECRET=dev-secret-key-not-for-production
# ... other development configs
```

### Database Configuration

The PostgreSQL database is automatically initialized with the script in `lesson1/setup/init.sql`. Modify this file to set up your database schema.

### Nginx Configuration

The Nginx configuration in `lesson1/setup/nginx.conf` includes:
- Reverse proxy to NestJS app
- Rate limiting
- Gzip compression
- Security headers
- SSL configuration (commented out)

## 🏃‍♂️ Running the Application

### Available Commands

```bash
# Production
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml logs -f

# Development
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml logs -f

# Default (same as production)
docker-compose up -d
docker-compose down
docker-compose logs -f
```

### Accessing Services

- **Application**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Database**: localhost:5432
- **Redis**: localhost:6379
- **Nginx**: http://localhost:80

## 🔍 Monitoring and Debugging

### Health Checks

All services include health checks:
- **NestJS**: `/health` endpoint
- **PostgreSQL**: `pg_isready` command
- **Redis**: `redis-cli ping`
- **Nginx**: Depends on NestJS health

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nestjs-app
docker-compose logs -f postgres
docker-compose logs -f redis
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100 nestjs-app
```

### Container Status

```bash
# Check container status
docker-compose ps

# Check resource usage
docker stats

# Execute commands in container
docker-compose exec nestjs-app sh
docker-compose exec postgres psql -U postgres -d nestjs_db
```

## 🛡️ Security Features

### Application Security
- Non-root user in container
- Security headers via Nginx
- Rate limiting
- Input validation (implement in NestJS)

### Database Security
- SCRAM-SHA-256 authentication
- Volume encryption (configure in production)
- Network isolation

### Container Security
- Alpine Linux base images
- Minimal attack surface
- Resource limits
- Health checks

## 📊 Performance Optimization

### Container Resources
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

### Nginx Optimization
- Gzip compression enabled
- Static file caching
- Connection pooling
- Buffer optimization

### Database Optimization
- Connection pooling (configure in NestJS)
- Proper indexing
- Regular maintenance

## 🔄 CI/CD Integration

### Docker Hub
```bash
# Build and push
docker build -t your-org/nestjs-app:latest lesson1/setup/
docker push your-org/nestjs-app:latest
```

### Environment Promotion
```bash
# Staging
docker-compose -f docker-compose.staging.yml up -d

# Production
docker-compose -f docker-compose.prod.yml up -d
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using the port
   netstat -tulpn | grep :3000
   # Kill the process or change the port
   ```

2. **Database connection failed**
   ```bash
   # Check if PostgreSQL is running
   docker-compose ps postgres
   # Check logs
   docker-compose logs postgres
   ```

3. **Out of disk space**
   ```bash
   # Clean up Docker
   docker system prune -a
   docker volume prune
   ```

4. **Permission issues**
   ```bash
   # Fix permissions
   sudo chown -R $USER:$USER logs/
   ```

### Debug Mode

```bash
# Start with debug logging
LOG_LEVEL=debug docker-compose up

# Attach to running container
docker-compose exec nestjs-app sh

# Run commands inside container
docker-compose exec nestjs-app npm run test
```

## 📈 Scaling

### Horizontal Scaling
```bash
# Scale NestJS instances
docker-compose up -d --scale nestjs-app=3
```

### Load Balancing
Update `nginx.conf` to include multiple upstream servers:
```nginx
upstream nestjs_app {
    server nestjs-app_1:3000;
    server nestjs-app_2:3000;
    server nestjs-app_3:3000;
}
```

## 🔐 SSL/HTTPS Setup

1. **Generate certificates:**
   ```bash
   mkdir -p lesson1/setup/ssl
   # Add your SSL certificates to this directory
   ```

2. **Update nginx.conf:**
   ```nginx
   # Uncomment the SSL server block in nginx.conf
   ```

3. **Update docker-compose:**
   ```yaml
   ports:
     - "443:443"
   ```

## 📋 Maintenance

### Regular Tasks
- Monitor disk usage
- Update base images
- Backup database
- Review logs
- Security updates

### Backup Strategy
```bash
# Database backup
docker-compose exec postgres pg_dump -U postgres nestjs_db > backup.sql

# Volume backup
docker run --rm -v nestjs_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
