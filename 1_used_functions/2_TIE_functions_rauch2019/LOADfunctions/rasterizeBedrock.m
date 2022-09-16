
function BED = rasterizeBedrock(BEDcoor, BEDattr, X, Y, field)

% RASTERIZE/GRID BEDROCK
% Rasterizing vector data of Bedrock data
%
% ----------
% INPUT
% BEDattr, BEDcoor  --> structures loaded from shapefile (see loadTBedrock.mat)
% X, Y              --> Coordinate vectors (see loadCoord.mat)
% field             --> field in structure that should be needed to
%                       distinguish between different types of tectonic 
%                       boundaries. The field value must be a number.
% ----------
% OUTPUT
% BED               --> raster/grid of size [length(Y),length(X)](as size Z)
%                       where bedrock cells have the specified number
%                       according to the field input). 
%                       Empty cells (no outcrop) are filled with NaNs
   
                      
%%

[mX,mY] = meshgrid(X,Y);
BED     = zeros(length(Y),length(X));
    
for j = 1:length(BEDcoor) 
    polyxi  = [BEDcoor(j).X];
    polyyi  = [BEDcoor(j).Y];
    in      = inpolygon(mX, mY, polyxi, polyyi);
    K       = str2double(vertcat(BEDattr(j).(field)));
    BED(in) = K;
end

BED = flipud(BED);
BED(BED == 0) = NaN;



