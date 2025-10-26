#!/bin/bash

# Copyright (C) 2025 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

source config

function debug {
    if [[ "${DEBUG}" == "true" ]]; then
        echo "Debug: $1"
    fi
}

function delete_ns {
    kubectl delete -f "k8s/${NS_YAML}" >> /dev/null
}

function delete_cluster_policy {
    kubectl delete -f "k8s/${CLUSTER_POLICY_YAML}" >> /dev/null
}

if [[ "$1" == "--help" ]]; then
    echo "$0 [--debug]"
    exit 0
fi

if [[ "$1" == "--debug" ]]; then
    DEBUG="true"
else
    DEBUG="false"
fi


# starts here

debug "Apply cluster policy YAML"
kubectl apply -f "k8s/${CLUSTER_POLICY_YAML}" >> /dev/null
debug "Sleep 5 seconds"
sleep 5
if [[ "$( kubectl get ClusterPolicy -o json | jq -r ' .items[].status.conditions[] | select ( .type == "Ready" ) | .status ' )" != "True" ]]; then
    echo "ERROR: ClusterPolicy not Ready"
    exit 1
fi
debug "Cluster policy loaded"

debug "Create namespace YAML"
kubectl apply -f "k8s/${NS_YAML}" >> /dev/null
debug "Sleep 2 seconds"
sleep 2

debug "Apply test1 YAML"
kubectl apply -f "k8s/${NGINX1_YAML}" >> /dev/null
debug "Sleep 5 seconds"
sleep 5
nginx1_ready=$( kubectl get po -n kyverno-test -o json | jq -r ' .items[].status.containerStatuses[] | select ( .name=="nginx1" ) | .ready ' )
if [[ "${nginx1_ready}" != "true" ]]; then
    echo "ERROR: test1 not Ready"
    debug "Delete namespace"
    delete_ns
    debug "Delete cluster policy"
    delete_cluster_policy
fi
debug "Test1 YAML applied"

debug "Apply test2 YAML"
ka_nginx2=$( kubectl apply -f "k8s/${NGINX2_YAML}" 2>> /dev/stdout )
ka_nginx2_md5=$( echo "${ka_nginx2}" | md5sum | awk ' { print $1 } ' )
if [[ "${ka_nginx2_md5}" == "${KA_NGINX_MD5}" ]]; then
    echo "SUCCESS: Kyverno tests worked (scheduled with, and stopped scheduling test without resource requests and limits)"
else
    echo "ERROR: something unexpected with nginx2 and Kyverno: ${ka_nginx2}"
fi

debug "Delete namespace"
delete_ns
debug "Delete cluster policy" 
delete_cluster_policy
