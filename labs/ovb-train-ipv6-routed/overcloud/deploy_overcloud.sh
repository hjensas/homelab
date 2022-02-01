#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack tripleo container image prepare default \
  --local-push-destination \
  --output-env-file containers-prepare-parameter.yaml


openstack overcloud deploy --stack overcloud \
  --templates \
  -n /home/centos/overcloud/network_data.yaml \
  -r /home/centos/overcloud/my_roles_data.yaml \
  -e /home/centos/containers-prepare-parameter.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/podman.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-swap.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/centos/overcloud/node_data.yaml

