#!/bin/bash

ADDRESS=$(terraform output -raw domain_address)
echo "[ ${ADDRESS} ]"
ssh \
	-o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null \
vyos@${ADDRESS}
