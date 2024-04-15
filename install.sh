#!/bin/bash

echo "Doing installation"

wget -qO - https://packages.irods.org/irods-signing-key.asc > /etc/apt/trusted.gpg.d/irods-signing-key.asc

echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list

apt-get update -y

# Basic tools
apt install -y irods-icommands irods-gridftp-client \
    python3-irodsclient ipython3 jupyter-core jupyterhub python-is-python3 python3-pip \
    socat

sed -i.bak 's/^%sudo\s*ALL\=(ALL:ALL)\s*ALL/%sudo  ALL=(ALL)       NOPASSWD: ALL/' /etc/sudoers
useradd -m -G sudo tud -s /bin/bash

mkdir ~tud/.irods

cat <<EOD >> ~tud/.irods/irods_environment.json
{
    "irods_client_server_negotiation": "request_server_negotiation",
    "irods_client_server_policy": "CS_NEG_REQUIRE",
    "irods_encryption_algorithm": "AES-256-CBC",
    "irods_encryption_key_size": 32,
    "irods_encryption_num_hash_rounds": 16,
    "irods_encryption_salt_size": 8,
    "irods_host": "irods.cloud.tudelft.ninja",
    "irods_port": 1247,
    "irods_ssl_ca_certificate_file": "",
    "irods_ssl_certificate_chain_file": "",
    "irods_ssl_certificate_key_file": "",
    "irods_ssl_dh_params_file": "",
    "irods_ssl_verify_server": "hostname",
    "irods_zone_name": "tudcloud"
}
EOD

cat << EOD >> /etc/wsl.conf
[user]
default=tud

[network]
hostname=tudelft
EOD

