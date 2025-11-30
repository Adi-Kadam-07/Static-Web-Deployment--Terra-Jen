#!/bin/bash
set -e

# Update and install git, nginx
apt-get update -y
apt-get install -y git nginx

# Ensure /var/www/html is clean
rm -rf /var/www/html/*
git clone ${repo_url} /tmp/site || true

# If repo contains website/ directory, move its contents into web root
if [ -d /tmp/site/website ]; then
  cp -r /tmp/site/website/* /var/www/html/
else
  cp -r /tmp/site/* /var/www/html/
fi

# Permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start nginx
systemctl enable nginx
systemctl restart nginx
