#!/bin/bash -vx
#===============================================================================
#  This is a NorCPM superjob for hexagon_intel
#===============================================================================
# changes due to the heave load of the system ...

#PBS -A nn9039k
#PBS -W group_list=noresm
#PBS -N r_NCPM_FF_DA
#PBS -q batch
#PBS -l mppwidth=2560
#PBS -l walltime=24:00:00
####PBS -l mppwidth=512
####PBS -l walltime=1:00:00
#PBS -j oe
#PBS -S /bin/csh

set -x 
source ${HOME}/NorESM/Script/personal_setting.sh

if [ ! -d ${WORKDIR}/ANALYSIS/ ] ; then
      mkdir -p ${WORKDIR}/ANALYSIS  || { echo "Could not create ANALYSIS dir" ; exit 1 ; }
fi
FIRST_INTERGRATION=1
for year in `seq ${STARTYEAR} ${ENDYEAR}`; do
 for month in `seq 1 12`
 do
    if [ $month -ge $STARTMONTH ]
    then
    STARTMONTH=0
    mm=`echo 0$month | tail -3c`
    yr=`echo 000$year | tail -5c`
    yr_assim=`echo 000$year | tail -5c`
    if (( ${SKIPASSIM} ))
       then
       echo 'model is at:' $year $month
       echo 'observation is at:' $yr_assim $month
       cd ${WORKDIR}/ANALYSIS/
       for iobs in ${!OBSLIST[*]};
       do
          OBSTYPE=${OBSLIST[$iobs]}
          PRODUCER=${PRODUCERLIST[$iobs]}
          MONTHLY=${MONTHLY_ANOM[$iobs]}
             ln -sf ${WORKSHARED}/Obs/${OBSTYPE}/${PRODUCER}/${yr_assim}_${mm}.nc  .  || { echo "${WORKDIR}/OBS/${OBSTYPE}/${PRODUCER}/${yr_assim}_${mm}.nc, we quit" ; exit 1 ; }
          if (( ${ANOMALYASSIM} ))
          then
             ln -sf ${WORKSHARED}/bin/prep_obs_anom prep_obs
             if (( ${SUPERLAYER} ))
                then
                   ln -sf ${WORKSHARED}/bin/EnKF_Yiguo_anom_no_copy EnKF
                else
                   ln -sf ${WORKSHARED}/bin/EnKF_anom EnKF
             fi
             if (( ${MONTHLY} ))
             then
                ln -sf ${WORKSHARED}/Obs/${OBSTYPE}/${PRODUCER}/Anomaly/${OBSTYPE}_avg_${mm}-${REF_PERIOD}.nc mean_obs.nc || { echo "Error ${WORKSHARED}/Obs/${OBSTYPE}/${PRODUCER}/Anomaly/SST_avg_${mm}.nc missing, we quit" ; exit 1 ; }
                ln -sf ${WORKSHARED}/Input/NorESM/${CASEDIR}_${PRODUCER}_anom/Free-average${mm}-${REF_PERIOD}.nc mean_mod.nc || { echo "Error ${WORKSHARED}/Input/NorESM/${CASEDIR}_${PRODUCER}_anom/${OBSTYPE}_ave-${mm}.nc  missing, we quit" ; exit 1 ; }
             fi
           else
              ln -sf ${WORKSHARED}/bin/prep_obs_FF prep_obs
              if (( ${SUPERLAYER} ))
              then
                 ln -sf ${WORKSHARED}/bin/EnKF_Yiguo_FF EnKF
              else
                 ln -sf ${HOMEDIR}/bin/EnKF_FF EnKF
              fi
              ln -sf ${WORKSHARED}/Obs/${OBSTYPE}/${PRODUCER}/Anomaly/${OBSTYPE}_avg_${REF_PERIOD}.nc mean_obs.nc || { echo "Error ${WORKSHARED}/Obs/${OBSTYPE}/${PRODUCER}/Anomaly/SST_avg_${mm}.nc missing, we quit" ; exit 1 ; }
              ln -sf ${WORKSHARED}/Input/NorESM/${CASEDIR}_${PRODUCER}_anom/Free-average${REF_PERIOD}.nc mean_mod.nc || { echo "Error ${WORKSHARED}/Input/NorESM/${CASEDIR}_${PRODUCER}_anom/${OBSTYPE}_ave-${mm}.nc  missing, we quit" ; exit 1 ; }
          fi
          cat ${WORKSHARED}/Input/EnKF/infile.data.${OBSTYPE}.${PRODUCER} | sed  "s/yyyy/${yr_assim}/" | sed  "s/mm/${mm}/" > infile.data
          ln -sf  $GRIDPATH .
          #${WORKSHARED}/Script/Link_forecast_nocopy.sh ${yr} ${month}
exit 11
          /home/uib/earnest/NorESM/Script/Link_forecast_nocopy.sh ${yr} ${month}
          ./prep_obs 
          ln -sf ${WORKSHARED}/bin/ensave .
          ln -sf ${WORKSHARED}/bin/ensstat_field .
          ./ensstat_field forecast ${ENSSIZE}
          cat ${WORKSHARED}/Script/pbs_enkf.sh_nocopy_mal | sed  "s/NENS/${ENSSIZE}/" | sed  "s/nnXXXXk/${CPUACCOUNT}/"  > pbs_enkf.sh
          chmod 755 pbs_enkf.sh
          cp  -f ${WORKSHARED}/Input/EnKF/analysisfields.in .
          cat ${WORKSHARED}/Input/EnKF/enkf.prm_mal | sed  "s/XXX/${RFACTOR}/" > enkf.prm
          sed -i s/"enssize =".*/"enssize = "${ENSSIZE}/g enkf.prm
          #launch EnKF
          set -e 
    #      ./pbs_enkf.sh
          enkfid=`qsub ./pbs_enkf.sh`
          sleep 1s
          enkfans="R"
          while ( [ "${enkfans}" == "Q" ] || [ "${enkfans}" == "R" ] ) ; do
            enkfans=`qstat ${enkfid} 2>/dev/null | tail -n 1 | awk '{print $5}'`
            echo "waiting for EnKF-SST"
            sleep 5s
          done
          set +e
          cd ${WORKDIR}/ANALYSIS
          ans=`diff forecast_avg.nc analysis_avg.nc`
          if [ -z "${ans}" ] 
          then
                echo "There has been no update, we quit!!"
                exit 1
          fi
          echo 'Finished with EnKF; start post processing'
          date
          cat ${HOME}/NorESM/Script/fixenkf_${RES}_v3.sh_mal | sed  "s/NENS/${ENSSIZE}/g"  > fixenkf.sh
          chmod 755 fixenkf.sh
          ln -sf ${WORKSHARED}/bin/micom_serial_init_${RES}_link micom_serial_init
          ln -sf ${WORKSHARED}/bin/launcher${ENSSIZE} launcher
          if [ ! -d ${WORKDIR}/RESULT/ ] ; then
            mkdir -p ${WORKDIR}/RESULT  || { echo "Could not create RESULT dir" ; exit 1 ; }
          fi
          if [ ! -d ${WORKDIR}/RESULT/${yr}_${mm} ] ; then
            mkdir -p ${WORKDIR}/RESULT/${yr}_${mm}  || { echo "Could not create RESULT/${yr}_${mm} dir" ; exit 1 ; }
          fi
          cd ${WORKDIR}/ANALYSIS/
          mv enkf_diag.nc analysis_avg.nc forecast_avg.nc observations-SST.nc ensstat_field.nc ${WORKDIR}/RESULT/${yr}_${mm}
          rm -f  FINITO
#          ./fixenkf.sh 
          fixenkfid=`qsub ./fixenkf.sh `
          fixenkfans="R"
          while ( [ "${fixenkfans}" == "Q" ] || [ "${fixenkfans}" == "R" ] ); do
            fixenkfans=`qstat ${fixenkfid} 2>/dev/null | tail -n 1 | awk '{print $5}'`
            echo "waiting for fix EnKF-SST"
            sleep 5s
          done
          ./ensave forecast $ENSSIZE &
          wait
          mv  forecast_avg.nc ${WORKDIR}/RESULT/${yr}_${mm}/fix_analysis_avg.nc
          ans=`diff ${WORKDIR}/RESULT/${yr}_${mm}/fix_analysis_avg.nc ${WORKDIR}/RESULT/${yr}_${mm}/analysis_avg.nc`
          if [ -z "${ans}" ]
            then
            echo "There has been no fix update, we quit!!"
            echo "Delete FINITO"
            rm -f FINITO
            exit 1;
         fi
         #Do some clean up
         rm -f  forecast???.nc
         rm -f observations.uf enkf.prm infile.data mask.nc
         echo 'Finished with Assim post-processing'
         date
         let RFACTOR=RFACTOR-2
         if [ $RFACTOR -lt 1 ] 
         then
            RFACTOR=1
         fi
       done  #OBS list
    fi
    SKIPASSIM=1
    if (( ${SKIPPROP} ))
       then
       echo 'Integrate NorESM for a month'
       cd ${WORKDIR}/
#       ln -sf  /home/uib/earnest/NorESM/Script/Integrate_F19_tn21_1_month_superjob.sh .
#       ./Integrate_F19_tn21_1_month_superjob.sh

for mem in `seq -w 1 30 `; do
  IMEM=$mem
  cd ${HOMEDIR}/cases/${VERSION}${IMEM}
  #./${VERSION}${IMEM}.${machine}.submit
  jobid[${mem}]=`qsub ${VERSION}${IMEM}.${machine}.run`
  sleep 10s
  let mem=mem+1
  wait
done

  finished=0
  while (( ! finished )); do 
    finished=1
    for (( proc = 1; proc <= 30; ++proc )) ; do 
      if [ -z "${jobid[$proc]}" ]; then
        continue
      fi
      answer=`qstat ${jobid[$proc]} 2>/dev/null | tail -n 1 | awk '{print $5}'`
      if ( [ "${answer}" == "Q" ] || [ "${answer}" == "R" ] ); then
        jobid[$proc]=
        echo -n " Noresm job finished for member " $mem
      else
        finished=0
        sleep 60
        break
      fi
    done
  done

       if [ $month -eq 12 ]
       then
          let years=year+1
          ys=`echo 000$years | tail -5c`
          ms=01
       else
          ys=$yr
          let tmp=month+1
          ms=`echo 0$tmp | tail -3c`
       fi

       for (( proc = 1; proc <= ${ENSSIZE}; ++proc ))
       do
          mem=`echo 0$proc | tail -3c`
          cd ${WORKDIR}/${VERSION}${mem}/run/
          if [ ! -f "${VERSION}${mem}.micom.r.${ys}-${ms}-15-00000.nc" ] 
          then
             echo "The file  ${VERSION}${mem}.micom.r.${ys}-${ms}-15-00000.nc is missing !! we quit"
             exit
          fi
       done
       echo 'All integration jobs completed'
       date
       #mv ${WORKDIR}/NorCPM_ensemble.o* ${WORKDIR}/Log/
   fi
   SKIPPROP=1
  # if [ $FIRST_INTERGRATION -a $hybrid_run ] ;then
  #    for i in `seq 01 ${ENSSIZE}`
  #    do
  #        mem=`echo 0$i | tail -3c`
  #        cd ${HOMEDIR}/cases/${VERSION}${mem}/
  #        xmlchange -file env_run.xml -id CONTINUE_RUN -val TRUE
  #    done
  #    FIRST_INTERGRATION=0
  # fi
 fi
 done
done
echo " done"
