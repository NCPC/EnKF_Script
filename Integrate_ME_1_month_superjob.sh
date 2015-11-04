#!/bin/sh -evx
#===============================================================================
#  This is a CCSM batch job script for hexagon_intel
#===============================================================================

#PBS -A nn9039k
#PBS -W group_list=noresm
#PBS -N NorCPM_ensemble
#PBS -q batch
#PBS -l mppwidth=1600
#PBS -l walltime=01:37:00
#PBS -j oe
#PBS -S /bin/csh
HOMEDIR=/home/nersc/${USER}/NorESM/
ANOMPATH=/work/shared/nersc/msc/NorCPM/
CASEDIR='NorCPM_ME'
VERSION=${CASEDIR}'_mem'
machine='hexagon_intel'

SIMTYPE=cont
NENS=3
NMEM=10
mem=1 
for ENS in `seq -w 1 $NENS`
do
   for MEM in `seq -w 01 $NMEM` 
   do 
        IMEM=$(echo 0$mem | tail -c3 )
       cd ${HOMEDIR}/cases/${VERSION}${IMEM}
       chmod +x ${VERSION}${IMEM}.${machine}.run
       ./${VERSION}${IMEM}.${machine}.run &   
       sleep 1s       
    let mem=mem+1
   done 
   wait 
done 

echo ensemble completed 
   
