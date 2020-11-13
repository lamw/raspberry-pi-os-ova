#!/bin/bash

# Bootstrap script

set -euo pipefail

if [ -e /root/ran_customization ]; then
    exit
else
    DEBUG=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.debug" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

    if [ ${DEBUG} == "True" ]; then
        LOG_FILE=/var/log/rpi-customization.log
        set -x
        exec 2> ${LOG_FILE}
        echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
    fi

    # Output for debugging
    OVFENV=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv")
    PI_PASSWORD=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.pi_password" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

    echo -e "\e[92mConfiguring pi password ..." > /dev/console
    printf "pi:%s\n" "${PI_PASSWORD}" | sudo /usr/sbin/chpasswd

    IP_ADDRESS=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ipaddress" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NETMASK=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.netmask" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    GATEWAY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.gateway" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_SERVER=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.dns"| awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_DOMAIN=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.domain" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

    ##################################
    ### No User Input, assume DHCP ###
    ##################################
    if [ -z "${IP_ADDRESS}" ]; then
        cat > /etc/dhcpcd.conf << __CUSTOMIZE_RPI__
persistent
option rapid_commit
option interface_mtu
require dhcp_server_identifier
__CUSTOMIZE_RPI__
    #########################
    ### Static IP Address ###
    #########################
    else
        echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console
        cat > /etc/dhcpcd.conf << __CUSTOMIZE_RPI__
persistent
option rapid_commit
option interface_mtu
require dhcp_server_identifier
interface eth0
static ip_address=${IP_ADDRESS}/${NETMASK}
static routers=${GATEWAY}
static domain_name_servers=${DNS_SERVER}
__CUSTOMIZE_RPI__

        echo -e "\e[92mRestarting Network ..." > /dev/console
        systemctl restart dhcpcd
    fi

    # clearing ovf properties
    vmtoolsd --cmd "info-set guestinfo.ovfEnv ' '"

    # Ensure we don't run customization again
    touch /root/ran_customization
fi