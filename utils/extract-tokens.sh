#!/bin/bash

# join token
JOIN_NODE1=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | head -1 | awk '{printf("%s %s %s %s %s"),$1,$2,$3,$4,$5}'`
JOIN_NODE2=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | tail -2 | tail -1`
JOIN_NODE="${JOIN_NODE1} ${JOIN_NODE2}"

# control-plane params
JOIN_MASTER_PARAMS=`cat ~/kubeadm-init-master1.log | grep --after-context=2 "kubeadm join" | grep "control-plane"`

JOIN_MASTER="${JOIN_NODE} ${JOIN_MASTER_PARAMS}"

echo join node:
echo $JOIN_NODE

echo ""

echo join control-plane:
echo $JOIN_MASTER
