#What is this script doing ? 

source ${HOME}/NorESM/Script/personal_setting.sh

for i in `seq 2 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cp ${WORKDIR}/${VERSION}01/run/ocn_in ${WORKDIR}/${VERSION}${mem}/run/ocn_in
done
