# KrakenD API Gateway Configuration

## Overview

KrakenD is a high-performance API Gateway that provides:
- **Rate Limiting**: Protect your services from overload
- **Authentication**: JWT validation and authorization
- **Aggregation**: Combine multiple backend responses
- **Caching**: Reduce backend load with intelligent caching
- **Monitoring**: Built-in metrics and telemetry
- **CORS**: Cross-Origin Resource Sharing support

## Service URLs

- **API Gateway**: http://localhost:8000 or http://api.local
- **Gateway Docs**: http://localhost:8000/__debug
- **Gateway Health**: http://localhost:8000/__health
- **Gateway Metrics**: http://localhost:8090 (Prometheus format)

## API Endpoints

### Health Checks
```bash
# Gateway health
GET http://localhost:8000/health

# Application health (through gateway)
GET http://localhost:8000/api/v1/health
```

### Authentication (Keycloak)
```bash
# Get token
POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=admin&password=admin123&client_id=admin-cli

# Get user info
GET http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/userinfo
Authorization: Bearer <token>
```

### Monitoring (Prometheus)
```bash
# Query metrics
GET http://localhost:8000/api/v1/monitoring/metrics/query?query=up

# Example queries
GET http://localhost:8000/api/v1/monitoring/metrics/query?query=krakend_requests_total
GET http://localhost:8000/api/v1/monitoring/metrics/query?query=prometheus_notifications_total
```

### Messaging (RabbitMQ)
```bash
# List queues
GET http://localhost:8000/api/v1/messaging/queues
Authorization: Basic YWRtaW46YWRtaW4xMjM=  # admin:admin123

# List exchanges
GET http://localhost:8000/api/v1/messaging/exchanges
```

### Artifact Management (Nexus)
```bash
# List repositories
GET http://localhost:8000/api/v1/artifacts/repositories
Authorization: Basic YWRtaW46YWRtaW4xMjM=  # admin:admin123
```

### Dashboards (Grafana)
```bash
# Search dashboards
GET http://localhost:8000/api/v1/dashboards/search

# Get specific dashboard
GET http://localhost:8000/api/v1/dashboards/{uid}
```

## Rate Limiting

KrakenD includes rate limiting to protect your services:

- **Global Rate Limit**: 100 requests/second per endpoint
- **Client Rate Limit**: 10 requests/second per IP
- **Auth Endpoints**: 30 requests/second for token generation
- **Monitoring**: 200 requests/second for metrics queries

## Authentication & Authorization

### JWT Validation
KrakenD validates JWT tokens from Keycloak:
```json
{
  "auth/validator": {
    "alg": "HS256",
    "audience": ["http://localhost:8000"],
    "issuer": "http://keycloak:8080",
    "jwk_url": "http://keycloak:8080/realms/master/protocol/openid_connect/certs"
  }
}
```

### Protected Endpoints
Some endpoints require authentication:
- `/api/v1/storage/*` - Requires user or admin role
- Most management endpoints - Require proper authentication

## CORS Configuration

KrakenD is configured to handle CORS for web applications:
- **Allowed Origins**: `*` (all origins)
- **Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Allowed Headers**: Authorization, Content-Type, X-API-Key
- **Credentials**: Supported for authenticated requests

## Monitoring & Metrics

### Built-in Metrics
KrakenD exposes metrics on port 8090:
```bash
# Prometheus metrics
curl http://localhost:8090/metrics

# Via Nginx proxy
curl http://localhost/gateway/metrics
```

### Key Metrics
- `krakend_requests_total` - Total requests processed
- `krakend_request_duration_seconds` - Request latency
- `krakend_responses_total` - Response status codes
- `krakend_backends_total` - Backend service calls

## Configuration Management

### Main Configuration
The main configuration is in `infrastructure/krakend/krakend.json`:
```json
{
  "version": 3,
  "name": "DevOps Infrastructure API Gateway",
  "port": 8000,
  "endpoints": [...]
}
```

### Environment Variables
Configure KrakenD through environment variables:
```bash
KRAKEND_PORT=8000
KRAKEND_CONFIG=/etc/krakend/krakend.json
```

## Docker Integration

### Container Configuration
```yaml
krakend:
  image: devopsfaith/krakend:2.5
  container_name: krakend-gateway
  ports:
    - "8000:8000"   # API Gateway
    - "8090:8090"   # Metrics
  volumes:
    - ./infrastructure/krakend/krakend.json:/etc/krakend/krakend.json:ro
```

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8000/__health"]
  interval: 30s
  timeout: 10s
  retries: 5
```

## Usage Examples

### Basic API Call
```bash
# Direct service call
curl http://localhost:9090/api/v1/query?query=up

# Through API Gateway
curl http://localhost:8000/api/v1/monitoring/metrics/query?query=up
```

### Authenticated Request
```bash
# Get token first
TOKEN=$(curl -X POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=admin-cli" \
  | jq -r '.access_token')

# Use token for protected endpoint
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/storage/buckets
```

## Troubleshooting

### Common Issues

1. **Service Not Responding**
   ```bash
   # Check KrakenD health
   curl http://localhost:8000/__health
   
   # Check specific service through gateway
   curl http://localhost:8000/api/v1/health
   ```

2. **Rate Limiting**
   ```bash
   # Check if you're hitting rate limits
   curl -v http://localhost:8000/api/v1/monitoring/metrics/query?query=up
   # Look for 429 Too Many Requests
   ```

3. **Authentication Issues**
   ```bash
   # Verify Keycloak is accessible
   curl http://localhost:8080/realms/master/.well-known/openid_connect_configuration
   
   # Check JWT validation
   curl -H "Authorization: Bearer invalid_token" \
     http://localhost:8000/api/v1/storage/buckets
   ```

### Debug Mode
Enable debug mode for detailed logging:
```json
{
  "debug_endpoint": true,
  "echo_endpoint": true,
  "extra_config": {
    "telemetry/logging": {
      "level": "DEBUG"
    }
  }
}
```

### Debug Endpoints
- `/__debug` - Configuration viewer
- `/__health` - Health status
- `/__echo` - Request echo for testing

## Performance Tuning

### Timeouts
```json
{
  "timeout": "5000ms",
  "cache_ttl": "300s"
}
```

### Backend Configuration
```json
{
  "backend": {
    "timeout": "3000ms",
    "extra_config": {
      "backend/http": {
        "return_error_details": "backend_alias"
      }
    }
  }
}
```

### Rate Limiting Strategy
```json
{
  "qos/ratelimit/router": {
    "max_rate": 100,
    "client_max_rate": 10,
    "strategy": "ip"  // or "header", "query"
  }
}
```

## Security Best Practices

1. **Use HTTPS in Production**
2. **Implement Proper Authentication**
3. **Configure Rate Limiting**
4. **Validate JWT Tokens**
5. **Monitor for Suspicious Activity**
6. **Use API Keys for Service-to-Service Communication**
7. **Regular Security Updates**

## Next Steps

1. **Customize Rate Limits** for your specific use case
2. **Add API Keys** for service authentication
3. **Implement Circuit Breakers** for backend resilience
4. **Add Response Transformation** if needed
5. **Configure Custom Middleware** for advanced features
6. **Set up Alerting** based on gateway metrics
