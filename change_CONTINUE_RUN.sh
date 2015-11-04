#Francois Counillon 6/10/2011
#It assumes that the first Folder has been created and compiled (TO DO this should be verified) 
source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   xmlchange -file env_run.xml -id CONTINUE_RUN -val FALSE
done
