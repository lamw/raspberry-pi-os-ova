#!/bin/bash

RPI_OS_VM_NAME="RaspberryPi-OS-BUSTER-ARM64-2020-05-27"
VCENTER_HOSTNAME="192.168.30.200"
VCENTER_DATACENTER="Arm-Datacenter"
VCENTER_USERNAME="administrator@vsphere.local"
VCENTER_PASSWORD="VMware1!"

ovftool "vi://${VCENTER_USERNAME}:${VCENTER_PASSWORD}@${VCENTER_HOSTNAME/${}/vm/${RPI_OS_VM_NAME}" ${RPI_OS_VM_NAME}.ovf
rm -f ${RPI_OS_VM_NAME}.mf
sed -i .bak1 's/<VirtualHardwareSection>/<VirtualHardwareSection ovf:transport="com.vmware.guestInfo">/g' ${RPI_OS_VM_NAME}.ovf
sed -i .bak2 "/    <\/VirtualHardwareSection>/ r rpi_ovf_template.xml" ${RPI_OS_VM_NAME}.ovf
ovftool ${RPI_OS_VM_NAME}.ovf ${RPI_OS_VM_NAME}.ova