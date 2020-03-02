#!/bin/bash
set -e

# args
# $1: total size(must dividable by 512)
# $2: bl1 file path
# $3: loader offset
# $4: loader file path
# $5: secure offset
# $6: secure file path
# $7: non-secure offset
# $8: non-secure file path
# $9: param offset
# $10: param file path
# $11: logo offset
# $12: logo file path
# $13: outfile path
function make_bootloader()
{
    local total_size=${1}
    local loader=${2}
    local secure_offset=${3}
    local secure=${4}
    local nonsecure_offset=${5}
    local nonsecure=${6}
    local param_offset=${7}
    local param=${8}
    local logo_offset=${9}
    local logo=${10}
    local out=${11}

    test -f ${out} && rm -f ${out}

    echo "total_size --> ${total_size}"
    echo "loader --> ${loader}"
    echo "secure_offset --> ${secure_offset}"
    echo "secure --> ${secure}"
    echo "nonsecure_offset --> ${nonsecure_offset}"
    echo "nonsecure --> ${nonsecure}"
    echo "param_offset --> ${param_offset}"
    echo "param --> ${param}"
    echo "logo_offset --> ${logo_offset}"
    echo "logo --> ${logo}"
    echo "out --> ${out}"

    local count_by_512=$((${total_size}/512))
    echo "=========================="
    echo ${count_by_512}
    dd if=/dev/zero of=${out} bs=512 count=${count_by_512}
    dd if=${loader} of=${out} bs=1
    dd if=${secure} of=${out} seek=${secure_offset} bs=1
    dd if=${nonsecure} of=${out} seek=${nonsecure_offset} bs=1
    dd if=${param} of=${out} seek=${param_offset} bs=1
    dd if=${logo} of=${out} seek=${logo_offset} bs=1

    #Zero padding
    out_size=`du -b "${out}" | cut -f1`
    diffsize=$((${total_size}-${out_size}))
    echo "${out} file size = ${out_size}"
    echo "add zero pad ${diffsize} byte"
    dd if=/dev/zero bs=1 count=${diffsize} >> ${out}

    sync
}

make_bootloader ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11}

