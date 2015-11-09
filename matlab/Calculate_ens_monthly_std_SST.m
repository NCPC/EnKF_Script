%Various info 
OBS_ENS=10
NENS=30;
dlon=360;
dlat=180;
nx=180
ny=193
year_start=1980
year_end=1999
O_PATH='/work/shared/nn9039k/NorCPM/Obs/SST/HADISST2/'
FREE_PATH='/work/fanf/FREE/'
NorCPM_PATH='/work/fanf/NorCPM5/'
Input_PATH = '/work/shared/nn9039k/NorCPM/Input/NorESM/NorCPM_F19_tn21_HADISST2_anom/'
grid_PATH='/work/shared/noresm/inputdata/ocn/micom/tnx2v1/20130206/grid.nc'
%NorCPM_PATH2='/work/fanf/NorCPM2/Processed/'
%reading pivo2t
ipiv  =ncgetvar([Input_PATH 'pivots_SST.nc'],'ipiv');
jpiv  =ncgetvar([Input_PATH 'pivots_SST.nc'],'jpiv');
for j=1:dlat
      lat(j)= 89.5-j;
end
for i=1:dlon
   lon(i)=-179.5+(i-1);
end
for j=2:dlat-1
   dx=Haversin_dist(lon(1),lat(j),lon(3),lat(j))/2;
   dy=Haversin_dist(lon(1),lat(j-1),lon(1),lat(j+1))/2;
   parea(1:dlon,j)=dx*dy;
end
parea(1:dlon,1)=parea(1:dlon,2);
parea(1:dlon,180)=parea(1:dlon,179);
paream=mean(parea(:));
plon=repmat(lon',1,dlat);
plat=repmat(lat,dlon,1);
mean_rms_f=zeros(dlon,dlat);
mean_rms_a=zeros(dlon,dlat);
cnt=0
f_osst=zeros(dlon,dlat,NENS);
a_osst=zeros(dlon,dlat,NENS);
f_osst_sq=zeros(dlon,dlat,NENS);
a_osst_sq=zeros(dlon,dlat,NENS);
osst=zeros(dlon,dlat,OBS_ENS);
osst_sq=zeros(dlon,dlat,OBS_ENS);
nb_fosst=zeros(dlon,dlat,NENS);
nb_aosst=zeros(dlon,dlat,NENS);
for yr=year_start:year_end
      yr
   for month=1:12
      %reading data
      sst = squeeze(ncgetvar([O_PATH 'SST_ens_' num2str(yr) '_' num2str(month,'%2.2d') '.nc'],'sst'));
      sst_avg =ncgetvar([O_PATH 'Anomaly/SST_avg_' num2str(month,'%2.2d') '.nc'],'sst');
      sst=sst-reshape(repmat(sst_avg,1,OBS_ENS),dlon,dlat,OBS_ENS);
      sic = squeeze(ncgetvar([O_PATH 'SST_ens_' num2str(yr) '_' num2str(month,'%2.2d') '.nc'],'sic'));
      mask=find(sic~=0);
      sst(mask)=nan;
      osst=osst+sst;
      osst_sq=osst_sq+sst.^2;
      cnt=cnt+1;
      for mem=1:NENS
         %reading Free
         f_sst=ncgetvar([FREE_PATH  'NorCPM_F19_tn21_mem' num2str(mem,'%2.2d') '.micom.hm.' num2str(yr,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sst');
         avg_sst=ncgetvar([Input_PATH 'ave-' num2str(month,'%2.2d') '.nc'],'sst');
         f_sst=f_sst-avg_sst;
         f_sic=ncgetvar([FREE_PATH   'NorCPM_F19_tn21_mem' num2str(mem,'%2.2d') '.micom.hm.' num2str(yr,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'fice');
         mask=find(f_sic~=0);
         f_sst(mask)=nan;
         %reading Assim
         a_sst=ncgetvar([NorCPM_PATH   'NorCPM_F19_tn21_mem' num2str(mem,'%2.2d') '.micom.hm.' num2str(yr,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sst');
         a_sst=a_sst-avg_sst;
         a_sic=ncgetvar([NorCPM_PATH   'NorCPM_F19_tn21_mem' num2str(mem,'%2.2d') '.micom.hm.' num2str(yr,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'fice');
         mask=find(a_sic~=0);
         a_sst(mask)=nan;
         %interp_model to obs
         for i=1:dlon
            for j=1:dlat
               if (~isnan(f_sst(ipiv(i,j),jpiv(i,j))))
                  f_osst(i,j,mem)   =f_osst(i,j,mem)+f_sst(ipiv(i,j),jpiv(i,j));
                  f_osst_sq(i,j,mem)=f_osst_sq(i,j,mem)+f_sst(ipiv(i,j),jpiv(i,j)).^2;
                  nb_fosst(i,j,mem) =nb_fosst(i,j,mem)+1;
               end
               if (~isnan(a_sst(ipiv(i,j),jpiv(i,j))))
                  a_osst(i,j,mem)   =a_osst(i,j,mem   )+a_sst(ipiv(i,j),jpiv(i,j));
                  a_osst_sq(i,j,mem)=a_osst_sq(i,j,mem)+a_sst(ipiv(i,j),jpiv(i,j)).^2;
                  nb_aosst(i,j,mem) =nb_aosst(i,j,mem )+1;
               end

            end
         end
      end%ens
   end %month
end

f_osst=f_osst./nb_fosst;
f_osst_sq=f_osst_sq./nb_fosst;
a_osst=a_osst./nb_aosst;
a_osst_sq=a_osst_sq./nb_aosst;
osst=osst/cnt;
osst_sq=osst_sq/cnt;
figure(1)
set(gcf, 'Renderer', 'opengl')
set(gcf, 'InvertHardCopy', 'off');
whitebg('w');
hold on
m_proj('hammer-aitoff','clongitude',-150);
P=m_pcolor(plon,plat,    mean(sqrt(f_osst_sq-f_osst.^2),3))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,mean(sqrt(f_osst_sq-f_osst.^2),3))
set(P,'LineStyle','none')
title('Mean of Monthly std SSTA: Free')
caxis([0 1.5])
colormap(fc100);
colorbar('h')
m_grid;
m_coast('patch','k');
print('-depsc2','Mean_Monthly_std_FREE_SSTA.eps')
figure(2)
set(gcf, 'Renderer', 'opengl')
set(gcf, 'InvertHardCopy', 'off');
whitebg('w');
hold on
m_proj('hammer-aitoff','clongitude',-150);
P=m_pcolor(plon,plat,    mean(sqrt(a_osst_sq-a_osst.^2),3))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,mean(sqrt(a_osst_sq-a_osst.^2),3))
set(P,'LineStyle','none')
caxis([0 1.5])
colormap(fc100);
title('Mean of Monthly std SSTA: NorCPM')
m_grid;
m_coast('patch','k');
colorbar('h')
print('-depsc2','Mean_Monthly_std_NorCPM_SSTA.eps')
%
figure(3)
m_proj('hammer-aitoff','clongitude',-150);
set(gcf, 'Renderer', 'opengl')
set(gcf, 'InvertHardCopy', 'off');
whitebg('w');
hold on
P=m_pcolor(plon,plat,    mean(sqrt(osst_sq-osst.^2),3))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,mean(sqrt(osst_sq-osst.^2),3))
set(P,'LineStyle','none')
caxis([0 1.5])
colormap(fc100);
title('Mean of Monthly std SSTA: OBS')
m_grid;
m_coast('patch','k');
colorbar('h')
print('-depsc2','Mean_Monthly_std_obs_SSTA.eps')




