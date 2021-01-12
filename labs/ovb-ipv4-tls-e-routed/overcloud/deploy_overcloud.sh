#!/bin/bash

source /home/cloud-user/stackrc
cd /home/cloud-user

openstack overcloud deploy --templates /home/centos/tripleo-heat-templates \
  -n /home/centos/overcloud/network_data.yaml \
  -r /home/centos/overcloud/roles_data.yaml \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/centos/tripleo-heat-templates/environments/ssl/enable-internal-tls.yaml \
  -e /home/centos/tripleo-heat-templates/environments/ssl/tls-everywhere-endpoints-dns.yaml \
  -e /home/centos/overcloud/node_data.yaml

