// Real-time Docker service health checker
// This script checks if Docker services are actually running

class ServiceHealthChecker {
    constructor() {
        this.services = [
            { name: 'Keycloak', port: 8080, element: 0 },
            { name: 'GitLab', port: 8082, element: 1 },
            { name: 'Jenkins', port: 8081, element: 2 },
            { name: 'Nexus', port: 8083, element: 3 },
            { name: 'MinIO', port: 9001, element: 4 },
            { name: 'RabbitMQ', port: 15672, element: 5 },
            { name: 'Prometheus', port: 9090, element: 6 },
            { name: 'Grafana', port: 3001, element: 7 }
        ];
        this.indicators = [];
        this.checkInterval = null;
    }

    init() {
        this.indicators = document.querySelectorAll('.status-indicator');
        this.startHealthChecks();
        
        // Check every 10 seconds
        this.checkInterval = setInterval(() => {
            this.startHealthChecks();
        }, 10000);
    }

    async startHealthChecks() {
        console.log('🔍 Checking service health...');
        
        // Set all to checking state
        this.indicators.forEach((indicator, index) => {
            this.setIndicatorStatus(indicator, 'checking', `Checking ${this.services[index].name}...`);
        });

        // Check each service
        for (let i = 0; i < this.services.length; i++) {
            const service = this.services[i];
            const indicator = this.indicators[i];
            
            if (indicator) {
                const isUp = await this.checkService(service);
                this.setIndicatorStatus(
                    indicator, 
                    isUp ? 'up' : 'down', 
                    `${service.name} is ${isUp ? 'running' : 'not responding'} on port ${service.port}`
                );
            }
        }
    }

    async checkService(service) {
        try {
            // Method 1: Try to fetch a simple request
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 3000);
            
            const response = await fetch(`http://localhost:${service.port}`, {
                method: 'HEAD', // Use HEAD to minimize data transfer
                mode: 'no-cors',
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            return true; // If we get here, service responded
            
        } catch (error) {
            // Method 2: Try WebSocket connection test
            return await this.checkServiceViaWebSocket(service);
        }
    }

    checkServiceViaWebSocket(service) {
        return new Promise((resolve) => {
            try {
                const ws = new WebSocket(`ws://localhost:${service.port}`);
                const timeout = setTimeout(() => {
                    ws.close();
                    resolve(false);
                }, 2000);

                ws.onopen = () => {
                    clearTimeout(timeout);
                    ws.close();
                    resolve(true);
                };

                ws.onerror = () => {
                    clearTimeout(timeout);
                    resolve(false);
                };

            } catch (error) {
                resolve(false);
            }
        });
    }

    setIndicatorStatus(indicator, status, tooltip) {
        if (!indicator) return;

        switch (status) {
            case 'up':
                indicator.style.background = '#28a745';
                indicator.style.animation = 'pulse 2s infinite';
                indicator.style.boxShadow = '0 0 10px rgba(40, 167, 69, 0.3)';
                break;
            case 'down':
                indicator.style.background = '#dc3545';
                indicator.style.animation = 'none';
                indicator.style.boxShadow = '0 0 10px rgba(220, 53, 69, 0.3)';
                break;
            case 'checking':
                indicator.style.background = '#ffc107';
                indicator.style.animation = 'pulse 0.8s infinite';
                indicator.style.boxShadow = '0 0 10px rgba(255, 193, 7, 0.3)';
                break;
        }
        
        indicator.title = tooltip;
        indicator.setAttribute('data-status', status);
    }

    destroy() {
        if (this.checkInterval) {
            clearInterval(this.checkInterval);
        }
    }
}

// Export for use in main HTML
window.ServiceHealthChecker = ServiceHealthChecker;
