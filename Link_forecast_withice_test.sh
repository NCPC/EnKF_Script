#Script called by main.sh, it links the corresponding restart file to the ANALYSIS forlder with name forecastxxx.nc 
#It also make a copy of forecastxxx.nc to analysisxxx.nc
source personal_setting.sh

year=$1
month=$2
mm=`echo 0$month | tail -3c`
yr=`echo 000$year | tail -5c`
source personal_setting.sh
cd /work/fanf/ANALYSIS_test/
for (( proc = 1; proc <= ${ENSSIZE}; ++proc ))
do
    mem=`echo 0$proc | tail -3c`
    mem3=`echo 00$proc | tail -4c`
    if [ ! -f "${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc" ] 
          then
             echo "The file  ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc is missing !! we quit"
   #          exit
    else
          cp ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.micom.r.${yr}-${mm}-15-00000.nc forecast${mem3}.nc
          cp ${WORKDIR}/${VERSION}${mem}/run/${VERSION}${mem}.cice.r.${yr}-${mm}-15-00000.nc forecast${mem3}ice.nc
    fi
done

