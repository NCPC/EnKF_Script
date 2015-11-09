idm=320;
jdm=384;
nx=1440;
ny=689;
nens=30;
CASENAME='NorCPM_ME_mem'
FREE_CASENAME='NorESM1-ME_historicalExt_noAssim_mem'
year_start=1980;
year_end=2003;
nby=year_end-year_start+1;
norcpm_path='/work/fanf/NorCPM_ME/'
free_path='/work/fanf/FREE_ME/'
p90=0;
p92=0;
p94=0;
p95=0;
p96=0;
p90_path='/work/fanf/Predict_1990/'
p95_path='/work/fanf/Predict_1995/'
p92_path='/work/fanf/Predict_1992/'
p96_path='/work/fanf/Predict_1996/'
p94_path='/work/fanf/Predict_1994/'
obs_path='/work/fanf/noresm/SSH/'
plon=ncgetvar('/work/fanf/noresm/grid.nc','plon');
plat=ncgetvar('/work/fanf/noresm/grid.nc','plat');
pdepth=ncgetvar('/work/fanf/noresm/grid.nc','pdepth');
parea=ncgetvar('/work/fanf/noresm/grid.nc','parea');
pmaskspg=find(plon>-60 & plon<-15 & plat>48 &plat<65);
pmask=find(pdepth<1);
parea(pmask)=nan;
paream=nanmean(parea(:));
latitude=ncgetvar('/work/shared/nn9039k/NorCPM/Obs/SSH/ssh_l4_cls_0.25.nc','latitude');
longitude=ncgetvar('/work/shared/nn9039k/NorCPM/Obs/SSH/ssh_l4_cls_0.25.nc','longitude');
lon=repmat(longitude,1,ny);
lat=repmat(latitude',nx,1);
mask=find(lon>180);
lon(mask)=lon(mask)-360;
maskspg_obs=find(lon>-60 & lon<-15 & lat>48 &lat<65);
height=squeeze(ncgetvar('/work/shared/nn9039k/NorCPM/Obs/SSH/ssh_l4_cls_0.25.nc','height'));
time=1;
if (~exist('SPG-ind.mat','file'))
   for year=year_start:year_end
     year
     for k=1:nens
         assh=zeros(idm,jdm); 
         fssh=zeros(idm,jdm); 
         p90ssh=zeros(idm,jdm); 
         p92ssh=zeros(idm,jdm); 
         p94ssh=zeros(idm,jdm); 
         p95ssh=zeros(idm,jdm); 
         p96ssh=zeros(idm,jdm); 
         nbp90=0;
         nbp92=0;
         nbp95=0;
         nbp96=0;
         nbp94=0;
         for month=1:12
              assh=assh+ncgetvar([norcpm_path CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
           
           if (exist([free_path   FREE_CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              fssh=fssh+ncgetvar([free_path  FREE_CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
           else
              fssh(:,:)=nan;
           end
           if (p90 & exist([p90_path CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              p90ssh=p90ssh+ncgetvar([p90_path  CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
              nbp90=nbp90+1;
           end
           if (p92 & exist([p92_path   CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              p92ssh=p92ssh+ncgetvar([p92_path   CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
              nbp92=nbp92+1;
           end
           if (exist([p94_path  CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              p94ssh=p94ssh+ncgetvar([p94_path  CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
              nbp94=nbp94+1;
           end
           if (p95 & exist([p95_path   CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              p95ssh=p95ssh+ncgetvar([p95_path   CASENAME num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
              nbp95=nbp95+1;
           end
           if (p94 & exist([p96_path  CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'file'))
              p96ssh=p96ssh+ncgetvar([p96_path  CASENAME  num2str(k,'%2.2d') '.micom.hm.' num2str(year,'%4.4d') '-' num2str(month,'%2.2d') '.nc'],'sealv');
              nbp96=nbp96+1;
           end
         end 
         assh(pmask)=nan;
         fssh(pmask)=nan;
         p90ssh(pmask)=nan;
         p92ssh(pmask)=nan;
         p94ssh(pmask)=nan;
         p95ssh(pmask)=nan;
         p96ssh(pmask)=nan;
         p90ssh=p90ssh/nbp90;
         p92ssh=p92ssh/nbp92;
         p94ssh=p94ssh/nbp94;
         p95ssh=p95ssh/nbp95;
         p96ssh=p96ssh/nbp96;
         assh=assh/12;
         fssh=fssh/12;
         aspg2_ind(time,k)=nanmean(assh(pmaskspg).*parea(pmaskspg)/paream);
         fspg2_ind(time,k)=nanmean(fssh(pmaskspg).*parea(pmaskspg)/paream);
         p90spg2_ind(time,k)=nanmean(p90ssh(pmaskspg).*parea(pmaskspg)/paream);
         p92spg2_ind(time,k)=nanmean(p92ssh(pmaskspg).*parea(pmaskspg)/paream);
         p94spg2_ind(time,k)=nanmean(p94ssh(pmaskspg).*parea(pmaskspg)/paream);
         p95spg2_ind(time,k)=nanmean(p95ssh(pmaskspg).*parea(pmaskspg)/paream);
         p96spg2_ind(time,k)=nanmean(p96ssh(pmaskspg).*parea(pmaskspg)/paream);
     end 
     time=time+1;
   end
   cnt=1
   for year=max(1993,year_start):min(year_end,2004)
      ossh=nanmean(height(:,:,(cnt-1)*12+1:cnt*12),3);
      ospg2_ind(cnt)=nanmean(ossh(maskspg_obs));
      cnt=cnt+1;
   end
   ospg2_ind=(ospg2_ind-mean(ospg2_ind))*100;

   %mean_spg=mean(mean(aspg2_ind(14:end,:),1))
   mean_spg=mean(mean(aspg2_ind(max(1993-year_start+1,0):end,:),1))
   mean_fspg=mean(nanmean(fspg2_ind(max(1993-year_start+1,0):end,:),1))
   for  k=1:nens
      aspg2_ind(:,k)=(aspg2_ind(:,k)-mean_spg)*100;
      fspg2_ind(:,k)=(fspg2_ind(:,k)-mean_spg)*100;
      p90spg2_ind(:,k)=(p90spg2_ind(:,k)-mean_spg)*100;
      p92spg2_ind(:,k)=(p92spg2_ind(:,k)-mean_spg)*100;
      p94spg2_ind(:,k)=(p94spg2_ind(:,k)-mean_spg)*100;
      p95spg2_ind(:,k)=(p95spg2_ind(:,k)-mean_spg)*100;
      p96spg2_ind(:,k)=(p96spg2_ind(:,k)-mean_spg)*100;
   end
   save('SPG-ind.mat','aspg2_ind','fspg2_ind','p90spg2_ind','p92spg2_ind','p95spg2_ind','p94spg2_ind','p96spg2_ind','ospg2_ind')

else
   load SPG-ind.mat
end


mean_aspg=mean(aspg2_ind,2);
mean_fspg=nanmean(fspg2_ind,2);
mean_p90spg=nanmean(p90spg2_ind,2);
mean_p92spg=nanmean(p92spg2_ind,2);
mean_p94spg=nanmean(p94spg2_ind,2);
mean_p95spg=nanmean(p95spg2_ind,2);
mean_p96spg=nanmean(p96spg2_ind,2);


close all
figure(1)
for n=1:nby
   patchy1(n)=quantile(fspg2_ind(n,:),0.75);
   patchx(n)=n+year_start-1;
   patchy1(n+nby)=quantile(fspg2_ind(nby-n+1,:),0.25);
   patchx(n+nby)=nby-n+year_start;
end
h(1)=patch(patchx,patchy1,[0.,.7,1],'edgecolor','none')
hold on

for n=1:nby
   patchy1(n)=quantile(aspg2_ind(n,:),0.75);
   patchx(n)=n+year_start-1;
   patchy1(n+nby)=quantile(aspg2_ind(nby-n+1,:),0.25);
   patchx(n+nby)=nby-n+year_start;
end
h(2)=patch(patchx,patchy1,[1,0.6,1],'edgecolor','none')

clear patchx
if (p90)
   offset=10;
   for n=1:10
      patchy1(n+offset)=quantile(p90spg2_ind(n+offset,:),0.75);
      patchy2(n+offset)=max(p90spg2_ind(n+offset,:));
      patchx(n)=n+year_start+offset-1;
      patchy1(n+10+offset)=quantile(p90spg2_ind(10-n+1+offset,:),0.25);
      patchy2(n+10+offset)=min(p90spg2_ind(10-n+1+offset,:));
      patchx(n+10)=10-n+year_start+offset;
   end
%   h(3)=patch(patchx(1:20),patchy1(offset+1:offset+20),[1,.9,.6],'edgecolor','none')
   h(4)=patch(patchx(1:20),patchy2(offset+1:offset+20),[1,.99,.75],'edgecolor','none')
end
if (p92)
   offset=12;
   for n=1:10
      patchy1(n+offset)=quantile(p92spg2_ind(n+offset,:),0.75);
      patchx(n)=n+year_start+offset-1;
      patchy1(n+10+offset)=quantile(p92spg2_ind(10-n+1+offset,:),0.25);
      patchx(n+10)=10-n+year_start+offset;
   end
   h(4)=patch(patchx(1:20),patchy1(offset+1:offset+20),[1,1,0.8],'edgecolor','none')
end

if (p94)
   offset=14;
   for n=1:10
      patchy1(n+offset)=quantile(p94spg2_ind(n+offset,:),0.75);
      patchx(n)=n+year_start+offset-1;
      patchy1(n+10+offset)=quantile(p94spg2_ind(10-n+1+offset,:),0.25);
      patchx(n+10)=10-n+year_start+offset;
   end
   h(4)=patch(patchx(1:20),patchy1(offset+1:offset+20),[.9,.9,.9],'edgecolor','none')
end


if (p95)
   offset=15;
   for n=1:10
      patchy1(n+offset)=quantile(p95spg2_ind(n+offset,:),0.75);
      patchx(n)=n+year_start+offset-1;
      patchy1(n+10+offset)=quantile(p95spg2_ind(10-n+1+offset,:),0.25);
      patchx(n+10)=10-n+year_start+offset;
   end
   h(4)=patch(patchx(1:20),patchy1(offset+1:offset+20),[.9,1,0.9],'edgecolor','none')
   hold on
end

if (p96)
   offset=16;
   for n=1:10
      patchy1(n+offset)=quantile(p96spg2_ind(n+offset,:),0.75);
      patchx(n)=n+year_start+offset-1;
      patchy1(n+10+offset)=quantile(p96spg2_ind(10-n+1+offset,:),0.25);
      patchx(n+10)=10-n+year_start+offset;
   end
   h(4)=patch(patchx(1:20),patchy1(offset+1:offset+20),[0.7,.3,1],'edgecolor','none')
end



h(3)=plot(max(1993,year_start):min(year_end,2004) ,ospg2_ind,'k-','linewidth',3)
h(4)=plot(year_start:year_end,mean_aspg,'r-','linewidth',2)
h(5)=plot(year_start:year_end,mean_fspg,'b-','linewidth',2)
if (p90)
   h(6)=plot(year_start+offset:year_start+offset+9,mean_p90spg(offset+1:offset+10),'--','Color',[1 .5 .2 ],'linewidth',2)
end
if (p92)
   h(6)=plot(year_start+offset:year_start+offset+9,mean_p92spg(offset+1:offset+10),'--','Color',[.95 .95 0 ],'linewidth',2)
end
if (p94)
h(6)=plot(year_start+offset:year_start+offset+9,mean_p94spg(offset+1:offset+10),'--','Color',[.4 .4 .4],'linewidth',2)
end
if (p95)
   h(6)=plot(year_start+offset:year_start+offset+9,mean_p95spg(offset+1:offset+10),'--','Color',[0 1 0],'linewidth',2)
end
if (p96)
   h(6)=plot(year_start+offset:year_start+offset+9,mean_p96spg(offset+1:offset+10),'--','Color',[.4 0.2 0.6],'linewidth',2)
end
ylabel('SSH [cm]','fontweight','bold','fontsize',12)
xlabel('Year','fontweight','bold','fontsize',12)
if (p90 | p92 | p94 | p95 | p96)
   legend(h(3:6),{'Obs','Analysis','Free','Prediction'},'fontweight','bold','fontsize',12)
else
   legend(h(3:5),{'Obs','Analysis','Free'},'fontweight','bold','fontsize',12)
end
axis([year_start year_end -5 5])
set(gca,'fontsize',12,'fontweight','bold')
%title('Prediction starting in 1995','fontweight','bold','fontsize',12)
print('-depsc2','SPG_Index_ana_ME.eps')


