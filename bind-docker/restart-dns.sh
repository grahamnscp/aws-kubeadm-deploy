#!/bin/bash

DOCKERHUB_USER=grahamh
TAG=infra

docker stop $TAG-dns
docker rm $TAG-dns
docker pull $DOCKERHUB_USER/bind-docker:$TAG
docker run -it -d --restart unless-stopped --name=$TAG-dns \
  --dns=8.8.8.8 --dns=8.8.4.4 -p 53:53/udp -p 53:53 \
  $DOCKERHUB_USER/bind-docker:$TAG
docker logs $TAG-dns

