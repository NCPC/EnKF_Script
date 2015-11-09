idm=180
jdm=193 
nens=30  %Ens size
nens=30;
CASENAME='NorCPM_F19_tn21_mem'
Input_PATH = '/work/shared/nn9039k/NorCPM/Input/NorESM/NorCPM_F19_tn21_HADISST2_anom/'
NorCPM_PATH='/work/fanf/NorCPM5/Processed/'
grid_PATH='/work/shared/noresm/inputdata/ocn/micom/tnx2v1/20130206/grid.nc'
O_PATH='/work/shared/nn9039k/NorCPM/Obs/SST/HADISST2/'
year_start=1980;
year_end=1996;
nby=year_end-year_start+1;
norcpm_path='/work/fanf/NorCPM5/'
free_path='/work/fanf/FREE/'
OBS_ENS=10
dlon=360;
dlat=180;

year_start=1980
year_end=2004




ipiv  =ncgetvar([Input_PATH 'pivots_SST.nc'],'ipiv');
jpiv  =ncgetvar([Input_PATH 'pivots_SST.nc'],'jpiv');

parea=ncgetvar(grid_PATH,'parea');
pdepth=ncgetvar(grid_PATH,'pdepth');
plon=ncgetvar(grid_PATH,'plon');
plat=ncgetvar(grid_PATH,'plat');
%pmasknino=find(plon>-150 & plon<-90 & plat>-5 & plat<5);
pmasknino=find(plon>-170 & plon<-120 & plat>-5 & plat<5);
pmask=find(pdepth<1);
parea(pmask)=nan;


for j=1:dlat
      lat(j)= 89.5-j;
end
for i=1:dlon
   lon(i)=-179.5+(i-1);
end
for j=2:dlat-1
   dx=Haversin_dist(lon(1),lat(j),lon(3),lat(j))/2;
   dy=Haversin_dist(lon(1),lat(j-1),lon(1),lat(j+1))/2;
   oparea(1:dlon,j)=dx*dy;
end
oparea(1:dlon,1)=oparea(1:dlon,2);
oparea(1:dlon,180)=oparea(1:dlon,179);

opaream=mean(parea(:));
olon=repmat(lon',1,dlat);
olat=repmat(lat,dlon,1);
%omask=find(olon>-150 & olon<-90 & olat>-5 & olat<5);
omask=find(olon>-170 & olon<-120 & olat>-5 & olat<5);


cnt=1
for yr=year_start:year_end
      yr
   for month=1:12
      %reading data
      sst =squeeze(nanmean(ncgetvar([O_PATH 'SST_ens_' num2str(yr) '_' num2str(month,'%2.2d') '.nc'],'sst'),4));
      sst_avg =ncgetvar([O_PATH 'Anomaly/SST_avg_' num2str(month,'%2.2d') '.nc'],'sst');
      sst=sst-sst_avg;
      a_sst=ncgetvar([NorCPM_PATH 'assim-average' num2str(yr) '-' num2str(month,'%2.2d') '.nc'],'sst');
      avg_sst=ncgetvar([Input_PATH 'ave-' num2str(month,'%2.2d') '.nc'],'sst');
      a_sst=a_sst-avg_sst;

%      a_osst=zeros(dlon,dlat);
%      nb_aosst=zeros(dlon,dlat);
%      for i=1:dlon
%         for j=1:dlat
%            if (~isnan(a_sst(ipiv(i,j),jpiv(i,j))))
%               a_osst(i,j)=a_osst(i,j)+a_sst(ipiv(i,j),jpiv(i,j));
%               nb_aosst(i,j)=nb_aosst(i,j)+1;
%            end
%         end
%      end
%      a_osst=a_osst./nb_aosst;
%      nino3_mo(cnt)=nanmean(a_osst(omask));
      nino3_m(cnt)=nanmean(a_sst(pmasknino));
      nino3_o(cnt)=nanmean(sst(omask));
      date(cnt)=datenum(yr,month,15);
      cnt=cnt+1;
   end
end
plot(date,nino3_m,'r-')
hold on
plot(date,nino3_o,'b-')
legend('Model','Obs')
title('Nino3.4')
print('-depsc2','NINO3.eps')


