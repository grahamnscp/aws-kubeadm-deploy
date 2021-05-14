#!/bin/bash

CONTROL_PLANE_ENDPOINT=$1
cd /root
kubeadm init --control-plane-endpoint $CONTROL_PLANE_ENDPOINT --node-name master1 --upload-certs 2>&1 | tee -a /root/kubeadm-init-master1.log

JOIN_NODE1=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | head -1 | awk '{printf("%s %s %s %s %s"),$1,$2,$3,$4,$5}'`
JOIN_NODE2=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | tail -2 | tail -1`
JOIN_MASTER_PARAMS=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | grep "control-plane"`

JOIN_CMD_NODE="${JOIN_NODE1} ${JOIN_NODE2}"
JOIN_CMD_MASTER="${JOIN_NODE1} ${JOIN_NODE2} ${JOIN_MASTER_PARAMS}"

