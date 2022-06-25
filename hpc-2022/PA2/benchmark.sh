# !/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <executable> <mpi-conf or omp-conf>" >&2
  exit 1
fi

export DAPL_DBG_TYPE=0

DATAPATH=stencil_data

conf=`cat $2`
#$conf $1 7 256 256 256 100 ${DATAPATH}/stencil_data_256x256x256
#$conf $1 7 512 512 512 100 ${DATAPATH}/stencil_data_512x512x512
$conf $1 7 768 768 768 100 ${DATAPATH}/stencil_data_768x768x768
