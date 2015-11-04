#! /bin/bash


home=`pwd`
LID="`date +%y%m%d_%H%M%S`"
stdout=r_main_ff_${LID}_log
stderr=r_main_ff_${LID}_err
mv r_main_* /work/earnest/noresm/Log || echo "No log files left......."

 ${home}/main2.sh 1> ${stdout} 2> ${stderr} 


echo "Finished?? "
