source ${HOME}/NorESM/Script/personal_setting.sh
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : year; example 1953 "; exit 1 ; }
#Keep only the restart for Jan, Feb, May, Aug, Nov for seasonal pred
year=$1
rm -rf ${ARCHIVE}/${VERSION}??/rest/${year}-0[1,2,3,4,5,6,7,8,9]-*
rm -rf ${ARCHIVE}/${VERSION}??/rest/${year}-1[0,1]-*
