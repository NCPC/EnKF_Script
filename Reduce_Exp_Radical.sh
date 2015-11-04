source ${HOME}/NorESM/Script/personal_setting.sh

#Keep only the restart for Jan, Feb, May, Aug, Nov for seasonal pred
rm -rf ${ARCHIVE}/${VERSION}??/rest/????-0[1,2,3,4,5,6,7,8,9]-*
rm -rf ${ARCHIVE}/${VERSION}??/rest/????-1[0,1]-*
#rm -rf ${ARCHIVE}/${VERSION}??/rest/00?[0,2,3,4,5,6,7,8,9]-*
#delete daily average
rm -f ${ARCHIVE}/${VERSION}??/ocn/hist/${VERSION}??.micom.hd.00*
#delete some atm files
rm -f ${ARCHIVE}/${VERSION}??/atm/hist/${VERSION}*h[1,2]*
#delete some land files
rm -f ${ARCHIVE}/${VERSION}??/lnd/hist/${VERSION}*h[1,2]*
rm -f ${ARCHIVE}/${VERSION}??/atm/logs/*
rm -f ${ARCHIVE}/${VERSION}??/cpl/logs/*
rm -f ${ARCHIVE}/${VERSION}??/ice/logs/*
rm -f ${ARCHIVE}/${VERSION}??/lnd/logs/*
rm -f ${ARCHIVE}/${VERSION}??/ocn/logs/*
