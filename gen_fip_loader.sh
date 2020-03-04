#!/bin/bash
set -e

function gen_fip_loader()
{

	local soc_name=${1}
	local secure_bin=${2}
	local nonsecure_bin=${3}
	local in=${4}
	local out=${5}

	local fip_sec_size=$(stat --printf="%s" ${secure_bin})
	local fip_nonsec_size=$(stat --printf="%s" ${nonsecure_bin})

	vendor/nexell/tools/SECURE_BINGEN \
		-c ${soc_name} -t 3rdboot \
		-i ${in} \
		-o ${out} \
		-l 0xbfcc0000 -e 0xbfd00800 \
		-k 0 -u -m 0xbfb00000 -z ${fip_sec_size} \
		-m 0xbdf00000 -z ${fip_nonsec_size}
    sync
}

gen_fip_loader ${1} ${2} ${3} ${4} ${5}

