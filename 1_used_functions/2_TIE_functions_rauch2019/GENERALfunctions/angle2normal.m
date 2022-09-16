
function normal = angle2normal(azim, dip)

% ANGLE to NORMAL
% calculates the normal of the plane, which is only defined by angles -
% dip azimuth and dip
% ----------
% INPUT
% azim, dip -> angles of azimuth (dip azimuth) and dip of plane.  
% ----------
% OUTPUT
% normal    -> normal vector: normal = [normalx,normaly,normalz];

normalz = cosd(dip);
normalx = sind(dip)*sind(azim);
normaly = sind(dip)*cosd(azim);
normal  = [normalx, normaly, normalz];