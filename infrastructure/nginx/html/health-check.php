<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Define services to check
$services = [
    'keycloak' => ['host' => 'localhost', 'port' => 8080, 'name' => 'Keycloak'],
    'gitlab' => ['host' => 'localhost', 'port' => 8082, 'name' => 'GitLab'],
    'jenkins' => ['host' => 'localhost', 'port' => 8081, 'name' => 'Jenkins'],
    'nexus' => ['host' => 'localhost', 'port' => 8083, 'name' => 'Nexus'],
    'minio' => ['host' => 'localhost', 'port' => 9001, 'name' => 'MinIO'],
    'rabbitmq' => ['host' => 'localhost', 'port' => 15672, 'name' => 'RabbitMQ'],
    'prometheus' => ['host' => 'localhost', 'port' => 9090, 'name' => 'Prometheus'],
    'grafana' => ['host' => 'localhost', 'port' => 3001, 'name' => 'Grafana']
];

$results = [];

foreach ($services as $key => $service) {
    $status = checkServiceHealth($service['host'], $service['port']);
    $results[$key] = [
        'name' => $service['name'],
        'status' => $status ? 'up' : 'down',
        'port' => $service['port'],
        'checked_at' => date('Y-m-d H:i:s')
    ];
}

function checkServiceHealth($host, $port, $timeout = 3) {
    $connection = @fsockopen($host, $port, $errno, $errstr, $timeout);
    if ($connection) {
        fclose($connection);
        return true;
    }
    return false;
}

echo json_encode([
    'timestamp' => date('Y-m-d H:i:s'),
    'services' => $results
]);
?>
