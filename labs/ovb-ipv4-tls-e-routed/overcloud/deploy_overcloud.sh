#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud deploy --templates /home/cloud-user/tripleo-heat-templates \
  -n /home/cloud-user/overcloud/network_data.yaml \
  -r /home/cloud-user/overcloud/roles_data.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/ssl/enable-internal-tls.yaml \
  -e /home/cloud-user/tripleo-heat-templates/environments/ssl/tls-everywhere-endpoints-dns.yaml \
  -e /home/cloud-user/overcloud/node_data.yaml

