# 📊 GRAFANA SETUP & USAGE GUIDE

## 🚀 Step 1: Start the Infrastructure

```bash
# Quick start (recommended)
quick-start.bat

# OR using the management script
infrastructure-manager.bat
# Choose option: 3. Development Environment (Lightweight)
```

## 🌐 Step 2: Access Grafana

After services start (wait 2-3 minutes):

```
URL: http://localhost:3001
Username: admin
Password: admin123
```

## 🎯 Step 3: What You'll See

### **Initial Dashboard:**
- 📈 **HTTP Requests Rate** - Real-time API calls
- ⏱️ **Response Time Distribution** - 95th percentile latency
- 🗄️ **Database Connections** - Active PostgreSQL connections
- ⚡ **Redis Cache Performance** - Hit/miss rates
- 💾 **Memory Usage** - System memory utilization
- 📨 **RabbitMQ Queue Size** - Message queue depth

## 🔧 Step 4: Add Metrics to Your NestJS App

### 4.1 Install Prometheus Package

```bash
cd lesson1
npm install @willsoto/nestjs-prometheus prom-client --legacy-peer-deps
```

### 4.2 Add Metrics Module

Create `src/metrics/metrics.module.ts`:

```typescript
import { Module } from '@nestjs/common';
import { PrometheusModule } from '@willsoto/nestjs-prometheus';
import { Counter, Histogram, Gauge, makeCounterProvider, makeHistogramProvider, makeGaugeProvider } from '@willsoto/nestjs-prometheus';

@Module({
  imports: [
    PrometheusModule.register({
      path: '/metrics',
      collectDefaultMetrics: true,
      defaultLabels: {
        app: 'nestjs-lesson1',
        version: '1.0.0',
      },
    }),
  ],
  providers: [
    makeCounterProvider({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status'],
    }),
    makeHistogramProvider({
      name: 'http_request_duration_ms',
      help: 'Duration of HTTP requests in milliseconds',
      labelNames: ['method', 'route'],
      buckets: [0.1, 5, 15, 50, 100, 500],
    }),
    makeGaugeProvider({
      name: 'active_users',
      help: 'Number of active users',
    }),
  ],
  exports: [PrometheusModule],
})
export class MetricsModule {}
```

### 4.3 Add Metrics Middleware

Create `src/metrics/metrics.middleware.ts`:

```typescript
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { InjectMetric } from '@willsoto/nestjs-prometheus';
import { Counter, Histogram } from 'prom-client';

@Injectable()
export class MetricsMiddleware implements NestMiddleware {
  constructor(
    @InjectMetric('http_requests_total')
    private readonly httpRequestsCounter: Counter<string>,
    
    @InjectMetric('http_request_duration_ms')
    private readonly httpRequestDuration: Histogram<string>,
  ) {}

  use(req: Request, res: Response, next: NextFunction) {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - start;
      const route = req.route?.path || req.path;
      
      // Count requests
      this.httpRequestsCounter
        .labels({
          method: req.method,
          route: route,
          status: res.statusCode.toString(),
        })
        .inc();
      
      // Record duration
      this.httpRequestDuration
        .labels({
          method: req.method,
          route: route,
        })
        .observe(duration);
    });
    
    next();
  }
}
```

### 4.4 Update App Module

Update `src/app.module.ts`:

```typescript
import { Module, MiddlewareConsumer } from '@nestjs/common';
import { MetricsModule } from './metrics/metrics.module';
import { MetricsMiddleware } from './metrics/metrics.middleware';
// ... other imports

@Module({
  imports: [
    // ... existing imports
    MetricsModule,
  ],
  // ... rest of module
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(MetricsMiddleware)
      .forRoutes('*');
  }
}
```

## 📊 Step 5: Test Your Setup

### 5.1 Start Your NestJS App

```bash
# In the lesson1 folder
npm run start:dev
```

### 5.2 Generate Some Traffic

```bash
# Test API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/users
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"name\":\"Test User\"}"
```

### 5.3 Check Metrics Endpoint

```bash
# View raw metrics
curl http://localhost:3000/metrics
```

You should see metrics like:
```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/health",status="200",app="nestjs-lesson1"} 5

# HELP http_request_duration_ms Duration of HTTP requests in milliseconds
# TYPE http_request_duration_ms histogram
http_request_duration_ms_bucket{le="0.1",method="GET",route="/health",app="nestjs-lesson1"} 0
http_request_duration_ms_bucket{le="5",method="GET",route="/health",app="nestjs-lesson1"} 3
```

## 🎛️ Step 6: Using Grafana Dashboard

### 6.1 View Pre-built Dashboard

1. Go to http://localhost:3001
2. Login with admin/admin123
3. Go to **Dashboards** → **Browse**
4. Open **"NestJS Application Overview"**

### 6.2 Create Custom Panels

Click **"+ Add Panel"** and try these queries:

**Total Requests:**
```promql
sum(rate(http_requests_total[5m]))
```

**Error Rate:**
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
```

**Average Response Time:**
```promql
rate(http_request_duration_ms_sum[5m]) / rate(http_request_duration_ms_count[5m])
```

**Top Endpoints by Traffic:**
```promql
topk(10, sum by (route) (rate(http_requests_total[5m])))
```

## 🔔 Step 7: Set Up Alerts

### 7.1 Create Alert Rule

1. Go to **Alerting** → **Alert Rules**
2. Click **"New Rule"**
3. Set query: `rate(http_requests_total{status=~"5.."}[5m]) > 0.1`
4. Set threshold: `> 0.1`
5. Set evaluation: `for 2m`

### 7.2 Add Notification Channel

1. Go to **Alerting** → **Notification Channels**
2. Click **"Add Channel"**
3. Choose type (Email, Slack, Webhook)
4. Configure your settings

## 📈 Step 8: Advanced Usage

### 8.1 Custom Business Metrics

Add to your service:

```typescript
@Injectable()
export class UserService {
  constructor(
    @InjectMetric('active_users') private activeUsersGauge: Gauge<string>,
    @InjectMetric('user_registrations_total') private userRegistrationsCounter: Counter<string>,
  ) {}

  async createUser(userData: any) {
    // ... create user logic
    
    // Increment registration counter
    this.userRegistrationsCounter.inc();
    
    // Update active users count
    const activeCount = await this.getActiveUserCount();
    this.activeUsersGauge.set(activeCount);
    
    return user;
  }
}
```

### 8.2 Infrastructure Monitoring

Prometheus automatically collects metrics from:
- **PostgreSQL** (if postgres_exporter is added)
- **Redis** (if redis_exporter is added)
- **RabbitMQ** (built-in management metrics)
- **System metrics** (CPU, memory, disk)

## 🎯 What to Monitor

### **Golden Signals:**
1. **Latency** - How long requests take
2. **Traffic** - How many requests per second
3. **Errors** - Rate of failed requests
4. **Saturation** - How full your service is

### **Business Metrics:**
- User registrations per day
- Active users
- Feature usage
- Revenue metrics

### **Infrastructure Metrics:**
- Database query time
- Cache hit rates
- Queue depths
- Memory/CPU usage

## 🚨 Common Issues & Solutions

### Problem: No Data in Grafana
**Solution:**
```bash
# Check if Prometheus is collecting metrics
curl http://localhost:9090/targets

# Check if your app is exposing metrics
curl http://localhost:3000/metrics

# Restart services if needed
docker-compose restart prometheus grafana
```

### Problem: Dashboard Not Loading
**Solution:**
```bash
# Check Grafana logs
docker logs grafana-lite

# Recreate dashboard
# Delete and re-import the JSON dashboard
```

## 🎉 You're Ready!

Your monitoring stack is now complete:
- ✅ **Metrics Collection** (Prometheus)
- ✅ **Visualization** (Grafana) 
- ✅ **Alerting** (Built-in)
- ✅ **Custom Dashboards** (Pre-configured)

Visit http://localhost:3001 and start monitoring your application! 📊
