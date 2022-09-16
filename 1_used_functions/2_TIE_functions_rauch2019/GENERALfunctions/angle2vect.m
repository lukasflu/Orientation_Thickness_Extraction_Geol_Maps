
function [vx,vy,vz]=angle2vect(trend,plunge)

% ANGLE to VECTOR
% calculates the directional vector (length = 1) from a line defined by angles -
% trend and plunge
% ----------
% INPUT
% trend, plunge -> angles of azimuth (dip azimuth) and dip of plane.  
% ----------
% OUTPUT
% [vx, vy, vz]  -> coordinate of line vector;

k       =  1:length(trend);
vz(k)   = -sind(plunge(k));
vx(k)   =  sind(trend(k)).* cosd(plunge(k));
vy(k)   =  cosd(trend(k)).* cosd(plunge(k));
