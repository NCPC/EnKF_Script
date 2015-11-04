#This script is Cleaning up file that are already converted into netcdf4 (present in BACKUP FOLDER)
#The coneversion script is noresm2netcdf4_all.pbs
#
set -ex
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : path of the forlder where converted files are stored "; exit 1 ; }
BACKUP_CONVERSION_FOLDER=$1
source ${HOME}/NorESM/Script/personal_setting.sh
IMEM_START=1
IMEM_END=${ENSSIZE}
for mem in `seq ${IMEM_START} ${IMEM_END}`
do
  IMEM=$(echo 0$mem | tail -c3 )
  if [ -d  ${1}/${VERSION}${IMEM}/ ]; then
     cd ${BACKUP_CONVERSION_FOLDER}/${VERSION}${IMEM}/
     for elm in ocn atm ice lnd
     do
        if [ -d  ${BACKUP_CONVERSION_FOLDER}/${VERSION}${IMEM}/${elm}/hist ] ;then
          target=${BACKUP_CONVERSION_FOLDER}/${VERSION}${IMEM}/${elm}/hist/
          if test "$(ls -A "$target")"; then #Not empty dir
          cd $target
             for i in  *.nc
               do
                  echo "${ARCHIVE}/${VERSION}${IMEM}/${elm}/hist/${i}" >>/work/${USER}/File_deleted
                  rm -f ${ARCHIVE}/${VERSION}${IMEM}/${elm}/hist/${i}
               done
         fi
        fi
     done
  fi
  cd ${BACKUP_CONVERSION_FOLDER}/${VERSION}${IMEM}/rest
  for i in `ls -1 *0000.tar.gz`
  do
    echo $i 
    rm -rf ${ARCHIVE}/${VERSION}${IMEM}/rest/$(basename $i \.tar.gz)
  done
  cd ..

done
