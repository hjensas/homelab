# Deploy ovb lab
ovb-deploy \
 --env env-routed-lab.yaml \
 --quintupleo \
 --name quintupleo-ipv6-l3 \
 --id ipv6-l3 \
 --env environments/all-networks.yaml \
 --env env-ipv6-routed.yaml \
 --role env-ipv6-role-leaf1.yaml \
 --role env-ipv6-role-leaf2.yaml

# Build nodes json
./bin/build-nodes-json \
	--env env-routed-lab.yaml \
	--physical_network

OVB_UNDERCLOUD=$(openstack stack show quintupleo-ipv6-l3 -f json -c outputs | jq '.outputs[0].output_value' | sed s/'"'//g)
OVB_UNDERCLOUD_PUBLIC=$(openstack server show undercloud-ipv6-l3 -f json -c addresses | jq '.addresses' | sed s/.*public=// | sed s/\;.*// | sed s/'"'//g)
cat << EOF > inventory.ini
[undercloud]
$OVB_UNDERCLOUD ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC
EOF

ansible-playbook -i inventory.ini ../homelab/labs/playbooks/ssh_hardening.yaml

scp -o StrictHostKeyChecking=no nodes.json centos@$OVB_UNDERCLOUD:~/instackenv.json

DEPLOY_UNDERCLOUD="ansible-playbook -i inventory.ini ../homelab/labs/ovb-ipv6-routed/playbooks//deploy_undercloud.yaml"
DEPLOY_OVERCLOUD="Log into undercloud ($OVB_UNDERCLOUD) and run command: bash ~/overcloud/deploy_overcloud.sh"
echo "###############################################"
echo -e "Undercloud floating IP:\n\t$OVB_UNDERCLOUD"
echo -e "Deploy undercloud:\n\t$DEPLOY_UNDERCLOUD"
echo -e "Deploy overcloud:\n\t$DEPLOY_OVERCLOUD"
echo "###############################################"

