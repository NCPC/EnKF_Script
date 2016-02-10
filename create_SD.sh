#!/bin/bash
set -ex
#This script will create an ensemble of folder of Noresm without duplicating Build directory.
#Francois Counillon 6/10/2011
source ${HOME}/NorESM/EnKF_Script/personal_SD_setting.sh
if [ -d ${HOMEDIR}/cases/${VERSION}01 ]
then
   echo "There is already an Ensemble structure existing for " $VERSION
   echo "We cannot overwrite it"
   echo "please clean it first using :"
   echo "${HOMEDIR}/Script/cleanup_ensemble.sh"
   echo "and"
   echo "${HOMEDIR}/Script/cleanup_single_mem.sh 1"
   echo "We quit"
   exit 1
fi
let tmp_date=hist_start_date+hist_freq_date
hist_mem_date=`echo 000$tmp_date | tail -5c`
hist_mem01_date=`echo 000$hist_start_date | tail -5c`
#Generate the script to convert output to netcdf4
cat ${WORKSHARED}/Input/NorESM/norcpm2netcdf4_all.pbs_mal | sed "s/V.E.R.S.I.O.N/${VERSION}/" \
| sed "s/E.N.S/${ENSSIZE}/" > ${HOMEDIR}/Script/norcpm2netcdf4.pbs

#Prepare member 1
cd ${HOMEDIR}/${CODEVERSION}/scripts
create_newcase -case ${HOMEDIR}/cases/${ParentP}/${VERSION}01 -compset ${COMPSET} -res ${RES} -mach ${machine}
cd ${HOMEDIR}/cases/${ParentP}/${VERSION}01
#Avoid saving log file in your home folder
xmlchange -file env_run.xml -id LOGDIR -val ${WORKDIR}/${VERSION}01/logs
#Possible that you wish to integrate for 14 days for moving restart in the middle of the month
#Assume also that assim cycle is 1 month here
xmlchange -file env_run.xml -id STOP_OPTION -val nmonth
xmlchange -file env_run.xml -id STOP_N -val 1
xmlchange -file env_run.xml -id RESUBMIT -val 0
xmlchange -file env_run.xml -id RESTART -val 0
xmlchange -file env_conf.xml -id CAM_CONFIG_OPTS -val '-phys cam4 -scen_rcp rcp85 -offline_dyn '


#Avoid saving log file in your home folder
xmlchange -file env_run.xml -id LOGDIR -val ${WORKDIR}/${VERSION}01/logs
xmlchange -file env_build.xml -id EXEROOT -val ${WORKDIR}/${VERSION}01
xmlchange -file env_run.xml -id DOUT_S_ROOT -val ${ARCHIVE}/${VERSION}01



if ((${hybrid_run})) ; then
   xmlchange -file env_run.xml -id CONTINUE_RUN -val FALSE
   xmlchange -file env_conf.xml -id RUN_TYPE -val branch
   if ((${hist_start})) ; then
      echo "Not yet implemented"; exit 0;
   elif ((${ens_start})) ; then
      short_ens_start_date=`echo $ens_start_date | cut -c1-10`
      xmlchange -file env_conf.xml -id RUN_STARTDATE -val $short_start_date
      xmlchange -file env_conf.xml -id RUN_REFDATE -val $short_ens_start_date
      xmlchange -file env_conf.xml -id RUN_REFCASE -val ${ens_casename}01
      if ((${ens_casename}==${CASEDIR})); then
         xmlchange -file env_conf.xml -id BRNCH_RETAIN_CASENAME -val TRUE
      fi
   fi
else
   xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
fi   
configure -case
#cd ..
sed -i s/"PBS -N ".*/"PBS -N NorCPM01"/g          ${VERSION}01.${machine}.run
sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     ${VERSION}01.${machine}.run
sed -i s/"PBS -l walltime".*/"PBS -l walltime=00:45:00"/g ${VERSION}01.${machine}.run
cd ${HOMEDIR}/cases/${ParentP}/${VERSION}01/Buildconf/
sed -i s/" RSTCMP   =".*/" RSTCMP   = 0"/g micom.buildnml.csh
sed -i s/"mfilt".*/"mfilt     = 1"/g cam.buildnml.csh
sed -i s/"nhtfrq".*/"nhtfrq    = 0"/g cam.buildnml.csh
sed -i s/" fincl2".*/"fincl2     = ' '"/g cam.buildnml.csh


sed -i s/"ncdata".*/"ncdata = ${ens_casename}01.cam2.i.${branched_ens_date}.nc "/g cam.input_data_list
sed -i s/"ncdata".*/"ncdata     = '${ens_casename}01.cam2.i.${branched_ens_date}.nc'"/g cam.buildnml.csh
sed -i s/"finidat".*/"finidat     = '${ens_casename}01.clm2.r.${ens_start_date}.nc'"/g clm.buildnml.csh
sed -i s/"finidat".*/"finidat = '${ens_casename}01.clm2.r.${ens_start_date}.nc' "/g clm.input_data_list
sed -i s/"ice_ic".*/"ice_ic     = '${ens_casename}01.cice.r.${ens_start_date}.nc'"/g cice.buildnml.csh
insertLN=`grep -n "nhtfrq" cam.buildnml.csh | awk -F ":" '{print $1}' `

cp /home/uib/earnest/NorESM/EnKF_Script/CAML26_nudging_namelist CAML26_nudging_namelist
yyCAM=`echo ${start_date} | awk -F "-" '{print $1}'`
mmCAM=`echo ${start_date} | awk -F "-" '{print $2}'`
sed -i s/"#nuYEAR"/"${yyCAM}"/g CAML26_nudging_namelist
sed -i s/"#nuMONTH"/"${mmCAM}"/g CAML26_nudging_namelist

met_path=`echo "${metdata_path}" | sed 's/\//\\\\\//g'`
sed -i s/"#nuPath"/"${met_path}"/g CAML26_nudging_namelist
sed -i s/"#CAM_Max_rlx"/"${CAM_Max_rlx}"/g CAML26_nudging_namelist

sed -i "${insertLN} r CAML26_nudging_namelist" cam.buildnml.csh
cp /home/uib/earnest/NorESM/EnKF_Script/CAMnudging_metdata.F90 ${HOMEDIR}/cases/${ParentP}/${VERSION}01/SourceMods/src.cam/metdata.F90
cp /home/uib/earnest/NorESM/EnKF_Script/CAMnudging_cam_comp.F90 ${HOMEDIR}/cases/${ParentP}/${VERSION}01/SourceMods/src.cam/cam_comp.F90

cp /home/uib/earnest/NorESM/EnKF_Script/CAMnudging_runtime_opts.F90 ${HOMEDIR}/cases/${ParentP}/${VERSION}01/SourceMods/src.cam/runtime_opts.F90

#
############################################################################


cd ${HOMEDIR}/cases/${ParentP}/${VERSION}01/
echo "Compiling the code, this will take some time"
${VERSION}01.${machine}.build
echo "Copying and extracting restart file"

#TODO copy restart and pointer
mkdir -p  ${rest_path}
#[ ! -f ${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz ] && { echo "Could not find restart file
#${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz; Look in Norstore " ; exit 1 ; }
#cp  -f ${WORKSHARED}/Restart/${VERSION}_restart_${start_date}.tar.gz ${rest_path}
#cd ${rest_path}
#tar -xvof ${rest_path}/${VERSION}_restart_${start_date}.tar.gz 
cp -f ${rest_path}/${ParentP}/${VERSION}01/rest/${start_date}/* ${WORKDIR}/${VERSION}01/run/



echo "Prepare the rest of the members"
for i in `seq 2 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cd ${HOMEDIR}/${CODEVERSION}/scripts/
   create_newcase -case ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem} -compset ${COMPSET} -res ${RES} -mach  ${machine}
   cd ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}
   cat ${HOMEDIR}/cases/${ParentP}/${VERSION}01/env_conf.xml | sed  "s/mem01/mem${mem}/" > toto
      mv toto env_conf.xml
   cat ${HOMEDIR}/cases/${ParentP}/${VERSION}01/env_run.xml | sed  "s/mem01/mem${mem}/" > toto
      mv toto env_run.xml
   cat ${HOMEDIR}/cases/${ParentP}/${VERSION}01/env_build.xml | sed  "s/mem01/mem${mem}/" > toto
      mv toto env_build.xml

#   if (( ${ens_start} )) ; then
#      #configure -cleannamelist
#      cat env_conf.xml | sed  "s/mem01/mem${mem}/" > toto
#      mv toto env_conf.xml
#      elseif (( ${hist_start} )) ; then
#      #configure -cleannamelist
#      cat env_conf.xml | sed  "s/${hist_mem01_date}/${hist_mem_date}/" > toto
#      mv toto env_conf.xml
#   fi
   configure -case
   sed '/ccsm_buildexe/d' ${VERSION}${mem}.${machine}.build > toto
   mv toto ${VERSION}${mem}.${machine}.build
   chmod 755 ${VERSION}${mem}.${machine}.build 
   rm -f ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/cam.buildnml.csh 
   cat ${HOMEDIR}/cases/${ParentP}/${VERSION}01/Buildconf/cam.buildnml.csh | sed  "s/mem01/mem${mem}/" | sed  "s/mem01/mem${mem}/" > ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/cam.buildnml.csh
   chmod 755 ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/cam.buildnml.csh
   rm -f ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   cat ${HOMEDIR}/cases/${ParentP}/${VERSION}01/Buildconf/clm.buildnml.csh | sed  "s/mem01/mem${mem}/" | sed  "s/mem01/mem${mem}/" > ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   chmod 755 ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/clm.buildnml.csh
   cp ${HOMEDIR}/cases/${ParentP}/${VERSION}01/Buildconf/micom.buildnml.csh  ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/micom.buildnml.csh
   chmod 755  ${HOMEDIR}/cases/${ParentP}/${VERSION}${mem}/Buildconf/micom.buildnml.csh
   ${VERSION}${mem}.${machine}.build
   cat env_build.xml | sed  's/id="BUILD_COMPLETE"   value="FALSE"/id="BUILD_COMPLETE"   value="TRUE"/' > toto
   mv toto env_build.xml
   sed -i s/"PBS -N ".*/"PBS -N ${VERSION}${mem}"/g  ${VERSION}${mem}.${machine}.run
   sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     ${VERSION}${mem}.${machine}.run
   sed -i s/"PBS -l walltime".*/"PBS -l walltime=00:45:00"/g ${VERSION}${mem}.${machine}.run

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
      rm -f ${WORKDIR}/${VERSION}${mem}/run/*.nc
      cp ${rest_path}/${ParentP}/${VERSION}${mem}/rest/${start_date}/* ${WORKDIR}/${VERSION}${mem}/run/
#      cp ${ens_path}/${ens_date}/${ens_casename}${mem}*.nc ${WORKDIR}/${VERSION}${mem}/run/
#      cat ${ens_path}/${ens_date}/rpointer.atm | sed  "s/mem01/mem${mem}/" > ${WORKDIR}/${VERSION}${mem}/run/rpointer.atm
#      cat ${ens_path}/${ens_date}/rpointer.drv | sed  "s/mem01/mem${mem}/" > ${WORKDIR}/${VERSION}${mem}/run/rpointer.drv
#      cat ${ens_path}/${ens_date}/rpointer.ice | sed  "s/mem01/mem${mem}/" > ${WORKDIR}/${VERSION}${mem}/run/rpointer.ice
#      cat ${ens_path}/${ens_date}/rpointer.lnd | sed  "s/mem01/mem${mem}/" > ${WORKDIR}/${VERSION}${mem}/run/rpointer.lnd
#      cat ${ens_path}/${ens_date}/rpointer.ocn | sed  "s/mem01/mem${mem}/" > ${WORKDIR}/${VERSION}${mem}/run/rpointer.ocn
#   elseif (( ${hist_start} )) ; then
#      rm -f ${WORKDIR}/${VERSION}${mem}/run/*.nc
#      cp ${hist_path}/${hist_mem_date}-??-??-00000/* ${WORKDIR}/${VERSION}${mem}/run/
#      let tmp_date=tmp_date+hist_freq_date
#      hist_mem_date=`echo 000$tmp_date | tail -5c`
   fi
done
cp -f ${WORKSHARED}/Input/NorESM/${CASEDIR}_pak* ${HOMEDIR}/cases
cd ${HOMEDIR}/cases
for i in ${CASEDIR}_pak*
do
  pakN=`echo $i | awk -F "_pak" '{print $2}' | cut -c1`
  sed -i s/"PBS -A ".*/"PBS -A ${CPUACCOUNT}"/g     $i 
  sed -i s/"PBS -N ".*/"PBS -N r_NCPM_p${pakN}"/g     $i
  sed -i s/"PBS -l walltime".*/"PBS -l walltime=01:00:00 "/g     $i
  sed -i "s|PATHCASE|${HOMEDIR}/cases/${ParentP}/${VERSION}|"  $i 
  ##PBS -N NorCPM_pak1
done
echo 'The Ensemble structure is created successfully'
