
function [trend,plunge]=vect2angle(v)

% VECTOR (AXIS) to ANGLE (AXIS ORIENTATION)
% extracts from vectors (vx,vy,vz) its axis directions in angles (geology style) 
% ----------
% INPUT
% v             -> vector: v = [vx,vy,vz];
% ----------
% OUTPUT
% trend, plunge -> angles of trend (plunge azimuth) and plunge of vector.  

if v(3) > 0 
    v = v*-1;
end

trend = abs(atand(v(1)/v(2)));
plunge = atand(abs(v(3))/sqrt(v(1)^2+v(2)^2));

if v(1)>0 && v(2)<=0
    trend = 180-trend;
end

if v(1)<=0 && v(2)<=0
    trend = 180+trend;
end

if v(1)<=0 && v(2)>0
    trend = 360-trend;
end
