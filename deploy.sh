#!/bin/bash

# Production deployment script for NestJS application

set -e

echo "🚀 Starting production deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    print_warning ".env.production file not found. Please create it with your production environment variables."
fi

# Pull latest images
print_status "Pulling latest Docker images..."
docker-compose pull

# Build the application
print_status "Building the application..."
docker-compose build --no-cache

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down

# Start the application
print_status "Starting the application..."
docker-compose up -d

# Wait for services to be healthy
print_status "Waiting for services to be healthy..."
sleep 30

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    print_status "✅ Application deployed successfully!"
    print_status "🌐 Application is available at: http://localhost:3000"
    print_status "🗄️  Database is available at: localhost:5432"
    print_status "🔴 Redis is available at: localhost:6379"
    
    # Show container status
    print_status "Container status:"
    docker-compose ps
    
    # Show logs for a few seconds
    print_status "Recent logs:"
    docker-compose logs --tail=20
else
    print_error "❌ Deployment failed. Check the logs:"
    docker-compose logs
    exit 1
fi

print_status "🎉 Deployment completed successfully!"
print_status "💡 To view logs: docker-compose logs -f"
print_status "💡 To stop the application: docker-compose down"
