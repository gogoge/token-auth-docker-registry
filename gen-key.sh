openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
            -subj '/C=TW/ST=Taiwan/L=Taipei/O=Wistron/OU=SWPC/CN=gogoge/' \
            -x509 -days 365 -out certs/domain.crt

