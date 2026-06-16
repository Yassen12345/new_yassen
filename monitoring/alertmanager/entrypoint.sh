#!/bin/sh
set -e
sed "s|\${SMTP_PASSWORD}|${SMTP_PASSWORD}|g" \
  /etc/alertmanager/alertmanager.yml.template > /etc/alertmanager/alertmanager.yml
exec /bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml
