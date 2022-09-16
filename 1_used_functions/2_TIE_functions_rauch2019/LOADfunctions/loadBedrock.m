
function [BEDcoor, BEDattr] = loadBedrock(shapefile,X,Y)

% BEDROCK DATA
% Loading bedrock vector data
%
% ----------
% INPUT
% shapefile     --> name of shapefile containing bedrock data (polygon
%                   data)
% X, Y          --> Coordinate vectors (see loadCoord.mat)
% ----------
% OUTPUT
% BEDcoor       --> structure with coordinates of bedrock shapefile cut
%                   according the X and Y extent (one structure is one              
%                   polygon)
% BEDattr       --> structure with attributes of bedrock shapefile cut
%                   according the X and Y extent (one structure is one
%                   polygon)
                  

%%

[BEDcoor,BEDattr] = shaperead(shapefile);

% redefining extent borders extracting them from Matrix coordinates
xlim = [X(1)-1, X(length(X))+1]; 
ylim = [Y(length(Y))-1, Y(1)+1];

% redefining extent limits as polygon (five coordinate points)
lim  = [    min(xlim),max(ylim);...
            min(xlim),min(ylim);...
            max(xlim),min(ylim);...
            max(xlim),max(ylim);...
            min(xlim),max(ylim)         ];

% finding all polygons, which are at least part of the subzone
j = 1;
f = zeros(10000,1); 
for i = 1:length(BEDcoor)
    xi = BEDcoor(i).X;
    yi = BEDcoor(i).Y;

    for k = 1:length(BEDcoor(i).X)
        if  xi(k) > min(xlim) && xi(k) < max(xlim) && ...
            yi(k) > min(ylim) && yi(k) < max(ylim)
            f(j) = i;
            j    = j+1;
        break
        end   
    end
end
f = f(f~=0);

% cutting all polygons according to the subzone 
for  m = 1:length(f) 
    [x2,y2]         = poly2cw(BEDcoor(f(m)).X, BEDcoor(f(m)).Y);
    [limx2,limy2]   = poly2cw(lim(:,1),lim(:,2));
    [xb, yb]        = polybool('intersection', x2, y2, limx2,limy2);
    
    BEDcoor(f(m)).X = xb;
    BEDcoor(f(m)).Y = yb;
end

BEDcoor = BEDcoor(f);
BEDattr = BEDattr(f);
    
