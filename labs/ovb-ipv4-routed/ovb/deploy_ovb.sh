# Deploy ovb lab
ovb-deploy \
	--env env-routed-lab.yaml \
	--quintupleo \
	--env environments/all-networks.yaml \
	--env env-custom-registry.yaml \
	--role env-role-leaf1.yaml \
	--role env-role-leaf2.yaml

# Build nodes json
./bin/build-nodes-json \
	--env env-routed-lab.yaml \
	--physical_network

OVB_UNDERCLOUD=$(openstack stack show quintupleo -f json -c outputs | jq '.outputs[0].output_value' | sed s/'"'//g)
OVB_UNDERCLOUD_PUBLIC=$(openstack server show undercloud -f json -c addresses | jq '.addresses' | sed s/.*public=// | sed s/\"//)
cat << EOF > inventory.ini
[undercloud]
$OVB_UNDERCLOUD ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC
EOF

ansible-playbook -i inventory.ini ../ooo-bp-tripleo-routed-networks-templates-testing/playbooks/ssh_hardening.yaml

scp -o StrictHostKeyChecking=no nodes.json centos@$OVB_UNDERCLOUD:~/instackenv.json

DEPLOY_UNDERCLOUD="ansible-playbook -i inventory.ini ../ooo-bp-tripleo-routed-networks-templates-testing/playbooks/deploy_undercloud.yaml"
DEPLOY_OVERCLOUD="Log into undercloud ($OVB_UNDERCLOUD) and run command: bash ~/overcloud/deploy_overcloud.sh"
echo "###############################################"
echo -e "Undercloud floating IP:\n\t$OVB_UNDERCLOUD"
echo -e "Deploy undercloud:\n\t$DEPLOY_UNDERCLOUD"
echo -e "Deploy overcloud:\n\t$DEPLOY_OVERCLOUD"
echo "###############################################"

