#This script delete a single memeber
#member deleted is the first argument of the script
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : member to be deleted  "; exit 1 ; }
source ${HOME}/NorESM/Script/personal_setting.sh

mem=`echo 0$1 | tail -3c`
cd ${HOMEDIR}/cases/
echo 'delete' ${HOMEDIR}/cases/${VERSION}${mem}
rm -rf ${VERSION}${mem}
cd ${WORKDIR}/
echo 'delete' ${WORKDIR}/${VERSION}${mem}
rm -rf ${VERSION}${mem} 
