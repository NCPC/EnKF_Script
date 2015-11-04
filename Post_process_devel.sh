year=$1
month=$2
NENS=$3
mm=`echo 0$month | tail -3c`
yr=`echo 000$year | tail -5c`
if [ ! -d ${WORKDIR}/Old_forecast/ ] ; then
      mkdir -p ${WORKDIR}/Old_forecast  || { echo "Could not create Old_forecast dir" ; exit 1 ; }
fi
if [ ! -d ${WORKDIR}/RESULT/ ] ; then
      mkdir -p ${WORKDIR}/RESULT  || { echo "Could not create RESULT dir" ; exit 1 ; }
fi
if [ ! -d ${WORKDIR}/RESULT/${yr}_${mm} ] ; then
      mkdir -p ${WORKDIR}/RESULT/${yr}_${mm}  || { echo "Could not create RESULT/${yr}_${mm} dir" ; exit 1 ; }
fi
cd ${WORKDIR}/ANALYSIS/
mv enkf_diag.nc analysis_avg.nc forecast_avg.nc enkf.out enkf.err observations-SST.nc ${WORKDIR}/RESULT/${yr}_${mm}
export WORKDIR
jobid=`qsub -v WORKDIR Post_process.sh`
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

for (( proc = 1; proc <= ${ENSSIZE}; ++proc ))
do
   mem=`echo 0$proc | tail -3c`
   mem3=`echo 00$proc | tail -4c`
   mv ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc ${WORKDIR}/Old_forecast/
   mv analysis${mem3}.nc ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc
   ln -s  ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc analysis${mem3}.nc
   let cnt=cnt+1
done
./ensave analysis $NENS
mv  analysis_avg.nc ${WORKDIR}/RESULT/${yr}_${mm}/fix_analysis_avg.nc
#Do some clean up
rm -f  analysis???.nc forecast???.nc
rm -f observations.uf enkf.prm infile.data mask.nc

