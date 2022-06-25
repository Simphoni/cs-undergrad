#!/usr/bin/env bash
#SBATCH --nodes=1
#BATCH --ntasks-per-node=1

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <executable> <mpi-conf or omp-conf>" >&2
  exit 1
fi

export  DAPL_DBG_TYPE=0

DATAPATH=stencil_data

conf=`cat $2`
$conf $1 7 256 256 256 16  ${DATAPATH}/stencil_data_256x256x256 ${DATAPATH}/stencil_answer_7_256x256x256_16steps
#$conf $1 7 512 512 512 16  ${DATAPATH}/stencil_data_512x512x512 ${DATAPATH}/stencil_answer_7_512x512x512_16steps
#$conf $1 7 768 768 768 16  ${DATAPATH}/stencil_data_768x768x768 ${DATAPATH}/stencil_answer_7_768x768x768_16steps
