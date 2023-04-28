#!/bin/bash

if [[ -z $1 ]]; then
	vm_number="00"
else
	vm_number="$1"
fi

remote-viewer --full-screen --title "$label" spice://localhost:59${vm_number}
