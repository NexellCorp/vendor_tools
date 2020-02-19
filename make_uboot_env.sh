#!/bin/bash

set -e

echo >&2 "make_uboot_env.sh startH"

function start_get_fsize()
{
    echo >&2 "start_get_fsize() start"
    local f=$1
    local align=$2
    local fsize=$(ls -al ${f} | awk '{print $5}')
    fsize=$(((${fsize} + ${align} - 1) / ${align}))
    fsize=$((${fsize} * ${align}))
    echo -n ${fsize}
    echo >&2 "fsize : $fsize"
}

function start_get_blocknum_hex()
{
    echo >&2 "start_get_partition_offset() start"
    local value=$1
    local block_size=$2
    local blocknum_hex=$(printf "0x%x" $((${value}/${block_size})))
    echo -n ${blocknum_hex}
    echo >&2 "blocknum_hex : $blocknum_hex"
}

function start_get_partition_offset()
{
    echo >&2 "start_get_partition_offset() start"
    local partmap=$1
    local name=$2
    local offset=$(grep ${name} ${partmap} | awk -F ':' '{print $4}' | awk -F ',' '{print $1}')
    echo -n ${offset}
    echo >&2 "offset : $offset"
}

function start_make_uboot_bootcmd()
{
    echo >&2 "start_make_uboot_bootcmd() start"

    local partmap=$1
    local load_addr=$2
    local page_size=$3
    local kernel=$4
    local dtb_addr=$5
    local ramdisk=$6
    local partname=($7 $8)

    local kernel_start_address=0
    local kernel_start_address_hex=0

    local dtb_start_address=0
    local dtb_start_address_hex=0

    # return array
    local -n bootcmd=$9

    for pn in "${partname[@]}";
    do
        local boot_header_size=${page_size}
        local partition_start_offset=$(start_get_partition_offset ${partmap} ${pn})
        local partition_start_block_num_hex=$(start_get_blocknum_hex ${partition_start_offset} 512)
        local kernel_size=$(start_get_fsize ${kernel} ${page_size})
        local total_size=$((${boot_header_size} + ${kernel_size}  ))
        local total_size_block_num_hex=$(start_get_blocknum_hex ${total_size} 512)
        local var='${change_devicetree}'

        if [ "${TARGET_SOC}" == "s5p4418" ]; then
            if [ ${pn} == "boot_a:emmc" ];then  # slot A
                kernel_start_address=$(start_get_partition_offset ${partmap} "boot_a:emmc")
                kernel_start_address_hex=$(start_get_blocknum_hex ${kernel_start_address} 512)
                dtb_start_address=$(start_get_partition_offset ${partmap} "dtbo_a:emmc")
                dtb_start_address_hex=$(start_get_blocknum_hex ${dtb_start_address} 512)
                bootcmd+=("aboot load_zImage ${kernel_start_address_hex} ${load_addr}; dtimg load_mmc ${dtb_start_address_hex} ${dtb_addr} \$\{board_rev\};if test !-z $var; then run change_devicetree; fi;bootz ${load_addr} - ${dtb_addr}")

            else # slot B
                kernel_start_address=$(start_get_partition_offset ${partmap} "boot_b:emmc")
                kernel_start_address_hex=$(start_get_blocknum_hex ${kernel_start_address} 512)
                dtb_start_address=$(start_get_partition_offset ${partmap} "dtbo_b:emmc")
                dtb_start_address_hex=$(start_get_blocknum_hex ${dtb_start_address} 512)
                bootcmd+=("aboot load_zImage ${kernel_start_address_hex} ${load_addr}; dtimg load_mmc ${dtb_start_address_hex} ${dtb_addr} \$\{board_rev\};if test !-z $var; then run change_devicetree; fi;bootz ${load_addr} - ${dtb_addr}")
            fi
        else
            if [ ${pn} == "boot_a:emmc" ];then  # slot A
                dtb_start_address=$(start_get_partition_offset ${partmap} "dtbo_a:emmc")
                dtb_start_address_hex=$(start_get_blocknum_hex ${dtb_start_address} 512)
                bootcmd+=("aboot load_kernel ${partition_start_block_num_hex} ${load_addr} ; dtimg load_mmc ${dtb_start_address_hex} ${dtb_addr} \$\{board_rev\}; if test !-z $var; then run change_devicetree; fi; bootm ${load_addr} - ${dtb_addr}")
            else # slot B
                dtb_start_address=$(start_get_partition_offset ${partmap} "dtbo_b:emmc")
                dtb_start_address_hex=$(start_get_blocknum_hex ${dtb_start_address} 512)
                bootcmd+=("aboot load_kernel ${partition_start_block_num_hex} ${load_addr}; dtimg load_mmc ${dtb_start_address_hex} ${dtb_addr} \$\{board_rev\}; if test !-z $var; then run change_devicetree; fi; bootm ${load_addr} - ${dtb_addr}")
            fi
        fi
    done

    echo >&2 "bootcmd : $bootcmd"
}

function start_make_uboot_env()
{
    echo >&2 "start_make_uboot_env() start"
    echo >&2 "UBOOT_DIR : $UBOOT_DIR"
    echo >&2 "DEVICE_DIR : $DEVICE_DIR"
    echo >&2 "PARTMAP_TXT : $PARTMAP_TXT"
    echo >&2 "UBOOT_LOAD_ADDR : $UBOOT_LOAD_ADDR"
    echo >&2 "PAGESIZE : $PAGESIZE"
    echo >&2 "KERNEL_IMG : $KERNEL_IMG"
    local UBOOT_BOOTCMD
    local UBOOT_RECOVERY_BOOTCMD
    if [ -f ${UBOOT_DIR}/u-boot.bin ]; then
        test -f ${UBOOT_DIR}/u-boot.bin && \
            start_make_uboot_bootcmd ${DEVICE_DIR}/${PARTMAP_TXT} \
                   ${UBOOT_LOAD_ADDR} \
                   ${PAGESIZE} \
                   ${KERNEL_IMG} \
                    0x49000000 \
                   ${DEVICE_DIR}/ramdisk-not-used \
                   "boot_a:emmc" \
                   "boot_b:emmc" \
                   UBOOT_BOOTCMD

    fi
}


start_make_uboot_env
