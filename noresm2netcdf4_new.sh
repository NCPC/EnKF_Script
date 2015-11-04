export ACCOUNT=nn9039k
export WALLTIME=04:50:00 
ENS_SIZE=30
IMEM_START=1
IMEM_END=${ENS_SIZE}
for  mem in `seq ${IMEM_START} ${IMEM_END}`
do
   IMEM=$(echo 0$mem | tail -c3 )
   export TEMPDIR=/work/ywang/Conversion/NorCPM_F19_tn21_mem${IMEM}
   /work/shared/noresm/tools/noresm2nc4mpi /work/ywang/archive/NorCPM_F19_tn21_mem${IMEM}
done

