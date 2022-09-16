            
function TRACE = sortTRACE(TRACE)

% SORT TRACE indexes
% A trace must have an oriented, ordered and sorted structure of indexes
% (TIE is based on that principle)
%
% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
%              could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.matrix   = matrix size of BED or TEC
% ----------            
% OUTPUT
% TRACE     -> structure containing basic TRACE information (exaclty as input), where
%              the array of TRACE.index  is re-ordered according to its neighbors.
             
             
%%

for t = 1:length(TRACE)
    
    tm                  = zeros(TRACE(t).matrix);
    tm(TRACE(t).index)  = 1; 
    edges               = bwmorph(tm,'endpoints');                          % identifies the edges of each til (always two) --> starting and end points
    a                	= find(edges==1);
    
    if isempty(a)                                                           % if a is empty the trace segment is circular
        a               = [TRACE(t).index(2),TRACE(t).index(1)];
        tm(a(2)) = 0;
    end
    
    if length(a)>2
        r = 1;
        
        while length(a) > 2                                                 % if there are three (or more) endings                                      
         ai = 1;   
            while ai <= length(a)
                neigha = neighborPointsXn(a(ai),TRACE(t).matrix(1),TRACE(t).matrix(2),r);
                nna    = length(neigha(tm(neigha)==1));
                if nna > 1 || nna < 1
                    a(ai) = [];
                else
                    ai = ai + 1;
                end
            end
            r = r+1;
        end
    end
    
    if isempty(a)                                                           % if a is empty the trace segment is circular
        a               = [TRACE(t).index(2),TRACE(t).index(1)];
        tm(a(2)) = 0;
    end
    
    index               = zeros(length(TRACE(t).index),1);
    if length(a) == 1
        index(1)                = a(1);
    else
        index(1)                = a(1);    
        index(end)              = a(2);
    end
    b                           = a(1);
    
    
    l   = length(TRACE(t).index);
    k   = 2;
    nn  = 1;
    while nn > 0 && k < l                                                   % sorting process according to the connecting neighbor
        neigh   = neighborPoints8n(b,TRACE(t).matrix(1),TRACE(t).matrix(2));
        posn    = neigh(tm(neigh)==1);
        nn      = length(posn);
        
        if nn == 1                                                          % if there is only one positive neighbor - do as usual
                index(k)        = posn;
                k               = k+1;
                tm(b)    = 0;
                b               = posn;          
        end
        
        if nn > 1                                                           % if there are more than one positive neighbors...
            
            r       = 1;
            nn2     = nn;
            tm(posn)     = -1;
            tm(b)        = 1000;
            
            while nn2 > 1
                r           = r+1;
                neigh2      = neighborPointsXn(b,TRACE(t).matrix(1),TRACE(t).matrix(2),r);
                posn2       = neigh2(tm(neigh2)==1);
                tm(posn2)   = -1;
                nn2         = length(posn2);
            end
            
            nn3     = nn2;
            posn3   = posn2;
            
            while nn3 == 1
                b2          = posn3;
                tm(b2)      = 10000;
                neigh3      = neighborPointsXn(b2,TRACE(t).matrix(1),TRACE(t).matrix(2),1);
                posn3       = neigh3(tm(neigh3)<0);
                nn3         = length(posn3);
                
                if length(neigh3(tm(neigh3)==1000)) == 1   
                    tm(tm<0) = 0;
                    tm(tm>1) = 1;
                    break
                end
            end           
        end
    end

    index           = index(index~=0);
    TRACE(t).index  = index;

end