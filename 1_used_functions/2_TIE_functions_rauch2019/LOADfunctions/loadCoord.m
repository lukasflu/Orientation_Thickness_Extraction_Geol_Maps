
function [X,Y,Z] = loadCoord(geotif, lim)

% COORDINATES
% Load coordinate data and transform it in vector-matrix form
%
% ----------
% INPUT
% geotif -> filename of DEM in geotif format (e.g. 'geneva.tif')    
% lim    -> limits of coordinates within the geotif that is loaded
%           lim = [minX, maxX; minY, maxY];
%           if the entire geotif needs to be loaded, define lim = [];
%           
% ----------            
% OUTPUT
% Coordinates of X, Y and Z in matrix form:
%           X -> row vector
%           Y -> column vector
%           Z -> matrix of size X and Y
            

%%

[Z,Rm,~]  = geotiffread(geotif);

X  =            Rm(3) + Rm(2): Rm(2): Rm(3)+ size(Z,2)* Rm(2);
Y  = transpose( Rm(6) - Rm(2): Rm(4): Rm(6)+ size(Z,1)* Rm(4));

if ~isempty(lim)
    xlim = lim(1,:);
    ylim = lim(2,:);
    
    n1   = find(X > (min(xlim)-1));
    n2   = find(X(n1) < (max(xlim)+1));
    m1   = find(Y > (min(ylim)-1));
    m2   = find(Y(m1) < (max(ylim)+1));

    X    = (X(n1(n2)));
    Y    = (Y(m1(m2)));
    Z    = (Z(m1(m2),n1(n2)));    
end



