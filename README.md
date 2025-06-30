# Booking Pteas Khmer

A microservices-based platform for booking services with Khmer language support.

## Prerequisites
- Git
- Docker and Docker Compose

## Setup
1. Run `./setup_project.sh` to create structure and prepare Docker environment
2. Configure `.env` with necessary environment variables (e.g., Keycloak, MySQL, Stripe, PayPal)
3. Run `docker-compose up --build -d` to build and start services
4. Access the application at `http://localhost`

## Services
- **API Gateway**: Node.js-based gateway (port 8080)
- **Auth Service**: PHP/Laravel with Keycloak (port 8001)
- **Notification Service**: Node.js for email, SMS, push notifications (port 8002)
- **Payment Service**: PHP/Laravel with Stripe and PayPal (port 8003)
- **Chat Websocket Service**: Node.js WebSocket for real-time chat (port 8004)

## Deployment
- Kubernetes: `deployment/kubernetes/`
- Ansible: `deployment/ansible/`
- Scripts: `deployment/scripts/`

## Contributing
1. Fork the repository
2. Create a feature branch
3. Submit a pull request
