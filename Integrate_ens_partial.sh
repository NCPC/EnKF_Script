#This script is made to integrate your ensemble for half a month (to get centered time w.r.t observation)
#Make sure ${HOMEDIR}/cases/${VERSION}01/${VERSION}01.${machine}.run use correct account number and reasonable time for half a month integration
#Francois Counillon 13/04/2014
source ${HOME}/NorESM/Script/personal_setting.sh

for i in `seq 21 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   #Copy the start date
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   ./${VERSION}${mem}.${machine}.submit
done
