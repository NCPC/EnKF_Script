#Francois Counillon 6/10/2011
#Copy macro from mem01
source ${HOME}/NorESM/Script/personal_setting.sh

for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cp ${HOMEDIR}/cases/${VERSION}01/Macros.${machine} ${HOMEDIR}/cases/${VERSION}${mem}
done
