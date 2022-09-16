
function [azim,dip] = normal2angle(normal)

% NORMAL to ANGLE (PLANE ORIENTATION)
% calculates the orientation (in dip azimuth and dip) of the plane
% according to the normal (in x,y,z)
% ----------
% INPUT
% normal        -> normal vector: v = [x,y,z];
% ----------
% OUTPUT
% azim, dip     -> azimuth (dip azimuth) and dip of plane expressed in angles.


if normal(3) < 0
    normal = normal*-1;
end

zvector = [0 0 1]; 
dip     = atan2d(norm(cross(normal,zvector)),dot(normal,zvector)); % angle between normal vector and vertical vector
azim    = atand(abs(normal(1))/abs(normal(2))); % angle between x and y components

if normal(1) > 0 && normal(2) <= 0
    azim = 180 - azim;
end

if normal(1) <= 0 && normal(2) < 0
    azim = 180 + azim;
end

if normal(1) <= 0 && normal(2) > 0
    azim = 360 - azim;
end