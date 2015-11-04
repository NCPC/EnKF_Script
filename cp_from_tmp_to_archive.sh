#Creator: Fanf
#Script to mv restart file ensemble from a folder tmp2 (typically where a tar.gz where extracted to the standard archive structure
[ $# -ne 2 ] &&  { echo "Must be called with 2 arg: path to tmp folder and date; example: /work/fanf/tmp 1980-01-15-00000  "; exit 1 ; }
TMP_PATH=$1
date=$2
for i in `seq 01 ${ENSSIZE}`
do
   mem=`echo 0$i | tail -3c`
   mkdir -p ${ARCHIVE}/${VERSION}${mem}
   mkdir -p ${ARCHIVE}/${VERSION}${mem}/rest
   cp -r ${TMP_PATH}/${VERSION}${mem}/rest/${date} ${ARCHIVE}/${VERSION}${mem}/rest/
done

