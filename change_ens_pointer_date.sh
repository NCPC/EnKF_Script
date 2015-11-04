#Recreate the ensemble of pointer files with the start_date from the run directory
source ${HOME}/NorESM/Script/personal_setting.sh
[ $# -ne 1 ] &&  { echo "Must be called with 1 args -date; example:1995-01-15  "; exit 1 ; }
startdate=$1
for mem in `seq 1 ${ENSSIZE}`
do
    imem=$(echo 0$mem | tail -c3 )
    cat ${WORKSHARED}/Input/NorESM/rpointer.atm_mal | sed  "s/MM/${imem}/" | sed  "s/XXXX-XX-XX/${startdate}/" > ${WORKDIR}/${VERSION}${imem}/run/rpointer.atm
    cat ${WORKSHARED}/Input/NorESM/rpointer.ocn_mal | sed  "s/MM/${imem}/" | sed  "s/XXXX-XX-XX/${startdate}/" > ${WORKDIR}/${VERSION}${imem}/run/rpointer.ocn
    cat ${WORKSHARED}/Input/NorESM/rpointer.ice_mal | sed  "s/MM/${imem}/" | sed  "s/XXXX-XX-XX/${startdate}/" > ${WORKDIR}/${VERSION}${imem}/run/rpointer.ice
    cat ${WORKSHARED}/Input/NorESM/rpointer.lnd_mal | sed  "s/MM/${imem}/" | sed  "s/XXXX-XX-XX/${startdate}/" > ${WORKDIR}/${VERSION}${imem}/run/rpointer.lnd
    cat ${WORKSHARED}/Input/NorESM/rpointer.drv_mal | sed  "s/MM/${imem}/" | sed  "s/XXXX-XX-XX/${startdate}/" > ${WORKDIR}/${VERSION}${imem}/run/rpointer.drv
done
