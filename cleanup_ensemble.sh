#This script delete all the ensemble member except the member 01
source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 02 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/cases/
   rm -rf ${VERSION}${mem}
   cd ${WORKDIR}/
   rm -rf ${VERSION}${mem} 
done
