#This script is made to integrate your ensemble for half a month (to get centered time w.r.t observation)
#Make sure ${HOMEDIR}/cases/${VERSION}01/${VERSION}01.${machine}.run use correct account number and reasonable time for half a month integration
#Francois Counillon 13/04/2014
startdate_exp=1992-01-15-00000
source ${HOME}/NorESM/Script/personal_setting.sh

for i in `seq 20 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   #Copy the start date
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   xmlchange -file env_run.xml -id STOP_OPTION -val nyears
   xmlchange -file env_run.xml -id STOP_N -val 10 
   xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
   xmlchange -file env_run.xml -id RESUBMIT -val 0
   xmlchange -file env_run.xml -id RESTART -val 0
   cat ${HOMEDIR}/cases/${VERSION}01/${VERSION}01.${machine}.run | sed "s/mem01/mem${mem}/"> toto
   mv toto   ${HOMEDIR}/cases/${VERSION}${mem}/${VERSION}${mem}.${machine}.run
   ./${VERSION}${mem}.${machine}.submit
done
