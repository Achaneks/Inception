#!/bin/bash
set -e

exec /usr/sbin/grafana-server \
    --config=/etc/grafana/grafana.ini \
    --homepath=/usr/share/grafana \
    cfg:default.paths.data=/var/lib/grafana \
    cfg:default.paths.logs=/var/log/grafana