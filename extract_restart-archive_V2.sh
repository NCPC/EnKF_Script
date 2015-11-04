#This Script assume that the  file date.tar.gz is already in each sub folder run directory
#This is done by the script on norstore (Transfert_restart.sh) that mv tar.gz file to the corresponding NorESM run folder
#
#This script just extract the tar file
#Note that sometime rpointer are wrong in the tarfile and in such a case  use Change_ens_pointer_date.sh
#TODO We should create a script that pick up the write restart file from norstore and do everything automatically
source ${HOME}/NorESM/Script/personal_setting.sh

IMEM_START=1
IMEM_END=${ENSSIZE}
date=1968-12-15-00000
for mem in `seq ${IMEM_START} ${IMEM_END}`
do
   IMEM=$(echo 0$mem | tail -c3 )
   cd ${WORKDIR}/${VERSION}${IMEM}/run/
   for i in ${ens_casename}${IMEM}*.gz
   do
      gunzip $i
   done
done
