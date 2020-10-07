# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

syn=synpro
#syn=lse
PRJNAME=my
strategy=Timing
radiantdir="${RADIANTDIR:-/opt/lscc/radiant/1.0}"
top="${TOP:-top}"

usage() {
    echo "usage: radiant.sh [args]"
    echo "--syn         synthesis target"
    echo "--strategy    synthesis strategy"
}

ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
    --syn)
        syn=$2
        shift
        shift
        ;;
    --strategy)
        strategy=$2
        shift
        shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo "Unrecognized argument"
        usage
        exit 1
        ;;
    esac
done

if [ -z "$SRCS" ] ; then
    echo "SRCS required"
    exit 1
fi


case "${RADDEV:-up5k-uwg30}" in
    up3k-uwg30)
        iCEPACKAGE="UWG30ITR"
        iCE40DEV="iCE40UP3K"
        ;;
    up5k-sg48)
        iCEPACKAGE="SG48I"
        iCE40DEV="iCE40UP5K"
        ;;
    up5k-uwg30)
        iCEPACKAGE="UWG30ITR"
        iCE40DEV="iCE40UP5K"
        ;;
    *)
        echo "ERROR: Invalid \$RADDEV device config '$RADDEV'."
        exit 1
esac


run_radiant() {
    syn=$1
    SRCS=$2
    #edif=$3

    set -ex

    cat >run.tcl <<EOF
prj_create -name "test1" -impl "test1" -dev $iCE40DEV-$iCEPACKAGE -performance "High-Performance_1.2V" -synthesis "$syn"
prj_set_strategy "$strategy"
EOF

    for f in $SRCS ; do
        echo "prj_add_source \"$f\"" >>run.tcl
    done

    cat >>run.tcl <<EOF
prj_save
prj_run PAR -impl test1
prj_run Export -impl test1
EOF
    #timing -sethld -v 10 -u 10 -endpoints 10  -nperend 1 -html -rpt "test1_test1.twr" "test1_test1.udb"
    #bitgen -w "test1_test1.udb" -f "test1_test1.t2b"

    cat run.tcl | $radiantdir/bin/lin64/radiantc
    cp ./test1/test1_test1.bin my.bin
}

if [ "$syn" = "yosys-synpro" ] ; then
    # Use yosys to create a verilog file using primitives
    mkdir -p impl
    yscript="synth_ice40 -top $TOP; write_verilog impl/impl.v"
    LD_LIBRARY_PATH= "yosys" -p "$yscript" $SRCS

    # Then feed it into a icecube compatible script
    run_radiant "synplify" "impl/impl.v"
# not sure the tcl command and don't care enough to look into
#elif [ "$syn" = "yosys-edif" ] ; then
#    # Use yosys to create a verilog file using primitives
#    mkdir -p impl
#    yscript="synth_ice40 -top $TOP; write_edif -top $TOP impl/impl.edf"
#    LD_LIBRARY_PATH= "yosys" -p "$yscript" $SRCS
#
#    # Then feed it into a icecube compatible script
#    run_radiant "synplify" "" "impl/impl.edf"
else
    run_radiant "$syn" "$SRCS"
fi

