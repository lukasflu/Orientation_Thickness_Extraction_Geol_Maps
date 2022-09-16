
function [x_stereo,y_stereo] = greatCircle(azim,dip)

% GREAT CIRCLES
% extracts coordinates of great circle of a certain plane orientation
% based on: Middleton, G.V.(2000). Data analysis in the earth sciences using Matlab®. 
%           Upper Saddle River, NJ: Prentice Hall. 
% ----------
% INPUT
% azim, dip     -> angles of azimuth (dip azimuth) and dip of plane  
% ----------
% OUTPUT
% [x_stereo, y_stereo]  -> coordinates of great circle points


azim2   = -deg2rad(azim) + pi/2;
dip2    =  deg2rad(dip);

N       = 50;
psi     = 0:pi/N:pi;

radip   = atan(tan(dip2)*sin(psi));
rproj   = tan((pi/2-radip)/2);
x1      = rproj.*sin(psi);
y1      = rproj.*cos(psi);

x_stereo    = x1*cos(azim2) + y1*sin(azim2);
y_stereo    = x1*sin(azim2) - y1*cos(azim2);




    
