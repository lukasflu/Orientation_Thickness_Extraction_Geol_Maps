
function [x_stereo,y_stereo] = stereoPole(azim,dip)

% POLE ON STEREONET
% extracts coordinates of the pole of certain projected plane
% based on: Middleton, G.V.(2000). Data analysis in the earth sciences using Matlab®. 
%           Upper Saddle River, NJ: Prentice Hall. 
% ----------
% INPUT
% azim, dip             -> dip azimuth and dip of the projected plane 
% ----------
% OUTPUT
% [x_stereo, y_stereo]  -> coordinates of pole in stereonet

normal          = angle2normal(azim, dip);
[trend,plunge]  = vect2angle(normal);

radius          = tan(pi*(90-plunge)/360);
f1              = find((trend>90)&(trend<=180));
trend(f1)       = 180 -trend(f1);
f2              = find ((trend>180)&(trend<=270));
trend(f2)       = trend(f2)-180;
f3              = find(trend>270);
trend(f3)       = 360-trend(f3); 

x_stereo        = sind(trend).*radius;
y_stereo        = cosd(trend).*radius;

y_stereo(f1)    = cosd(trend(f1)).* - radius(f1);
x_stereo(f2)    = sind(trend(f2)).* - radius(f2);
y_stereo(f2)    = cosd(trend(f2)).* - radius(f2);
x_stereo(f3)    = sind(trend(f3)).* - radius(f3);






    
