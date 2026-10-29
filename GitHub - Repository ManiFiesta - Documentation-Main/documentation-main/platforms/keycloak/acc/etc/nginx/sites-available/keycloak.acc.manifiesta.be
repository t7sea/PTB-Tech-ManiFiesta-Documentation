server {
    server_name keycloak.acc.manifiesta.be;
    fastcgi_buffers 16 16k;
    fastcgi_buffer_size 32k;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;

    location ^~ /.well-known {
        allow all;
    }

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/keycloak.acc.manifiesta.be/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/keycloak.acc.manifiesta.be/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    listen 9001;
    server_name keycloak.acc.manifiesta.be;

    location ^~ /.well-known {
        allow all;
    }

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}

server {
    if ($host = keycloak.acc.manifiesta.be) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    server_name keycloak.acc.manifiesta.be;
    return 404; # managed by Certbot
}
