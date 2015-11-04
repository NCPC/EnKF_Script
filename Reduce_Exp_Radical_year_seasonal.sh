source ${HOME}/NorESM/Script/personal_setting.sh
[ $# -ne 1 ] &&  { echo "Must be called with 1 args : year; example 1953 "; exit 1 ; }
#Keep only the restart for Jan, Feb, May, Aug, Nov for seasonal pred
year=$1
rm -rf ${ARCHIVE}/${VERSION}??/rest/${year}-0[2,3,5,6,8,9]-*
rm -rf ${ARCHIVE}/${VERSION}??/rest/${year}-11-*
