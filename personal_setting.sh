HOMEDIR=${HOME}/NorESM/
WORKDIR=/work/${USER}/noresm/
WORKSHARED=/work/shared/nn9039k/NorCPM/
ARCHIVE=/work/${USER}/archive/
#ENSSIZE=30
ENSSIZE=2 # MS testing ...
CASEDIR='NorCPM_F19_tn21'
if [ "$CASEDIR" == "NorCPM_ME" ] ; then
   GRIDPATH=/work/shared/noresm/inputdata/ocn/micom/gx1v6/20101119/grid.nc
   COMPSET=N20TREXTAERCN
   RES=f19_g16 
   #The following are necessary to set path to the miseryous cam2.i file 
   ifile_casename=NorESM1-ME_historicalExt_noAssim_mem
   ifile_date=1980-01-01-00000
elif [ "$CASEDIR" == "NorCPM_F19_tn21" ] ; then
   GRIDPATH=/work/shared/noresm/inputdata/ocn/micom/tnx2v1/20130206/grid.nc
   COMPSET=N20TREXT
   RES=f19_tn21 
   #The following are necessary to set path to the miseryous cam2.i file 
   ifile_casename=NorCPM_F19_tn21_mem
   ifile_date=1970-01-01-00000
else
   echo "$CASEDIR not implemented in NorCPM, we quit"
fi
VERSION=${CASEDIR}'_mem'
#Possible to assimilate multiple observation sequentially
#OBSLIST="SST SSH"
OBSLIST="SST"
#PRODUCERLIST='HADISST2 CLS'
PRODUCERLIST='HADISST2'
ANOMALYASSIM=0  #1 is for TRUE
#MONTHLY_ANOM='1 0' #1 is monthly 0 is yearly
MONTHLY_ANOM='1'
REF_PERIOD='1980-2000' # for calculating anomalies
#SUPERLAYER='1'  #1 means you use the new fix from Yiguo
SUPERLAYER='1' # MS testing ...

CPUACCOUNT=nn9039k
machine='hexagon_intel'
CODEVERSION='projectEPOCASA-5/noresm/'

#FOLLOWING is related to the starting option
hybrid_run=1 #You need to make hybrid start if the model configuration is different
#If you are starting from the same model with same configuration set hybrib_run=0
rest_path="/work/${USER}/tmp/" #folder where data to be branched are temporarly stored

####First Hybrid run possiblility :Ensemble start ####
#   an ensemble of run =same date multiple case name that finish by CASENAME_memXX
ens_start=1 #1 means we start hybrid from an ensemble run
#ens_casename='NorCPM_ME_mem'
#ens_start_date=1950-01-15-00000
ens_casename='NorCPM_F19_tn21_mem'  # MS testing ...
ens_start_date=1970-01-15-00000    # MS testing ...

####Second Hybrid run possiblility :Historical start ####
#   a historical run   =same case name multiple date (hist_start_date:hist_freq_date:NENS*hist_freq_date+hist_start_date)
hist_start=0 #1 means we start hybrid from anstorical run
#first member use year 0001 and then all member use year+5 
#TODO Not Finished
hist_path="/work/${USER}/tmp/"
hist_start_date=1500
hist_freq_date=10


#FOLLOWING is related to the Reanalysis
SKIPASSIM=1 #if 0 we skip the first assimilation
SKIPPROP=1 #if 0 we skip the first model intergration
#start_date=2001-03-15-00000
start_date=1970-01-15-00000  # MS testing ...
short_start_date=`echo $start_date | cut -c1-10`
STARTMONTH=`echo $start_date | cut -c6-7`
STARTYEAR=`echo $start_date | cut -c1-4` 
RFACTOR=8  #Slow assimilation start
nbbatch=8  #Number of group of job going into the queue
ENDYEAR=2010
export WORKDIR HOMEDIR VERSION ENSSIZE

