
function neigh = neighborPoints4n(n,cellnumberX,cellnumberY)

% NEIGHBOUR INDEXES (4-connectivity)
% define array containing all neighbour indexes of a certain point in a
% matrix
% ----------
% INPUT
% cellnumberX, cellnumberY  -> size of matrix in X and Y
% n                         -> index in matrix of point analysed  
% ----------
% OUTPUT
% neigh     -> array with indexes of 4-connectivity neighbors

cellnumberXY    = (cellnumberY*cellnumberX)-cellnumberX + 1;
neigh           = zeros(length(n),4);

k = 1:length(n);
neigh(k,:)      = [n(k)+1 , n(k)-1 , n(k)-cellnumberX , n(k)+cellnumberX];

if rem(n(k),cellnumberX)   == 0   
    neigh(k,:)  = [n(k)-1 , n(k)-cellnumberX , n(k)+cellnumberX , NaN];
end

if rem(n(k)-1,cellnumberX) == 0
    neigh(k,:)  = [n(k)+1 , n(k)-cellnumberX , n(k)+cellnumberX , NaN];
end

if n(k) < cellnumberX
    neigh(k,:)  = [n(k)-1 , n(k)+1 , n(k)+cellnumberX , NaN];
end

if n(k) > cellnumberXY
    neigh(k,:)  = [n(k)-1 , n(k)+1 , n(k)-cellnumberX , NaN];
end

if n(k) == 1
    neigh(k,:)  = [n(k)+1 , n(k)+cellnumberX , NaN , NaN];
end

if n(k) == cellnumberX
    neigh(k,:)  = [n(k)-1 , n(k)+cellnumberX , NaN , NaN];
end

if n(k) == cellnumberXY
    neigh(k,:)  = [n(k)+1 , n(k)-cellnumberX , NaN , NaN];
end

if n(k) == cellnumberX*cellnumberY
    neigh(k,:)  = [n(k)-1 , n(k)-cellnumberX , NaN , NaN];
end

neigh(isnan(neigh)) = [];

            

