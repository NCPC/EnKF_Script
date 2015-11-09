%Various info 
OBS_ENS=10
dlon=360;
dlat=180;
nx=180
ny=193
year_start=1980
year_end=2004
O_PATH='/work/shared/nn9039k/NorCPM/Obs/SST/HADISST2/'
FREE_PATH='/work/fanf/FREE/Processed/'
NorCPM_PATH='/work/fanf/NorCPM5/Processed/'
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
f_osst=zeros(dlon,dlat);
a_osst=zeros(dlon,dlat);
osst=zeros(dlon,dlat);
f_osst_sq=zeros(dlon,dlat);
a_osst_sq=zeros(dlon,dlat);
osst_sq=zeros(dlon,dlat);
nb_fosst=zeros(dlon,dlat);
nb_aosst=zeros(dlon,dlat);
for yr=year_start:year_end
      yr
   for month=1:12
      %reading data
      sst =squeeze(nanmean(ncgetvar([O_PATH 'SST_ens_' num2str(yr) '_' num2str(month,'%2.2d') '.nc'],'sst'),4));
      sst_avg =ncgetvar([O_PATH 'Anomaly/SST_avg_' num2str(month,'%2.2d') '.nc'],'sst');
      sst=sst-sst_avg;
      sic =squeeze(nansum(ncgetvar([O_PATH 'SST_ens_' num2str(yr) '_' num2str(month,'%2.2d') '.nc'],'sic'),4));
      mask=find(sic~=0);
      sst(mask)=nan;
      %reading Free
      f_sst=ncgetvar([FREE_PATH 'Free-average' num2str(yr) '-'  num2str(month,'%2.2d') '.nc'],'sst');
      avg_sst=ncgetvar([Input_PATH 'ave-' num2str(month,'%2.2d') '.nc'],'sst');
      f_sst=f_sst-avg_sst;
      f_sic=ncgetvar([FREE_PATH 'Free-average' num2str(yr) '-'  num2str(month,'%2.2d') '.nc'],'fice');
      mask=find(f_sic~=0);
      f_sst(mask)=nan;
      %reading Assim
      a_sst=ncgetvar([NorCPM_PATH 'assim-average' num2str(yr) '-' num2str(month,'%2.2d') '.nc'],'sst');
      a_sst=a_sst-avg_sst;
      a_sic=ncgetvar([NorCPM_PATH 'assim-average' num2str(yr) '-' num2str(month,'%2.2d') '.nc'],'fice');
      mask=find(a_sic~=0);
      a_sst(mask)=nan;
      %interp_model to obs
      osst=osst+sst;
      osst_sq=osst_sq+sst.^2;
      cnt=cnt+1;
      for i=1:dlon
         for j=1:dlat
            if (~isnan(f_sst(ipiv(i,j),jpiv(i,j))))
               f_osst(i,j)=f_osst(i,j)+f_sst(ipiv(i,j),jpiv(i,j));
               f_osst_sq(i,j)=f_osst_sq(i,j)+f_sst(ipiv(i,j),jpiv(i,j)).^2;
               nb_fosst(i,j)=nb_fosst(i,j)+1;
            end
            if (~isnan(a_sst(ipiv(i,j),jpiv(i,j))))
               a_osst(i,j)=a_osst(i,j)+a_sst(ipiv(i,j),jpiv(i,j));
               a_osst_sq(i,j)=a_osst_sq(i,j)+a_sst(ipiv(i,j),jpiv(i,j)).^2;
               nb_aosst(i,j)=nb_aosst(i,j)+1;
            end

         end
      end
   end
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
P=m_pcolor(plon,plat,sqrt(f_osst_sq-f_osst.^2))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,sqrt(f_osst_sq-f_osst.^2))
set(P,'LineStyle','none')
title('Monthly std of ensemble mean SSTA: Free')
caxis([0 1.5])
colormap(fc100);
colorbar('h')
m_grid;
m_coast('patch','k');
print('-depsc2','Monthly_std_FREE_SSTA.eps')
figure(2)
set(gcf, 'Renderer', 'opengl')
set(gcf, 'InvertHardCopy', 'off');
whitebg('w');
hold on
m_proj('hammer-aitoff','clongitude',-150);
P=m_pcolor(plon,plat,sqrt(a_osst_sq-a_osst.^2))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,sqrt(a_osst_sq-a_osst.^2))
set(P,'LineStyle','none')
caxis([0 1.5])
colormap(fc100);
title('Monthly std of ensemble mean SSTA: NorCPM')
m_grid;
m_coast('patch','k');
colorbar('h')
print('-depsc2','Monthly_std_NorCPM_SSTA.eps')
%
figure(3)
m_proj('hammer-aitoff','clongitude',-150);
set(gcf, 'Renderer', 'opengl')
set(gcf, 'InvertHardCopy', 'off');
whitebg('w');
hold on
P=m_pcolor(plon,plat,sqrt(osst_sq-osst.^2))
set(P,'LineStyle','none')
P=m_pcolor(plon-360,plat,sqrt(osst_sq-osst.^2))
set(P,'LineStyle','none')
caxis([0 1.5])
colormap(fc100);
title('Monthly std of ensemble mean SSTA: OBS')
m_grid;
m_coast('patch','k');
colorbar('h')
print('-depsc2','Monthly_std_obs_SSTA.eps')




