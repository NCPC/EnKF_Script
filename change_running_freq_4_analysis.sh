#Creator: Fanf
#Ensure that NorESM integrate for a month, no automatic restart and use restart file
source ${HOME}/NorESM/Script/personal_setting.sh

for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   xmlchange -file env_run.xml -id STOP_OPTION -val nmonth
   xmlchange -file env_run.xml -id STOP_N -val 1 
   xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
   xmlchange -file env_run.xml -id RESUBMIT -val 0
   xmlchange -file env_run.xml -id RESTART -val 0
done
