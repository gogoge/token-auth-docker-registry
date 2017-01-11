docker run \
  -p 5001:5001 \
  -v `pwd`:/config \
  -v `pwd`:/logs \
  -v `pwd`/../certs:/certs \
  -e EXT="/config" \
  -d --name docker_auth \
  cesanta/docker_auth:stable --v=2 --alsologtostderr /config/auth_config.yml

