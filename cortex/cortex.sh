#!/bin/bash

url=https://github.com/cortexproject/cortex/releases/download/v1.11.0/cortex-linux-amd64

useradd --no-create-home --shell /bin/false cortex

wget ${url}

mv cortex-linux-amd64 /usr/local/bin/cortex
chmod +x /usr/local/bin/cortex
chown cortex:cortex /usr/local/bin/cortex
mkdir -p /etc/cortex/
cp cortex-frontend.yml /etc/cortex/
chown -R cortex:cortex /etc/cortex/

tee /etc/systemd/system/cortex.service <<"EOF"
[Unit]
Description=Cortex

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/cortex \
    --config.file=/etc/cortex/cortex-frontend.yml
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start cortex