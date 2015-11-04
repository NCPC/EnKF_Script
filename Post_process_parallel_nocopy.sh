#parallel post processing of the enkf called by main.sh
#This have been unstable on hexagon
#In such a case run the serial version
year=$1
month=$2
NENS=$3
mm=`echo 0$month | tail -3c`
yr=`echo 000$year | tail -5c`
if [ ! -d ${WORKDIR}/RESULT/ ] ; then
      mkdir -p ${WORKDIR}/RESULT  || { echo "Could not create RESULT dir" ; exit 1 ; }
fi
if [ ! -d ${WORKDIR}/RESULT/${yr}_${mm} ] ; then
      mkdir -p ${WORKDIR}/RESULT/${yr}_${mm}  || { echo "Could not create RESULT/${yr}_${mm} dir" ; exit 1 ; }
fi
cd ${WORKDIR}/ANALYSIS/
mv enkf_diag.nc analysis_avg.nc forecast_avg.nc enkf.out enkf.err observations-SST.nc ${WORKDIR}/RESULT/${yr}_${mm}
rm -f fixenkf.out fixenkf.err FINITO
export WORKDIR
jobid=`qsub -v WORKDIR fixenkf.sh`
finished=0
while (( ! finished ))
do
     finished=1
     answer=`qstat $jobid 2>/dev/null | tail -1 | awk '{print $5}'`
     if [ -z "${answer}" -o "${answer}" == "C" ]
     then
         answer=
         echo -n "Fix_Enkf finished"
     else
      finished=0
      sleep 10
     fi
done
if [ -f "FINITO" ] 
then
   echo "The job is finished and worked, overwrite the forecast files"
   echo "Backup of the old file in Old_restart"
   ./ensave forecast $NENS
   mv  forecast_avg.nc ${WORKDIR}/RESULT/${yr}_${mm}/fix_analysis_avg.nc
   mv fixenkf.out fixenkf.err ${WORKDIR}/RESULT/${yr}_${mm}/
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
fi

