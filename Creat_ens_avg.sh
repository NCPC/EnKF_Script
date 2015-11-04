
mkdir -p Processed
module load nco

for year in `seq 1950 1959`
do
   for month in `seq 1 12`
   do
      mm=$(echo 0$month | tail -c3 )
      ncea NorCPM_ME_mem??.micom.hm.${year}-${mm}.nc Processed/Assim_${year}-${mm}.nc
   done
done
 
