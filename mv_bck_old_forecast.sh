#The forecast file before assimilation are mv in the folder noresm//Old_forecast/
#This script move back the forecast file before assim
source ${HOME}/NorESM/Script/personal_setting.sh
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : date; example 2004-07 "; exit 1 ;}
date=$1
for i in `seq 01 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   mv ${WORKDIR}/Old_forecast/${VERSION}${mem}.micom.r.${date}*.nc  ${WORKDIR}/${VERSION}${mem}/run/
done
