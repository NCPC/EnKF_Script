%function that calcula spherical distance
% Using Haversin formula
% It is better for small angles calculations
function [distance]=Haversin_dist(lona,lata,lonb,latb)

   npts=length(lata);
   pi=4*atan(1.);
   torad=pi/180;
   %Earths radius in km
   rearth=6371.001;
   %Converions
   lat1=lata.*torad;
   lat2=latb.*torad;
   lon1=lona.*torad;
   lon2=lonb.*torad;
   diflon=lon2-lon1;
   diflat=lat2-lat1;
   Haversinlat=(sin(0.5.*diflat)).* (sin(0.5.*diflat));
   Haversinlon=(sin(0.5.*diflon)).* (sin(0.5.*diflon));
   %a=(  Haversinlat + cos(lat1) ) .* cos(lat2) .* Haversinlon;
   a=  Haversinlat + cos(lat1)  .* cos(lat2) .* Haversinlon;
   one=ones(1:npts,1);
   %mina1=min(one,sqrt(a));
   %c=2 .* asin(mina1);
   c=2 .* atan2(sqrt(a),sqrt(1-a));
   distance=rearth .* c;
