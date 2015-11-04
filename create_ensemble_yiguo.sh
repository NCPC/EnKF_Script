#!/bin/bash
set -ex
#This script will create an ensemble of folder of Noresm without duplicating Build directory.
#Francois Counillon 6/10/2011
source ${HOME}/NorESM/Script/personal_setting.sh
let tmp_date=hist_start_date+hist_freq_date
hist_mem_date=`echo 000$tmp_date | tail -5c`
hist_mem01_date=`echo 000$hist_start_date | tail -5c`
#Generate the script to convert output to netcdf4
cd ${HOMEDIR}/cases/${VERSION}01
#Assume also that assim cycle is 1 month here
xmlchange -file env_run.xml -id STOP_OPTION -val nmonth
xmlchange -file env_run.xml -id STOP_N -val 1
xmlchange -file env_run.xml -id RESUBMIT -val 0
xmlchange -file env_run.xml -id RESTART -val 0
xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
sed -i s/"PBS -N ".*/"PBS -N NorCPM01"/g          ${VERSION}01.${machine}.run
sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     ${VERSION}01.${machine}.run
sed -i s/"PBS -l walltime".*/"PBS -l walltime=00:45:00"/g ${VERSION}01.${machine}.run
cd ${rest_path}
mv ${rest_path}/${VERSION}01/rest/${start_date}/* ${WORKDIR}/${VERSION}01/run/

echo "Prepare the rest of the members"
for i in `seq 2 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/${CODEVERSION}/scripts/
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   ${VERSION}${mem}.${machine}.build
   cat env_build.xml | sed  's/id="BUILD_COMPLETE"   value="FALSE"/id="BUILD_COMPLETE"   value="TRUE"/' > toto
   mv toto env_build.xml
   echo 'Now setting up the work dir'
   cd ${WORKDIR}/${VERSION}${mem} 
   rm -rf atm cpl glc ice lib lnd ocn ccsm mct csm_share pio
   ln -s ${WORKDIR}/${VERSION}01/atm ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/cpl ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/ccsm ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/csm_share ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/glc ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/ice ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/lib ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/lnd ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/mct ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/pio ${WORKDIR}/${VERSION}${mem}
   ln -s ${WORKDIR}/${VERSION}01/ocn ${WORKDIR}/${VERSION}${mem}
   cp ${WORKDIR}/${VERSION}01/${VERSION}01.ccsm.exe ${WORKDIR}/${VERSION}${mem}/${VERSION}${mem}.ccsm.exe
   cp -r  ${WORKDIR}/${VERSION}01/run ${WORKDIR}/${VERSION}${mem}/
   cp ${WORKDIR}/${VERSION}01/run/ccsm.exe ${WORKDIR}/${VERSION}${mem}/run/ccsm.exe
   if (( ${ens_start} )) ; then
      mv ${rest_path}/${VERSION}${mem}/rest/${start_date}/* ${WORKDIR}/${VERSION}${mem}/run/
   fi
done
echo 'The Ensemble structure is created successfully'
