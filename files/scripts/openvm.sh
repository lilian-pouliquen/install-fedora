#!/bin/bash

if [ $# -eq 1 ]; then
	vm_name="$1"
else
	exit 1
fi

virsh --connect "qemu:///system" start "${vm_name}"
remote-viewer --full-screen --title "${vm_name}" "spice://localhost:5900" &
