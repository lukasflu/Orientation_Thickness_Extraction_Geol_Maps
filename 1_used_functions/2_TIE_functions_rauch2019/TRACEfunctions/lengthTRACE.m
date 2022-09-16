           

function TRACE = lengthTRACE(TRACE,mX,mY,Z)

% TRACE LENGTH
% Extracts absolute length (in m) between trace points. 
%
% ----------
% INPUT
% TRACE         -> structure containing basic TRACE information (any TRACE set, -
%                  could also be FAULTS). Fields needed:
%                   -> TRACE.index    = ordered index array of trace 
%                                       points within the matrix. 
% mX, mY, Z     -> Coordinate matrixes of X, Y an Z (see loadCoord.mat). mX
%                  and mY are just the meshgrided version X and Y
% ----------
% OUTPUT
% TRACE         -> structure containing TRACE information (as input) with added field:
%                   -> TRACE.length   = index array of length (in m) between
%                                       two individual points. Sum of the
%                                       array corresponds to the trace length

                        
%%

for t = 1:length(TRACE)
    
    index   = TRACE(t).index;
    xi      = mX(index);
    yi      = mY(index);
    zi      = Z(index);
    li      = zeros(length(index)-1,1);
    
    for i = 1:length(index)-1
        li(i) = norm([xi(i+1),yi(i+1),zi(i+1)]-[xi(i),yi(i),zi(i)]); 
    end
    
    TRACE(t).length = li;
end
