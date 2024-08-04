#!/bin/bash
export basePort="8081"
export metricsPath='/metrics'
export baseUrl="localhost:${basePort}"

make build

# Run cloudflare-exporter
nohup ./cloudflare_exporter --listen="${baseUrl}" >/tmp/cloudflare-exporter-test.out 2>&1 &
export pid=$!
sleep 5

# Get metrics
curl -s http://${baseUrl}${metricsPath}

# Run Tests
venom run tests/basic_tests.yml
