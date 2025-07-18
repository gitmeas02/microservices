# 🔗 RUNNING INFRASTRUCTURE + PRODUCTION TOGETHER

## ✅ YES, IT WORKS!

You can absolutely run both files together:
- `docker-compose.infrastructure.lite.yml` - Infrastructure services
- `docker-compose.prod.yml` - Your NestJS application

They use **different networks** and **different ports**, so no conflicts!

## 🚀 Quick Start

```cmd
# Option 1: Use the production manager
production-manager.bat

# Option 2: Manual commands
docker-compose -f docker-compose.infrastructure.lite.yml up -d
docker-compose -f docker-compose.prod.yml up -d
```

## 📊 Port Mapping (NO CONFLICTS!)

### Infrastructure Services (.lite.yml)
| Service | Host Port | Container Port | Access |
|---------|-----------|----------------|---------|
| Keycloak | 8080 | 8080 | http://localhost:8080 |
| Keycloak DB | 5433 | 5432 | localhost:5433 |
| RabbitMQ Web | 15672 | 15672 | http://localhost:15672 |
| RabbitMQ AMQP | 5672 | 5672 | localhost:5672 |
| MinIO API | 9000 | 9000 | localhost:9000 |
| MinIO Console | 9001 | 9001 | http://localhost:9001 |
| Nexus | 8083 | 8081 | http://localhost:8083 |
| Grafana | 3001 | 3000 | http://localhost:3001 |
| Prometheus | 9090 | 9090 | http://localhost:9090 |

### Application Services (.prod.yml)
| Service | Host Port | Container Port | Access |
|---------|-----------|----------------|---------|
| NestJS App | 3000 | 3000 | http://localhost:3000 |
| App PostgreSQL | 5434 | 5432 | localhost:5434 |
| Redis | 6380 | 6379 | localhost:6380 |
| Nginx | 80 | 80 | http://localhost:80 |
| Nginx HTTPS | 443 | 443 | https://localhost:443 |

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE LAYER                     │
│  (docker-compose.infrastructure.lite.yml)                  │
│                                                             │
│  🛡️  Keycloak (Auth)     🐰 RabbitMQ (Queue)              │
│  📊 Grafana (Monitor)    📦 Nexus (Artifacts)              │
│  💾 MinIO (Storage)      📈 Prometheus (Metrics)           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     APPLICATION LAYER                       │
│            (docker-compose.prod.yml)                       │
│                                                             │
│  🚀 NestJS App           🗄️  PostgreSQL (App DB)          │
│  ⚡ Redis (Cache)        🌐 Nginx (Reverse Proxy)          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Configuration for Your NestJS App

Update your `.env.production` file to connect to infrastructure services:

```env
# Database (App-specific)
DB_HOST=localhost
DB_PORT=5434
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=nestjs_db

# Redis (App-specific cache)
REDIS_HOST=localhost
REDIS_PORT=6380

# Infrastructure Services
KEYCLOAK_URL=http://localhost:8080
RABBITMQ_URL=amqp://dev:dev123@localhost:5672/dev
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=devadmin
MINIO_SECRET_KEY=dev123456

# Monitoring
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3001
```

## 🎯 Integration Examples

### 1. Connect to Keycloak (Authentication)
```typescript
// In your NestJS app
import { KeycloakConnectModule } from 'nest-keycloak-connect';

@Module({
  imports: [
    KeycloakConnectModule.register({
      authServerUrl: 'http://localhost:8080',
      realm: 'dev-realm',
      clientId: 'nestjs-app',
      secret: 'your-client-secret',
    }),
  ],
})
export class AppModule {}
```

### 2. Connect to RabbitMQ (Messaging)
```typescript
// In your NestJS app
import { ClientsModule, Transport } from '@nestjs/microservices';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'RABBITMQ_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: ['amqp://dev:dev123@localhost:5672/dev'],
          queue: 'nestjs_queue',
        },
      },
    ]),
  ],
})
export class AppModule {}
```

### 3. Connect to MinIO (File Storage)
```typescript
// In your NestJS app
import { Client } from 'minio';

@Injectable()
export class StorageService {
  private minioClient = new Client({
    endPoint: 'localhost',
    port: 9000,
    useSSL: false,
    accessKey: 'devadmin',
    secretKey: 'dev123456',
  });
}
```

## 🚨 Startup Order (Important!)

1. **Start Infrastructure FIRST** (wait 30-60 seconds)
2. **Then start Application**

```cmd
# Correct order
docker-compose -f docker-compose.infrastructure.lite.yml up -d
# Wait 30 seconds
docker-compose -f docker-compose.prod.yml up -d
```

## 📊 Monitoring Your Setup

Once both are running:

1. **Grafana**: http://localhost:3001 (admin/admin123)
   - View application metrics and infrastructure health

2. **Prometheus**: http://localhost:9090
   - Raw metrics data

3. **Application Health**: http://localhost:3000/health
   - Your NestJS app health check

## 🛠️ Troubleshooting

### Problem: Services not connecting
```cmd
# Check if all services are running
docker ps

# Check specific service logs
docker logs keycloak-dev
docker logs nestjs-lesson1-app-prod
```

### Problem: Port already in use
```cmd
# Find what's using the port
netstat -ano | findstr :5434

# Kill the process if needed
taskkill /PID <process_id> /F
```

### Problem: Database connection failed
- Make sure PostgreSQL ports are correct:
  - Keycloak DB: `5433` 
  - App DB: `5434`

## 🎉 Benefits of This Setup

✅ **Separation of Concerns**: Infrastructure vs Application
✅ **Scalability**: Scale infrastructure and app independently  
✅ **Reusability**: Use same infrastructure for multiple apps
✅ **Production-Ready**: Both layers are production-optimized
✅ **Monitoring**: Full observability with Grafana/Prometheus
✅ **Security**: Keycloak for authentication
✅ **Performance**: Redis caching, Nginx reverse proxy

## 📚 Next Steps

1. Set up CI/CD pipeline using the infrastructure
2. Configure Keycloak realms and clients
3. Set up monitoring alerts in Grafana
4. Configure backup strategies for data volumes
5. Set up SSL certificates for production

**You now have a enterprise-grade setup! 🚀**
