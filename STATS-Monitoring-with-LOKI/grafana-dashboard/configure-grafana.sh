#!/bin/bash
set -e

##Install grafana plugins
wget -nv https://grafana.com/api/plugins/grafana-piechart-panel/versions/latest/download -O /tmp/grafana-piechart-panel.zip
wget -nv https://grafana.com/api/plugins/natel-discrete-panel/versions/latest/download -O /tmp/natel-discrete-panel.zip
unzip -q /tmp/grafana-piechart-panel.zip -d /opt/logging-monitoring/grafana/data/plugins
unzip -q /tmp/natel-discrete-panel.zip -d /opt/logging-monitoring/grafana/data/plugins
################################################################
##Create grafana datasources
#Prometheus
curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","typeLogoUrl":"public/app/plugins/datasource/prometheus/img/prometheus_logo.svg","access":"proxy","isDefault":true,"database":"","user":"","password":"","basicAuth":false,"jsonData":{},"readOnly":false}'
#Loki
curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"Loki","type":"loki","url":"http://localhost:3100","typeLogoUrl":"public/app/plugins/datasource/loki/img/loki_icon.svg","access":"proxy","isDefault":true,"database":"","user":"","password":"","basicAuth":false,"jsonData":{},"readOnly":false}'
################################################################
##restart grafana 
systemctl restart grafana
################################################################
#check grafana rediness
until nc -z -v -w30 localhost 3000
do
  echo "Waiting for grafana connection..."
  # wait for 5 seconds before check again
  sleep 5
done
################################################################
##List grafana datasources
curl 'http://admin:admin@127.0.0.1:3000/api/datasources'
################################################################
##Import grafana Dashboards
#
for i in $(ls dashboards); do
 curl 'http://admin:admin@127.0.0.1:3000/api/dashboards/db' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary @dashboards/${i}
done