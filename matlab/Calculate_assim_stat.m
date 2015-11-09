%Script for calculatin statistic at assimilation time
%Launch the script from your RESULTS folder 
%/work/user/noresm/RESULTS/
idm=180;
jdm=193;
RMSE_all=zeros(idm,jdm);
BIAS_all=zeros(idm,jdm);
BIAS_obs_all=zeros(idm,jdm);
SPREAD_all=zeros(idm,jdm);
SPREAD_OBS_all=zeros(idm,jdm);
yr_start=1980;
yr_end=1980;
parea=ncgetvar('grid.nc','parea');
rec=0;
for yr=yr_start:yr_end
   for mm=1:12
      if exist([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'], 'file') == 2
       ipiv=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'ipiv');
       jpiv=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'jpiv');
       inov=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'innovation');
       d=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'d');
       obs_var=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'var');
       mod_var=ncgetvar([num2str(yr) '_' num2str(mm,'%2.2d') '/observations-SST.nc'],'forecast_variance');
       sum_inov=zeros(idm,jdm);
       sum_obs_var=zeros(idm,jdm);
       sum_obs=zeros(idm,jdm);
       sum_spread=zeros(idm,jdm);
       nb_obs=zeros(idm,jdm);
       for k=1:length(inov)
           sum_inov(ipiv(k),jpiv(k))= sum_inov(ipiv(k),jpiv(k))+inov(k);
           sum_obs(ipiv(k),jpiv(k))= sum_obs(ipiv(k),jpiv(k))+d(k);
           sum_spread(ipiv(k),jpiv(k))= sum_spread(ipiv(k),jpiv(k))+mod_var(k);
           sum_obs_var(ipiv(k),jpiv(k))= sum_obs_var(ipiv(k),jpiv(k))+obs_var(k);
           nb_obs(ipiv(k),jpiv(k))=nb_obs(ipiv(k),jpiv(k))+1;
       end
       sum_inov=sum_inov./nb_obs;
       sum_obs=sum_obs./nb_obs;
       sum_spread=sum_spread./nb_obs;
       sum_obs_var=sum_obs_var./nb_obs;
       rec=rec+1;
       mask=find(nb_obs>0);
       paream=nanmean(parea(mask));
       time_RMSE(rec)=nanmean(sqrt(sum_inov(:).^2).*parea(:)/paream);
       time_bias(rec)=nanmean(sum_inov(:).*parea(:)/paream);
       time_spread(rec)=nanmean(sqrt(sum_spread(:)).*parea(:)/paream);
       time_obs(rec)=nanmean(sqrt(sum_obs_var(:)).*parea(:)/paream);
       BIAS_all=BIAS_all+sum_inov;
       BIAS_obs_all=BIAS_obs_all+sum_obs;
       RMSE_all=RMSE_all+sum_inov.^2;
       SPREAD_all=SPREAD_all+sum_spread;
       SPREAD_OBS_all=SPREAD_OBS_all+sum_obs_var;
       date_timeserie(rec)=datenum(yr,mm,15);
    end
   end
end
%%%%%%%%%%%%%
figure(1)
plot(date_timeserie,time_RMSE,'r','linewidth',2)
hold on
plot(date_timeserie,time_bias,'r--','linewidth',2)
plot(date_timeserie,time_spread,'b-','linewidth',2)
plot(date_timeserie,time_obs,'g-','linewidth',2)
plot(date_timeserie,sqrt(time_obs.^2+time_spread.^2),'m-','linewidth',2)
legend('RMSE','Bias','spread','obs-std','spread+obs-std')
plot(date_timeserie,zeros(length(date_timeserie),1),'k-')
axis([date_timeserie(1) date_timeserie(end) min(time_bias) max([time_RMSE time_obs+time_spread]) ])
datetick
ylabel('SST [^oC]')
title('Assim stat summary')
print('-depsc2',['Assim_stat_summary.eps']);
%%%%%%%%%%%%%
figure(2)
a=sqrt(RMSE_all/rec);
micom_flat(a,[0.45 0.45 0.45])
m_grid
title(['Mean RMSE minval: ' num2str(min(a(:))) '  maxval ' num2str(max(a(:)))])
colorbar;
colormap(fc100);
caxis([0 1.5])
print('-djpeg95',['Spatial_RMSE.jpg']);
%%%%%%%%%%%%%
figure(3)
a=(BIAS_all./rec);
micom_flat(a,[0.45 0.45 0.45])
m_grid
colorbar;
colormap(anomwide);
title(['Mean bias minval: ' num2str(min(a(:))) '  maxval ' num2str(max(a(:)))])
caxis([-.5 .5])
print('-djpeg95',['Spatial_Bias.jpg']);
%%%%%%%%%%%%%
%figure(4)
%a=(BIAS_obs_all./rec);
%micom_flat(a,[0.45 0.45 0.45])
%m_grid
%colorbar;
%colormap(anomwide);
%title(['Mean bias minval: ' num2str(min(a(:))) '  maxval ' num2str(max(a(:)))])
%caxis([-.5 .5])
%print('-djpeg95',['Mean_Bias_obs-80-85.jpg']);

%%%%%%%%%%%%%
figure(5)
a=sqrt(SPREAD_all./rec);
micom_flat(a,[0.45 0.45 0.45])
m_grid
colorbar;
colormap(fc100);
title(['Mean mod spread minval: ' num2str(min(a(:))) '  maxval ' num2str(max(a(:)))])
caxis([0 1])
print('-djpeg95',['Mean_spread.jpg']);
%%%%%%%%%%%%%
figure(6)
a=sqrt(SPREAD_OBS_all./rec);
micom_flat(a,[0.45 0.45 0.45])
m_grid
colorbar;
colormap(fc100);
title(['Mean obs spread minval: ' num2str(min(a(:))) '  maxval ' num2str(max(a(:)))])
caxis([0 1])
print('-djpeg95',['Mean_obs-spread.jpg']);
%%%%%%%%%%%%%
