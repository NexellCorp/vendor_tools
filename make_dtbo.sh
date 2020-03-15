#!/bin/bash
set -e

function run_dtb_build()
{
	vendor/nexell/tools/mkdtimg create $@
    sync
}

run_dtb_build $@

