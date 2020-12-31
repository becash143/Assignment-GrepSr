#!/bin/bash
set -e

PROMETHEUS_VERSION=2.21.0
NODE_EXPORTER_VERSION=1.0.1
GRAFANA_VERSION=7.2.2
LOKI_VERSION=1.6.1
ROOT_DIR=/opt/logging-monitoring
################################################################
if [ ! -d "${ROOT_DIR}" ] 
then
    mkdir -p ${ROOT_DIR}  
fi
cp *.service ${ROOT_DIR}
cp *.yml ${ROOT_DIR}
cd ${ROOT_DIR}
################################################################
#Download and Unpack Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 prometheus
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
#################################################################
#Update prometheus configuration file for node exporter
tee -a prometheus/prometheus.yml > /dev/null <<EOT
  # Localhost Node Exporter ( You can add all servers here)
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
      
  #  Metric configuration
  - job_name: syslog
    metrics_path: "/v1/metrics"
    params:
      format: ['prometheus']
    scheme: http
    static_configs:
      - targets:
         - localhost:4646

  # SpringBoot prometheus metrics
  - job_name: 'spring'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:9099']       
EOT
#################################################################
#Download and Unpack the Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
#################################################################
#Download and Unpack Grafana
wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
tar -zxvf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
mv grafana-${GRAFANA_VERSION} grafana
rm -rf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
#################################################################
#Download and Unpack Loki
curl -O -L "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip"
unzip "loki-linux-amd64.zip"
rm -rf loki-linux-amd64.zip
chmod a+x "loki-linux-amd64"
mv loki-linux-amd64 loki
#################################################################
#Download and Unpack Promtail 
curl -fSL -o promtail.gz "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip"
gunzip promtail.gz
chmod a+x promtail
#################################################################
#Create service for monitoring tools
mv ${ROOT_DIR}/*.service /etc/systemd/system/
systemctl enable node_exporter prometheus grafana loki promtail
systemctl start node_exporter prometheus grafana loki promtail 
#################################################################

