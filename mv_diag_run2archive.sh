#Francois Counillon 6/10/2011
#mv all diag from rundir to archive
source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   mv ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.cam2.h0* ${ARCHIVE}/${VERSION}${mem}/atm/hist/
   mv ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.cice.h* ${ARCHIVE}/${VERSION}${mem}/ice/hist/
   mv ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.h* ${ARCHIVE}/${VERSION}${mem}/ocn/hist/
   mv ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.clm2.h* ${ARCHIVE}/${VERSION}${mem}/lnd/hist/
done
