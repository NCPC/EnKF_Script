%Various info 
OBS_ENS = 10;
dlon = 360;
dlat = 180;
nx = 180;
ny = 193;
start_year=1980
end_year=1988
%main pathes
FREE_PATH = '/work/fanf/FREE/Processed/';
ASSIM_PATH = '/work/fanf/NorCPM5/Processed/';
OBS_PATH = '/work/shared/nn9039k/NorCPM/Obs/SSH/';
Ave_PATH = '/work/shared/nn9039k/NorCPM/Input/NorESM/NorCPM_F19_tn21_MSSH/Free_mssh_1993-2004.nc';
grid_PATH='/work/shared/noresm/inputdata/ocn/micom/tnx2v1/20130206/grid.nc';
avg_ssh = ncgetvar(Ave_PATH, 'sealv');


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
opaream=mean(oparea(:));

%reading pivot
pdepth=ncgetvar(grid_PATH,'pdepth');
parea=ncgetvar(grid_PATH,'parea');
pmask=find(pdepth<1);
parea(pmask)=nan;
paream=nanmean(parea(:));
cnt=1;
for yr = start_year : end_year
   f_ssh=zeros(nx,ny);
   a_ssh=zeros(nx,ny);
   for month = 1:12
      %reading Free
      tmp = ncgetvar([FREE_PATH 'Free-average' num2str(yr) '-'  num2str(month,'%2.2d') '.nc'],'sealv');
      tmp(pmask)=nan;
      f_sic = ncgetvar([FREE_PATH 'Free-average' num2str(yr) '-'  num2str(month,'%2.2d') '.nc'], 'fice');
      mask = find(f_sic ~= 0);
      tmp(mask) = nan;
      f_ssh=f_ssh+tmp;

      %reading Assim
      tmp = ncgetvar([ASSIM_PATH 'assim-average' num2str(yr) '-' num2str(month,'%2.2d') '.nc'], 'sealv');
      tmp(pmask)=nan;
      a_sic = ncgetvar([ASSIM_PATH 'assim-average' num2str(yr) '-' num2str(month,'%2.2d') '.nc'], 'fice');
      mask = find(a_sic ~= 0);
      tmp(mask) = nan;
      a_ssh=a_ssh+tmp;
   end

   %size(f_ssh)
   time_f(cnt) = nanmean((f_ssh(:)/12-avg_ssh(:)).* parea(:) ./paream);
   time_a(cnt) = nanmean((a_ssh(:)/12-avg_ssh(:)).* parea(:) ./paream);
   cnt = cnt + 1;
end
ssh_full=ncgetvar([OBS_PATH 'ssh_L4_1_deg.nc'],'height');
mssh_obs=ncgetvar([OBS_PATH 'mssh_cls_1993-2004_1d.nc'],'height');

cnt=1
cnt_yr=1
for yr = 1993 : 2004
   ossh=zeros(dlon,dlat);
   for month = 1:12
      ossh=ossh+ssh_full(:,:,1,cnt);
      ossh=ossh-mssh_obs;
      cnt=cnt+1;
   end
   time_o(cnt_yr)=nanmean(ossh(:) .* oparea(:) ./opaream)/12;
   cnt_yr=cnt_yr+1;
end


%%%%%%%%%%%%
%%%%Plot%%%%
%%%%%%%%%%%%

figure(1)
time_yr=start_year:end_year;
[a_f ]=polyfit(time_yr,time_f*100,1);
[a_a ]=polyfit(time_yr,time_a*100,1);


plot(time_yr,time_f*100,'b-','linewidth',2)
hold on
plot(time_yr,time_a*100, 'r','linewidth',2)
hold on
b_o=time_yr(1)*((a_a(1)+a_f(1))/2-0.11)+(a_a(2)+a_f(2))/2;
plot(time_yr,time_yr*0.11+b_o,'g-','linewidth',2)

%plot(1993:2004,time_o*100, 'g-','linewidth',2)
%legend('Free', 'assim','Obs','bold','fontsize',12,'Location','NorthWest')
legend('Free', 'assim','Steric est. (IPCC)','bold','fontsize',12,'Location','NorthWest')
plot(time_yr,time_yr*a_f(1)+a_f(2),'b-','linewidth',1)
plot(time_yr,time_yr*a_a(1)+a_a(2),'r-','linewidth',1)
b_o=time_yr(1)*((a_a(1)+a_f(1))/2-0.08)+(a_a(2)+a_f(2))/2;
plot(time_yr,time_yr*0.08+b_o,'g--','linewidth',1)
b_o=time_yr(1)*((a_a(1)+a_f(1))/2-0.14)+(a_a(2)+a_f(2))/2;
plot(time_yr,time_yr*0.14+b_o,'g--','linewidth',1)
%plot(time_yr,time_yr*0.08+(a_f(2)+a_a(2))/2,'g--','linewidth',1)
%plot(time_yr,time_yr*0.14+(a_f(2)+a_a(2))/2,'g--','linewidth',1)
xlabel('Year','fontweight','bold','fontsize',12)
ylabel('MSL [cm]','fontweight','bold','fontsize',12)
print('-depsc2','MSL_evolution.eps')
