#This script delete all the ensemble member except the member 01
source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 01 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${ARCHIVE}/
   rm -f ${VERSION}${mem}/atm/hist/*.nc
   rm -f ${VERSION}${mem}/ocn/hist/*.nc
   rm -f ${VERSION}${mem}/cpl/hist/*.nc
   rm -f ${VERSION}${mem}/glc/hist/*.nc
   rm -f ${VERSION}${mem}/ice/hist/*.nc
   rm -f ${VERSION}${mem}/ocn/hist/*.nc
done
