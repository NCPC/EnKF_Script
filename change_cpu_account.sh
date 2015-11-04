source ${HOME}/NorESM/Script/personal_setting.sh
start_mem=1

for (( proc = ${start_mem}; proc <= ${ENSSIZE}; ++proc ))
do
   mem=`echo 0$proc | tail -3c`
   cd ${HOMEDIR}/cases/${CASEDIR}${mem}/
         cat ${CASEDIR}${mem}.${machine}.run | sed \
        -e "s/nn9207k/nn9039k/g" \
        > toto 
        mv toto  ${CASEDIR}${mem}.${machine}.run
done
