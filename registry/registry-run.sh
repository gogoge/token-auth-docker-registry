docker volume create --name registry
docker run -d -p 5000:5000 \
  --name registry \
  --restart=always \
  -v registry:/var/lib/registry \
  -v `pwd`/../certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH=token \
  -e REGISTRY_AUTH_TOKEN_REALM=https://gogoge:5001/auth \
  -e REGISTRY_AUTH_TOKEN_SERVICE="Docker registry" \
  -e REGISTRY_AUTH_TOKEN_ISSUER="Auth Service" \
  -e REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/domain.crt \
  -e REGISTRY_HTTP_SECRET=randomsecret \
  registry:2
