private registry
===
# push image to registry

## rename the image
namespace及tag為optional
```
docker tag <OriginImageName> <registryHostName/namespace/imageName:tag>
```

## push
```
docker push <registryHostName/namespace/imageName:tag>
```

# 從auth server取得token
> 若用curl記得開`-k` 若用Postman記得要關掉security 選項
GET URL
```
https://139.162.91.150:5001/auth?account=user&client_id=docker&offline_token=true&service=Docker+registry&scope=registry:catalog:*
```

Header
```
authorization Basic <id:pw>
```
id:pw必需以base64輸入，可以用下面指令獲得
```
echo user:password | base64
```

網址解析
```
https://139.162.91.150:5001/auth?
account=user&
client_id=docker&
offline_token=true&
service=Docker+registry&
scope=registry:catalog:*
```

由`account`、`service`、scope (`type`、`name`、`action`) 五個部分組成
在authz時，auth server會以下列各key作判斷，此`account`或`IP`是否有權操作這個`namespace`或`action`

pretty json
```
{
  "Account":"user",
  "Type":"registry",
  "Name":"catalog",
  "Service":"Docker registry",
  "IP":"111.250.164.33",
  "Actions":["*"],
  "Labels":null
}
```

raw json
```
{Account:user,Type:registry,Name:catalog,Service:Docker registry,IP:111.250.164.33,Actions:[*],Labels:null}
```

# 取得image列表

GET URL
```
https://172.19.1.17:5000/v2/_catalog
```

header
```
Authorization Bearer <JWT>
````

response
```
{
  "repositories": []
}
```

# Minor Errors

## 找不到使用者或密碼錯
```
Error response from daemon: Get https://localhost:5000/v2/: unauthorized: authentication required
```

## authn過了，但authz失敗或是cert錯誤導致token無效
```
Error response from daemon: login attempt to https://localhost:5000/v2/ failed with status: 401 Unauthorized
```


# Error 1: token signed by untrusted key with ID
###  handshake error
### insecure registry  
https://github.com/docker/docker/issues/23228#issuecomment-223732192  

### Failed tls handshake. Does not contain any IP SANs
http://serverfault.com/questions/611120/failed-tls-handshake-does-not-contain-any-ip-sans
> NO IP , use host name
://github.com/docker/distribution/issues/1143

```
docker logs -f registry
```

```
time="2017-01-11T06:07:51Z" level=error msg="token signed by untrusted key with ID: 略"
time="2017-01-11T06:07:51Z" level=warning msg="error authorizing context: invalid token"
```

可以發現，是由於`token signed by untrusted key`，造成的`invalid token`
token是由port `5001`的auth server產生的，port `5000`的registry要如何知道是否可信？
1. 取得公認可信的CA所發放的certificate
2. 用self-signed的cert，但registry開啟允許insecurity connection

## 開啟docker registry insecurity

```
{
  "insecure-registries": ["gogoge:5000"]
}
```

```
service docker restart
```

## cert所有的domain都必須是host name，不可以是IP

```
vi /etc/hosts
```

```
172.17.0.1      <hostname>  # ip  hostname
```

## 產生cert及private key

```
openssl req \
   -newkey rsa:4096 -nodes -sha256 -keyout certs/auth-srv.key \
   -x509 -days 365 -out certs/auth-srv.crt
```

只有CN是最重要的，記得用hostname，不要用IP，不必帶port
registry及auth-server共用一張cert和private key
```
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:<hostname>
Email Address []:
```

## 401 insufficient_scope
https://github.com/docker/docker-registry/issues/1071

> use correct scope when get token

# if you do not want to use token auth

create yaml file for auth
```
rm -rf auth
mkdir -p auth
docker run --name tmp-gen-pw-file --entrypoint htpasswd registry:2 -Bbn testuser testpassword > auth/htpasswd
docker rm -v tmp-gen-pw-file
```
run the container
```
docker run -d -p 5000:5000 \
  --name registry \
  --restart=always \
  -v registry:/var/lib/registry \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -v `pwd`/auth:/auth \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/var/lib/registry/auth \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2
```

# reference
https://gist.github.com/jlhawn/8f218e7c0b14c941c41f
https://blog.opendns.com/2016/02/23/implementing-oauth-for-registry-v2/
https://github.com/kwk/docker-registry-setup
https://www.sslshopper.com/certificate-decoder.html
https://the.binbashtheory.com/creating-private-docker-registry-2-0-with-token-authentication-service/

