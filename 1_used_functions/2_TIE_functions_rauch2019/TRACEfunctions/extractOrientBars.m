            
function TRACE = extractOrientBars(TRACE)

% EXTRACTION OF ORIENTATION BARS (TIE)
% Extracts orientation bars from chord planes. Chord plane values are
% distributed along the trace.
%
% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
%              could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.Segment  = structure of trace segments. Fields
%                                   of structure:
%                       Segment.index     = indexes of Trace.index. If only
%                                           one segment exists, Segment.index =
%                                           1:length(TRACE.index)
%                       Segment.delta     = delta (D) value used for the analysis
%                       Segment.ChdPlane  = structure of Chord plane information
%                           -> ChdPlane.plane_orient  = [dip direction, dip] of each chord plane
%                           -> ChdPlane.beta          = beta through each chord plane
%                                                       chords that form a chord plane normalized
%                                                       to the total length of the trace
%                       Segment.ChdPlaneR = structure of Chord plane information 
%                                           based on reverse orientation analysis
%                                           same structure as Segment.ChdPlane
%                           -> ChdPlaneR.plane_orient = [dip direction, dip] of each chord plane
%                           -> ChdPlaneR.beta         = beta through each chord plane
% ----------            
% OUTPUT
% TRACE     -> structure containing TRACE information (as input) with added fields:
%               -> TRACE.orientbar    = orientation bars for each point on TRACE
%                                       based on the chord planes
                
                
%%


for t = 1:length(TRACE)
    Segment = TRACE(t).Segment;
    
    li      = length(TRACE(t).index);
    or_new  = zeros(li,3);    % new orientation vector as long as the segment indexes

    for s = 1:length(Segment)
        bet     = [Segment(s).ChdPlane.beta];
        betI    = [Segment(s).ChdPlaneR.beta];
        
        if sum(bet) > sum(betI)
            or      = flipud(vertcat(Segment(s).ChdPlaneR.plane_orient));
        else
            or      = vertcat(Segment(s).ChdPlane.plane_orient);
        end
        
        d           = Segment(s).delta;   % => delta - for string calculation
        si          = Segment(s).index;

        if mod(d,2)>0                     % delta - for string plane calculation
            dd = (d-mod(d,2))/2;
        else
            dd = d/2;
        end

        for k = 1:length(or(:,1))
            [v1x,v1y,v1z]   = angle2vect(or(k,1),or(k,2));
            v1              = [v1x,v1y,v1z];
            anchora         = d+k;
            anchorb         = dd + d + k;
            vancha          = k:anchora;
            vanchb          = dd+k:anchorb;

            for a = vancha
                or_new(si(a),:)  = or_new(si(a),:)+v1;
            end
            for b = vanchb
                or_new(si(b),:)  = or_new(si(b),:)+v1;
            end
        end
    end
    
    for m = 1:li
       or_new(m,:)  = or_new(m,:)/norm(or_new(m,:));
    end  

    TRACE(t).orientbar  = or_new;
end

