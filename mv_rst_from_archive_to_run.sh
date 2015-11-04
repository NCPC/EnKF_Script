#This script copies restart files from the archive to the run folder
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : date; example 2004-07-15-00000 "; exit 1 ; }
date=$1
source ${HOME}/NorESM/Script/personal_setting.sh
for i in `seq 01 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
  cp ${ARCHIVE}/${VERSION}${mem}/rest/${date}/* ${WORKDIR}/${VERSION}${mem}/run/
done

