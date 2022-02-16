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