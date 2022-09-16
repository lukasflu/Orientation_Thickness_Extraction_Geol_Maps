
function TRACE = extractBeta(TRACE)

% BETA SIGNAL
% Extraction of Beta signal (part of TIE)
% Extracting the angular distance between each individual chord plane pole
% and the FIRST chord plane pole(reference).
%
% ----------
% INPUT
% TRACE   -> structure containing basic TRACE information (any TRACE set, -
%            could also be FAULTS). Fields needed:
%           -> TRACE.index    = ordered index array of trace 
%                               points within the matrix. 
%           -> TRACE.matrix   = matrix size of BED or TEC
%               Segment.ChdPlane    = structure of chord plane information
%                   -> ChdPlane.normal  = vector (x,y,z)
%                                         of each chord plane
%
%               Segment.ChdPlaneR   = structure of chord plane information 
%                                     based on reverse orientation analysis
%                                     same structure as Segment.ChdPlane
%                   -> ChdPlane.normal  = vector (x,y,z) of each
%                                         chord plane
% ----------            
% OUTPUT
% TRACE   -> structure containing TRACE information (as input) with added fields:
%           -> TRACE.Segment  = structure of trace segments. Fields
%                               of structure: 
%               Segment.ChdPlane  = structure of Chord plane information
%                    -> ChdPlane.beta  = beta through each chord plane
%                    
%               Segment.ChdPlaneR = structure of Chord plane information 
%                                   based on reverse orientation analysis
%                                   same structure as Segment.ChdPlane
%                   -> ChdPlane.beta   = beta through each chord plane


%%

% Normal signal
for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    for s = 1:length(Segment)        
        % definitions & allocations
        ChdPlane    = Segment(s).ChdPlane;
        strpl       = length(ChdPlane);
        bet         = zeros(strpl,1);
        normal      = vertcat(ChdPlane.normal);
        normal      = normal./norm(normal);
        refp        = ChdPlane(1).normal;
        refp        = refp/norm(refp);
        
        % angle (beta) calculation (small angle btw oriented vectors/normals)
        for k = 1:strpl
            bet(k)    = angleBtwVec(normal(k,:),refp);
        end
        
        a = find(~isnan(bet));
        bnn = bet(a);
        
        for j = 2:length(bnn)
            if bnn(j)-bnn(j-1) > 90
                bet(a(j)) = abs(bet(a(j))-180);
                bnn(j) = bet(a(j));
            end           
        end
        
        % storing it in the TRACE structure
        for k = 1:strpl
            TRACE(n).Segment(s).ChdPlane(k).beta = bet(k);
        end               
    end
end


% Reverse signal
for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    
    for s = 1:length(Segment)        
        % definitions & allocations
        ChdPlaneR   = Segment(s).ChdPlaneR;
        strpl       = length(ChdPlaneR);
        bet         = zeros(strpl,1);
        normal      = vertcat(ChdPlaneR.normal);
        refp        = ChdPlaneR(1).normal;
        
        % angle (beta) calculation (small angle btw oriented vectors/normals)
        for k = 1:strpl
            bet(k)    = angleBtwVec(normal(k,:),refp);
        end
        
        for j = 2:strpl
            if bet(j)-bet(j-1) > 90
                bet(j) = abs(bet(j)-180);
            end           
        end
        
        % storing it in the TRACE structure
        for k = 1:strpl
            TRACE(n).Segment(s).ChdPlaneR(k).beta = bet(k);
        end                
    end
end