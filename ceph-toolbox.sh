#!/bin/bash

# Get the OpenShift version
openshift_version=$(oc get clusterversion | awk '{print $2}')

if [ "$1" == "off" ]; then
    # Check the OpenShift version
    if [[ "$openshift_version" =~ ^4\.15\..* ]]; then
        # Run the command for 4.15 or above
        oc patch storagecluster ocs-storagecluster -n openshift-storage --type json --patch '[{ "op": "replace", "path": "/spec/enableCephTools", "value": false }]'
    else
        # Run the command for 4.14 or below
        oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": false }]'
    fi
else
    # Check the OpenShift version
    if [[ "$openshift_version" =~ ^4\.15\..* ]]; then
        # Run the command for 4.15 or above
        oc patch storagecluster ocs-storagecluster -n openshift-storage --type json --patch '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
    else
        # Run the command for 4.14 or below
        oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
    fi

    TOOLS_POD=""
    echo -n "waiting for ceph tools pod to schedule "
    until [ -n "$TOOLS_POD" ]; do
        echo -n "."
        sleep 5
        TOOLS_POD=$(oc get pod -n openshift-storage -l app=rook-ceph-tools -o name)
    done
    echo "$TOOLS_POD"

    echo "waiting for ceph tools pod to startup"
    oc wait $TOOLS_POD --for=condition=Ready --timeout=300s  -n openshift-storage

    echo "connecting to ceph toolbox"
    oc rsh -n openshift-storage $TOOLS_POD
fi