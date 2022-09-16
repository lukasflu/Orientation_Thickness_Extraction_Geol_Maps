
function [TECcoor, TECattr] = loadTecto(shapefile, X, Y)

% TECTO DATA
% Loading vector data of tectonic boundaries
%
% ----------
% INPUT
% shapefile     --> name of shapefile containing bedrock data (line
%                   data)
% X, Y          --> Coordinate vectors (see loadCoord.mat)
%
% ----------
% OUTPUT
% TECcoor       --> structure with coordinates of shapefile with tectonic 
%                   boundaries which touch the X and Y extent (one 
%                   structure is one polyline)
% TECattr       --> structure with attributes of shapefile with tectonic 
%                   boundaries which touch the X and Y extent (one 
%                   structure is one polyline)
 
                  
%%

[TECcoor,TECattr] = shaperead(shapefile);

% redefining extent borders extracting them from Matrix coordinates
xlim = [X(1)-1, X(length(X))+1]; 
ylim = [Y(length(Y))-1, Y(1)+1];

% finding all polygons, which are at least part of the subzone
j = 1;
f = zeros(10000,1); %allocating an f vector, fixing its maximum size at 1000 polygons / subzone
for i = 1:length(TECcoor)
    xi = TECcoor(i).X;
    yi = TECcoor(i).Y;
    
    for k = 1:length(xi)
        if  xi(k) > min(xlim) && xi(k) < max(xlim) && ...
            yi(k) > min(ylim) && yi(k) < max(ylim)
            f(j) = i;
            j    = j+1;
        break
        end   
    end
end
f = f(f~=0); 

TECcoor = TECcoor(f);
TECattr = TECattr(f);

