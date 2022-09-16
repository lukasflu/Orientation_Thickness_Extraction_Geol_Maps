
function neigh = neighborPointsXn(n,cellnumberX,cellnumberY,x)

% NEIGHBOUR INDEXES with DISTANCE
% define array containing all neighbour indexes of the index n at a given
% distance x in a matrix [cellnumberX,cellnumberY]
% ----------
% INPUT
% cellnumberX, cellnumberY  -> size of matrix in X and Y
% n                         -> index in matrix of point analysed
% x                         -> distance (in pixels) from points
% ----------
% OUTPUT
% neigh     -> array with indexes of neighbors


neigh = [n+x ; n-x; n-x*cellnumberX ; n+x*cellnumberX];
for i = 1:x
    neigh2 = [n-x*cellnumberX+i ; n-x*cellnumberX-i ; n+x*cellnumberX+i ; n+x*cellnumberX-i];
    neigh = [neigh;neigh2];
end
for i = 1:x-1
    neigh2 = [n-(x-i)*cellnumberX + x  ; n-(x-i)*cellnumberX - x; n+(x-i)*cellnumberX + x ; n+(x-i)*cellnumberX - x];
    neigh = [neigh;neigh2];
end
neigh(neigh>cellnumberX*cellnumberY) = NaN;
neigh(neigh<1) = NaN;

% removing bottom cell line
remx1 = rem(n+(x-1),cellnumberX);    
if remx1 < x
    neigh(1) = NaN;
    for i = 1:x       
        neigh([((x-1)+i)*4+1;((x-1)+i)*4+3]) = NaN;
    end
    if remx1 ~= 0
    for r = (1:remx1)+x-remx1 -1
        neigh([r*4+1;r*4+3]) = NaN;
    end
    end
end
    

% removing top cell line
remx2 = rem(n-x,cellnumberX);
if remx2 < 0
    remx2 = remx2*-1;
end
if remx2 > 0
    remx2 = cellnumberX - remx2;
end

if remx2 < x
    neigh(2) = NaN;
    for i = 1:x       
        neigh([((x-1)+i)*4+2;((x-1)+i)*4+4]) = NaN;
    end
    if remx2 ~= 0
    for r = (x-remx2):x-1
        neigh([r*4+2;r*4+4]) = NaN;
    end
    end
end

% removing far left cell line
if n/x <cellnumberX
    neigh(3) = NaN;
    for i = 1:x       
        neigh([i*4+1;i*4+2]) = NaN;
    end
end

% removing far right cell line
cellnumberXY = (cellnumberY*cellnumberX)-cellnumberX;
if n+(x-1)*cellnumberX > cellnumberXY
    neigh(4) = NaN;
    for i = 1:x       
        neigh([i*4+3;i*4+4]) = NaN;
    end    
end

neigh = neigh(~isnan(neigh));
