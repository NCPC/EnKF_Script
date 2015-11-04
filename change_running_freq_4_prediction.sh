#This script change the length of the NorESM ensemble integration to 10 years (Typical prediction length)
#Also make sure that CONTINUE_RUN is set to TRUE
source ${HOME}/NorESM/Script/personal_setting.sh
USER=`whoami`
for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   xmlchange -file env_run.xml -id STOP_OPTION -val nyears
   xmlchange -file env_run.xml -id STOP_N -val 10 
   xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
done
