#!/bin/bash

url=https://dl.grafana.com/oss/release/grafana_8.3.6_amd64.deb

apt-get install -y adduser libfontconfig1
wget ${url}
dpkg -i grafana_8.3.6_amd64.deb
rm grafana_8.3.6_amd64.deb

systemctl start grafana-server