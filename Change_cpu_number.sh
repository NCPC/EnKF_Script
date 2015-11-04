#!/bin/bash
set -ex
#This script will create an ensemble of folder of Noresm without duplicating Build directory.
#Francois Counillon 6/10/2011
source ${HOME}/NorESM/Script/personal_setting.sh
#Prepare member 1
#cd ${HOMEDIR}/cases/${VERSION}01
##Avoid saving log file in your home folder
#cp /work/ingo/env_mach_pes.xml_NorESM1-ME_64cpus env_mach_pes.xml
#xmlchange -file env_run.xml -id LOGDIR -val ${WORKDIR}${VERSION}01/logs
##Possible that you wish to integrate for 14 days for moving restart in the middle of the month
##Assume also that assim cycle is 1 month here
#xmlchange -file env_run.xml -id STOP_OPTION -val nmonth
#xmlchange -file env_run.xml -id STOP_N -val 1
#xmlchange -file env_run.xml -id RESUBMIT -val 0
#xmlchange -file env_run.xml -id RESTART -val 0
#if ((${hybrid_run})) ; then
   #xmlchange -file env_run.xml -id CONTINUE_RUN -val FALSE
   #xmlchange -file env_conf.xml -id RUN_TYPE -val hybrid
   #if ((${hist_start})) ; then
      #echo "Not yet implemented"; exit 0;
   #elif ((${ens_start})) ; then
      #short_ens_start_date=`echo $ens_start_date | cut -c1-10`
      #xmlchange -file env_conf.xml -id RUN_STARTDATE -val $short_start_date
      #xmlchange -file env_conf.xml -id RUN_REFDATE -val $short_ens_start_date
      #xmlchange -file env_conf.xml -id RUN_REFCASE -val ${ens_casename}01
      #if ((${ens_casename}==${CASEDIR})); then
         #xmlchange -file env_conf.xml -id BRNCH_RETAIN_CASENAME -val TRUE
      #fi
   #fi
#else
   #xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
#fi   
#configure -case
#sed -i s/"PBS -N ".*/"PBS -N NorCPM01"/g          ${VERSION}01.${machine}.run
#sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     ${VERSION}01.${machine}.run
#sed -i s/"PBS -l walltime".*/"PBS -l walltime=00:55:00"/g ${VERSION}01.${machine}.run
#cd ${HOMEDIR}/cases/${VERSION}01/Buildconf/
#sed -i s/" RSTCMP   =".*/" RSTCMP   = 0"/g micom.buildnml.csh
#sed -i s/"mfilt".*/"mfilt     = 1"/g cam.buildnml.csh
#sed -i s/"nhtfrq".*/"nhtfrq    = 0"/g cam.buildnml.csh
#sed -i s/" fincl2".*/"fincl2     = ' '"/g cam.buildnml.csh
#sed -i s/"ncdata".*/"ncdata = ${ifile_casename}01.cam2.i.${ifile_date}.nc "/g cam.input_data_list
#sed -i s/"ncdata".*/"ncdata     = '${ifile_casename}01.cam2.i.${ifile_date}.nc'"/g cam.buildnml.csh 
#sed -i s/"ncdata".*/"ncdata  = '${ifile_casename}01.cam2.i.${ifile_date}.nc'"/g camconf/ccsm_namelist
##sed -i "/ncdata/ c\ ncdata    = '${ens_casename}01.cam2.i.${branched_ens_date}.nc'" cam.buildnml.csh
##sed -i '/ncdata/d'  cam.buildnml.csh
#
#cd ${HOMEDIR}/cases/${VERSION}01/
#echo "Compiling the code, this will take some time"
#${VERSION}01.${machine}.build
#echo "Copying and extracting restart file"
#
##TODO copy restart and pointer
#mkdir -p  ${rest_path}
#[ ! -f ${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz ] && { echo "Could not find restart file
#${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz; Look in Norstore " ; exit 1 ; }
#cp  -f ${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz ${rest_path}
#cd ${rest_path}
#tar -xvof ${rest_path}/${VERSION}_restart_${start_date}.tar.gz 
#mv ${rest_path}/${VERSION}01/rest/${start_date}/* ${WORKDIR}/${VERSION}01/run/
cd ${WORKDIR}/${VERSION}01/run/
tar -xvof 1952-12-15-00000.tar.gz
mv 1952-12-15-00000/* .
#
#
#
#echo "Prepare the rest of the members"
for i in `seq 2 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/cases/${VERSION}${mem}
   cp -f ${HOMEDIR}/cases/${VERSION}01/env_mach_pes.xml .
   configure -cleanmach
   configure -case
   sed '/ccsm_buildexe/d' ${VERSION}${mem}.${machine}.build > toto
   mv toto ${VERSION}${mem}.${machine}.build
   chmod 755 ${VERSION}${mem}.${machine}.build 
   rm -f ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/cam.buildnml.csh 
   cat ${HOMEDIR}/cases/${VERSION}01/Buildconf/cam.buildnml.csh | sed  "s/mem01/mem${mem}/" > ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/cam.buildnml.csh
   chmod 755 ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/cam.buildnml.csh
   rm -f ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   cat ${HOMEDIR}/cases/${VERSION}01/Buildconf/clm.buildnml.csh | sed  "s/mem01/mem${mem}/" > ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   chmod 755 ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   cp ${HOMEDIR}/cases/${VERSION}01/Buildconf/micom.buildnml.csh  ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/micom.buildnml.csh
   chmod 755  ${HOMEDIR}/cases/${VERSION}${mem}/Buildconf/micom.buildnml.csh
   ${VERSION}${mem}.${machine}.build
   cat env_build.xml | sed  's/id="BUILD_COMPLETE"   value="FALSE"/id="BUILD_COMPLETE"   value="TRUE"/' > toto
   mv toto env_build.xml
   sed -i s/"PBS -N ".*/"PBS -N ${VERSION}${mem}"/g  ${VERSION}${mem}.${machine}.run
   sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     ${VERSION}${mem}.${machine}.run
   sed -i s/"PBS -l walltime".*/"PBS -l walltime=00:55:00"/g ${VERSION}${mem}.${machine}.run

   echo 'Now setting up the work dir'
   cd ${WORKDIR}/${VERSION}${mem} 
   cp ${WORKDIR}/${VERSION}01/${VERSION}01.ccsm.exe ${WORKDIR}/${VERSION}${mem}/${VERSION}${mem}.ccsm.exe
   cp ${WORKDIR}/${VERSION}01/run/ccsm.exe ${WORKDIR}/${VERSION}${mem}/run/ccsm.exe
   cp ${WORKDIR}/${VERSION}01/run/ccsm.exe ${WORKDIR}/${VERSION}${mem}/run/ccsm.exe
   cd ${WORKDIR}/${VERSION}${mem}/run/
   tar -xvof 1952-12-15-00000.tar.gz
   mv 1952-12-15-00000/* .
done
