#!/bin/bash

url=https://github.com/prometheus/prometheus/releases/download/v2.33.3/prometheus-2.33.3.linux-amd64.tar.gz

useradd --no-create-home --shell /bin/false prometheus

wget ${url}
tar -xf prometheus-2.33.3.linux-amd64.tar.gz
mkdir /etc/prometheus
mkdir /var/lib/prometheus
mv prometheus-2.33.3.linux-amd64/prometheus /usr/local/bin/
mv prometheus-2.33.3.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
mv prometheus-2.33.3.linux-amd64/consoles /etc/prometheus
mv prometheus-2.33.3.linux-amd64/console_libraries /etc/prometheus

rm -rf prometheus-2.33.3.linux-amd64.tar.gz prometheus-2.33.3.linux-amd64

cp prometheus.yaml /etc/prometheus/prometheus.yaml
cp -R alertmanager /etc/prometheus/
cp rules.yaml /etc/prometheus/
chown -R prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus

tee /etc/systemd/system/prometheus.service <<"EOF"
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yaml \
    --web.enable-lifecycle \
    --storage.tsdb.retention.time=6h \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus