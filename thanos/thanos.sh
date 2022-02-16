#!/bin/bash

url=https://github.com/thanos-io/thanos/releases/download/v0.24.0/thanos-0.24.0.linux-amd64.tar.gz

useradd --no-create-home --shell /bin/false thanos

wget ${url}
tar -xf thanos-0.24.0.linux-amd64.tar.gz
mv thanos-0.24.0.linux-amd64/thanos /usr/local/bin
mkdir -p /etc/thanos/
cp bucket.yaml /etc/thanos/
chown -R thanos:thanos /etc/thanos/
chown thanos:thanos /usr/local/bin/thanos

rm -rf thanos-0.24.0.linux-amd64 thanos-0.24.0.linux-amd64.tar.gz

#Thanos sidecar
tee /etc/systemd/system/sidecar.service <<"EOF"
[Unit]
Description=Thanos Sidecar

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos sidecar \
    --grpc-address="0.0.0.0:19090" \
    --http-address="0.0.0.0:19191" \
    --tsdb.path /var/lib/prometheus \
    --prometheus.url "http://localhost:9090" \
    --objstore.config-file  "/etc/thanos/bucket.yaml"

[Install]
WantedBy=multi-user.target
EOF

#Thanos store
tee /etc/systemd/system/store.service <<"EOF"
[Unit]
Description=Thanos Store

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos store \
    --grpc-address="0.0.0.0:19091" \
    --http-address="0.0.0.0:19100" \
    --data-dir        "/local/state/data/dir" \
    --objstore.config-file "/etc/thanos/bucket.yaml"

[Install]
WantedBy=multi-user.target
EOF

#Thanos query
tee /etc/systemd/system/query.service <<"EOF"
[Unit]
Description=Thanos Query

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos query \
    --grpc-address     "0.0.0.0:19092" \
    --http-address     "0.0.0.0:19192" \
    --store            "localhost:19090" \
    --store            "localhost:19091"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start sidecar
systemctl start store
systemctl start query