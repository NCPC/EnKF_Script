#!/bin/sh -evx
#Script from Ingo Bethke that interpolate HadSST_sst to model annd compute the diff

CNAME=`basename $1` 
YEAR1=`echo 000$2 | tail -5c`
YEARN=`echo 000$3 | tail -5c`
PWDDIR=`pwd`
GFILE=$PWDDIR/grid.nc
OFILE=$PWDDIR/Data/HadISST_sst_1870-1899.nc
ODIR=$PWDDIR/Data
TMPDIR=/work/$USER/tmp3/$CNAME
DATDIR=$1/ocn/hist
# create tmp dir and cd 
mkdir -p $TMPDIR $ODIR
cd $TMPDIR

# create filelist, unpack data and average
FNAME=${CNAME}.micom.hy.${YEAR1}-${YEARN}.nc
rm -f filelist
for YYYY in `seq -w $YEAR1 $YEARN`
do 
  for MM in `seq -w 01 12`
  do 
    echo ${CNAME}.micom.hm.${YYYY}-${MM}.nc >> filelist  
    ncpdq -h -O -3 -U -F -d depth,1,1 -v templvl -o ${CNAME}.micom.hm.${YYYY}-${MM}.nc ${DATDIR}/${CNAME}.micom.hm.${YYYY}-${MM}.nc 
  done 
done 
cat filelist | ncra -h -O -o $FNAME

# prepare data for interpolation 
ncks -h -A -v plon,plat -o $FNAME $GFILE 
ncrename -h -O -v templvl,Temp -v plon,lon -v plat,lat $FNAME 
ncatted -h -O -a coordinates,Temp,o,c,'lon lat' -a cell_measures,,d,, -a valid_range,,d,, -a corners,,d,, -a depth_bnds,,d,, $FNAME

# interpolate 
cdo remapbil,$OFILE $FNAME ${CNAME}.micom.hy.${YEAR1}-${YEARN}_interp.nc

# compute difference mod-obs
ncdiff -h -O -o $ODIR/mod-obs.${CNAME}.${YEAR1}-${YEARN}.nc ${CNAME}.micom.hy.${YEAR1}-${YEARN}_interp.nc $OFILE

