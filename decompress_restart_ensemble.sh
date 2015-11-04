#Decompress restart file format
source ${HOME}/NorESM/Script/personal_setting.sh

cd ${WORKDIR}/ANALYSIS/
ln -sf ${GRIDPATH} .
for i in `seq 1 ${ENSSIZE}`
do
   mem=`echo 00$i | tail -4c`
   ${HOMEDIR}/bin/micompp_decompress  grid.nc forecast${mem}.nc forecast${mem}_u.nc
   mv forecast${mem}_u.nc forecast${mem}.nc
   cp forecast${mem}.nc analysis${mem}.nc
done
