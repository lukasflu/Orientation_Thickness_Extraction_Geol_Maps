
function TEC = rasterizeTecto(TECcoor,TECattr,X,Y,field)

% RASTERIZE / GRID TECTO
% Rasterizing vector data of Tectonic boundaries
%
% ----------
% INPUT
% TECattr, TECcoor  --> structures loaded from shapefile (see loadTecto.mat)
% X, Y              --> Coordinate vectors (see loadCoord.mat)
% field             --> field in structure that should be needed to
%                       distinguish between different types of tectonic 
%                       boundaries. The field value must be a number.
% ----------
% OUTPUT
% TEC               --> raster/grid of size [length(Y),length(X)](as size Z)
%                       where tectonic boundaries cells have the
%                       specified number (according to the field input). 
%                       Empty cells - (no tectonic boundary) are filled
%                       with NaNs
                      
                      
%%

TEC     = zeros(length(Y),length(X));                   % matrix of size [X,Y]
cs      = X(2)-X(1);                                    % cellsize

for i = 1:length(TECcoor)
    
    K   = TECattr.(field);
    if ~isnumeric(K)
        K = str2double(K);
    end

    linex   = TECcoor(i).X';
    linex   = linex(~isnan(linex));
    liney   = TECcoor(i).Y';
    liney   = liney(~isnan(liney));

    for j = 1:length(linex)-1
        p(1,:) = [linex(j),     liney(j)    ];
        p(2,:) = [linex(j+1),   liney(j+1)  ];
        
        nPixels = round(max(abs(p(1,:)-p(2,:)))/cs+1);  % number of Pixels combining two points in a matrix 
        if nPixels > 1
            xj  = linspace(p(1,2), p(2,2),nPixels);     % creating x vector regularly spaced
            yj  = linspace(p(1,1), p(2,1),nPixels);

            fx  = find(xj < min(Y) | xj > max(Y));      % finding pixels which are out of the subzone
            fy  = find(yj < min(X) | yj > max(X));
            xj([fx,fy]) = [];                           % removing both pair pixels and pixels out of range
            yj([fx,fy]) = [];

            for k = 1:length(xj)
                [~,ix] = min(abs(X - yj(k)));
                [~,iy] = min(abs(Y - xj(k)));
                if k > 1
                   if  abs(ix - ixold) > 1
                       ix = (ix + ixold)/2;
                   elseif abs(iy - iyold) > 1
                       iy = (iy + iyold)/2;
                   end
                end
                TEC(iy,ix)  = K; 
                ixold       = ix;
                iyold       = iy;
            end
        end
    end
    
end

% removing spur pixels
TEC2            = TEC;
TEC2(TEC2>0)    = 1;

TEC2            = bwmorph(TEC2,'thin');
TEC2            = bwmorph(TEC2,'spur');
TEC(TEC2==0)    = NaN;

end

    
