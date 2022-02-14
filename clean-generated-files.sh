#!/bin/bash

# clean generated files from ansible playbooks
test -e ansible/hosts && rm ansible/hosts
test -e ansible/working-files/admin.yml && rm ansible/working-files/admin.yml
test -e ansible/working-files/admin.conf && rm ansible/working-files/admin.conf
test -e ansible/working-files/join-params.yaml && rm ansible/working-files/join-params.yaml

# clean generated dns files
test -e ansible/working-files/resolv.conf && rm ansible/working-files/resolv.conf
test -e bind-docker/configs/named.conf.docker && rm bind-docker/configs/named.conf.docker
rm -rf bind-docker/varbind/docker/*

rm tf/variables.tf
