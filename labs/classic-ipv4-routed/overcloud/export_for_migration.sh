#!/bin/bash

source /home/centos/stackrc
cd /home/centos

# Export overcloud stack networks to network-v2 yaml definition
openstack overcloud network extract --stack overcloud --output /home/centos/overcloud/network_data_v2.yaml

# Export overcloud network Virtual IPs from heat stack to vip yaml definition
openstack overcloud network vip extract --stack overcloud --output /home/centos/overcloud/network_vips_data.yaml

# Export overcloud nodes to baremtal deployment yaml definition
openstack overcloud node extract provisioned --stack overcloud --roles-file /home/centos/overcloud/my_roles_data.yaml --output /home/centos/overcloud/baremetal_deployment.yaml

# Run the network provision command to generate the deployed network env
openstack overcloud network provision --output /home/centos/overcloud/networks-deployed.yaml /home/centos/overcloud/network_data_v2.yaml

# Run the vip provision command to generate the deployed vip env
openstack overcloud network vip provision --stack overcloud --output /home/centos/overcloud/vips-deployed.yaml /home/centos/overcloud/network_vips_data.yaml

# Run the node provision command to generate the deployed baremetal env
openstack overcloud node provision --stack overcloud --network-config --output /home/centos/overcloud/baremetal-deployed.yaml /home/centos/overcloud/baremetal_deployment.yaml

# Fix the templates path
sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud/networks-deployed.yaml
sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud/vips-deployed.yaml
sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud/baremetal-deployed.yaml



