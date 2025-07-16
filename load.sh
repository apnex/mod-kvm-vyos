## information about automating config
# https://docs.vyos.io/en/latest/automation/cloud-init.html

ADDRESS=$(terraform output -raw domain_address)
CONFIG_FILE=${1}

if [[ -n ${CONFIG_FILE} ]]; then

scp ${CONFIG_FILE} vyos@${ADDRESS}:~/
ssh -o "StrictHostKeyChecking=no" vyos@${ADDRESS} 'vbash -s' <<-EOF
	source /opt/vyatta/etc/functions/script-template
	source ~/${CONFIG_FILE}
	commit
	save
EOF
else
	echo "Please specify CONFIG_FILE"
fi
