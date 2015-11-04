#!/bin/sh -e

PREFIX=NorCPM_F19_tn21_mem 
CASEROOT=/home/nersc/ywang/NorESM/cases 

for MEM in `seq -w 01 30` 
do 
  cp -f ./st_archive_fanf.sh $CASEROOT/${PREFIX}${MEM}/Tools/st_archive.sh
done 

