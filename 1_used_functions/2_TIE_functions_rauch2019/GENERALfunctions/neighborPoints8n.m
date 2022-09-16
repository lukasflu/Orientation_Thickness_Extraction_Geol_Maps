

function neigh = neighborPoints8n(n,cellnumberX,cellnumberY)

% NEIGHBOUR INDEXES (8-connectivity)
% define array containing all neighbour indexes of a certain point in a
% matrix
% ----------
% INPUT
% cellnumberX, cellnumberY  -> size of matrix in X and Y
% n                         -> index in matrix of point analysed  
% ----------
% OUTPUT
% neigh     -> array with indexes of 8-connectivity neighbors


cellnumberXY = (cellnumberY*cellnumberX)-cellnumberX + 1;

neigh = [n+1 ; n-1 ; n-cellnumberX ; n+cellnumberX; n-cellnumberX+1 ; n-cellnumberX-1 ; n+cellnumberX+1 ; n+cellnumberX-1];

if rem(n,cellnumberX)== 0   
    neigh = [n-1 ; n-cellnumberX ; n+cellnumberX; n-cellnumberX-1; n+cellnumberX-1];
end

if rem(n-1,cellnumberX)== 0
    neigh = [n+1 ; n-cellnumberX ; n+cellnumberX; n-cellnumberX+1; n+cellnumberX+1];
end
if n<cellnumberX
    neigh = [n-1 ; n+1 ; n+cellnumberX; n+cellnumberX+1; n+cellnumberX-1];
end
if n>cellnumberXY
    neigh = [n-1 ; n+1 ; n-cellnumberX; n-cellnumberX+1; n-cellnumberX-1];
end
if n == 1
    neigh = [n+1 ; n+cellnumberX; n+cellnumberX+1];
end
if n == cellnumberX
    neigh = [n-1 ; n+cellnumberX; n+cellnumberX-1];
end
if n == cellnumberXY
    neigh = [n+1 ; n-cellnumberX; n-cellnumberX+1];
end
if n == cellnumberX*cellnumberY
    neigh = [n-1 ; n-cellnumberX; n-cellnumberX-1];
end

            
            

