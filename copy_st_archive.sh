source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 01 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   cp /home/nersc/fanf/st_archive.sh ${HOMEDIR}/cases/NorCPM_ME_mem${mem}/Tools/

done

