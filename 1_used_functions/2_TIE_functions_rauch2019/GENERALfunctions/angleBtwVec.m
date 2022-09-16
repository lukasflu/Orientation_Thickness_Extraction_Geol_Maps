
function angle = angleBtwVec(v1,v2)

% ANGLE BETWEEN 2 VECTORS
% Small angle between two directional oriented vectors
% ----------
% INPUT
%   -> v1: first vector (x,y,z)
%   -> v2: second vector (x,y,z)
% ----------
% OUTPUT
%   -> angle: angle betwee the two vectors

v1n     = v1/norm(v1);
v2n     = v2/norm(v2);
angle   = real(acosd(dot(v1n,v2n)));


