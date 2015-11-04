
mkdir -p Processed
mkdir -p Finished
module load cdo
module load nco

for vset in 115 1194 1346 137 1466 396 400 69 1059 1169
do
   cdo -splitsel,1 HadISST.2.1.0.0_realisation_${vset}.nc SST_monthly
   year=1850
   month=1
   for i in SST_monthly*.nc
   do
      mm=$(echo 0$month | tail -c3 )
      mv $i SST_${year}_${mm}_${vset}.nc
      ncecat -O -u nens SST_${year}_${mm}_${vset}.nc SST_${year}_${mm}_${vset}.nc
      if [ $month -eq 12 ] 
      then
         let month=1
         let year=year+1
      else
         let month=month+1
      fi
   done
   mv  HadISST.2.1.0.0_realisation_${vset}.nc Finished/
done
for  year in `seq 1850 2007`
do
   for month in `seq 1 12`
   do
      mm=$(echo 0$month | tail -c3 )
      ncrcat SST_${year}_${mm}_*.nc SST_ens_${year}_${mm}.nc
      mv SST_ens_${year}_${mm}.nc Processed/

   done
done
 
