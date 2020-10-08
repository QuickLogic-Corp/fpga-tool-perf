#!/bin/bash
#
# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

if [ -z "${FPGA_TOOL_PERF_BASE_DIR}" ]; then
    export FPGA_TOOL_PERF_BASE_DIR=$(pwd)
fi
if [ -z "${VIVADO_SETTINGS}" ]; then
    echo "WARNING: using default vivado settings"
    #FIXME: to use the conda xilinx-vivado virtual package when available
    export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2017.2/settings64.sh
fi
if [ -z "${SYMBIFLOW}" ]; then
    echo "WARNING: using default symbiflow dir."
    export SYMBIFLOW=${FPGA_TOOL_PERF_BASE_DIR}/env/symbiflow
fi
if [ -z "${QUICKLOGIC}" ]; then
    echo "WARNING: using default quicklogic dir."
    export QUICKLOGIC=${FPGA_TOOL_PERF_BASE_DIR}/env/quicklogic
fi

#https://unix.stackexchange.com/a/291611
function path_remove {
  # Delete path by parts so we can never accidentally remove sub paths
  PATH=${PATH//":$1:"/":"} # delete any instances in the middle
  PATH=${PATH/#"$1:"/} # delete any instance at the beginning
  PATH=${PATH/%":$1"/} # delete any instance in the at the end
}

#Remove all possible paths from PATH
path_remove ${SYMBIFLOW}/bin
path_remove ${SYMBIFLOW}-a200t/bin
path_remove ${QUICKLOGIC}/install/bin

#Set now environment variables
environment=${1:-xilinx-a35t}

if [ "quicklogic" == ${environment} ]; then
    . ${FPGA_TOOL_PERF_BASE_DIR}/env/conda/bin/activate quicklogic
    export PATH=${QUICKLOGIC}/install/bin:${PATH}
elif [ "xilinx-a200t" == ${environment} ]; then
    . ${FPGA_TOOL_PERF_BASE_DIR}/env/conda/bin/activate fpga-tool-perf-env
    export SYMBIFLOW=${FPGA_TOOL_PERF_BASE_DIR}/env/symbiflow-a200t
    export PATH=${SYMBIFLOW}/bin:${PATH}
else
    . ${FPGA_TOOL_PERF_BASE_DIR}/env/conda/bin/activate fpga-tool-perf-env
    export SYMBIFLOW=${FPGA_TOOL_PERF_BASE_DIR}/env/symbiflow
    export PATH=${SYMBIFLOW}/bin:${PATH}
fi
