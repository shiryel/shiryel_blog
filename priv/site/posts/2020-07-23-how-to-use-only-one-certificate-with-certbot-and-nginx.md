---
layout: posts/_post.slime
tag:
  - post
tags:
  - certbot
  - nginx
title: "How to use only one certificate with certbot and nginx"
description: "A reminder on how to use only one certificate with certbot and nginx with the minimum of enfort"
permalink: post/how-to-use-only-one-certificate-with-certbot-and-nginx/index.html
date: 2020-07-23
---

This is more a reminder for myself but anyway

First, you need to generate the certificate with the certbot on the AWS, you need to put both the www and non-www url, otherwise the redirect will be invalid or the website will display a invalid certificate

```bash
  sudo certbot  -d shiryel.com -d www.shiryel.com -d blog.shiryel.com -d www.blog.shiryel.com -d webrtc.shiryel.com -d www.webrtc.shiryel.com
```

Then, you need a Nginx like this:

```nginx
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
	worker_connections 1024;
}

http {
	log_format main '$remote_addr - $remote_user [$time_local] "$request" '
		'$status $body_bytes_sent "$http_referer" '
		'"$http_user_agent" "$http_x_forwarded_for"';
	access_log /var/log/nginx/access.log main;

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;

	include /etc/nginx/mime.types;
	default_type text/plain;

	###########
	# CERTBOT #
	###########

  ssl_certificate /etc/letsencrypt/live/shiryel.com/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/shiryel.com/privkey.pem; # managed by Certbot
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
	# Automatic important security parameters (provided by certbot)
	include /etc/letsencrypt/options-ssl-nginx.conf;

	#################
	# ENFORCE HTTPS #
	#################

	server {
		listen 80 default_server;
		server_name _;
	
		return 301 https://$host$request_uri;
	}

	########
	# HOME #
	########

	# Dont have non-www because the DNS redirect to WWW
	server {
		server_name www.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		location / {
			root /www/shiryel;
			index shiryel.html;
		}
	}

	##########
	# WEBRTC #
	##########

	upstream docker-webrtc {
		server 0.0.0.0:5001;
	}

	upstream docker-webrtc-server {
		server 0.0.0.0:4001;
	}

	map $http_upgrade $connection_upgrade {
		default upgrade;
		''      close;
	}

	server {
		server_name www.webrtc.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		return 301 $scheme://webrtc.shiryel.com/$request_uri;
	}

	server {
		server_name webrtc.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		location / {
			proxy_pass         http://docker-webrtc;
			proxy_redirect     off;
			proxy_set_header   Host $host;
			proxy_set_header   X-Real-IP $remote_addr;
			proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header   X-Forwarded-Host $server_name;
		}
	}

	server {
		server_name webrtc-server.shiryel.com www.webrtc-server.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		location / {
			proxy_pass         http://docker-webrtc-server;
			proxy_set_header   Host $host;
			proxy_set_header   X-Real-IP $remote_addr;
			proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header   X-Forwarded-Host $server_name;

			# WebSocket support
			proxy_http_version 1.1;
			proxy_set_header   Upgrade $http_upgrade;
			proxy_set_header   Connection $connection_upgrade;
		}
	}

	########
	# BLOG #
	########

	server {
		server_name www.blog.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		return 301 $scheme://blog.shiryel.com/$request_uri;
	}

	server {
		server_name blog.shiryel.com;
		listen 443 ssl http2;
		listen [::]:443 ssl http2;

		location / {
			root /www/shiryel_blog;
		}
	}
}
```

Yes, good luck with the nginx file, I alread have a bad time learning all this shit :)
