
                           
function TRACE = extractAlpha(TRACE)

% ALPHA SIGNAL
% Extraction of Alpha signal (part of TIE)
% Extracting the angular distance between each individual connecting chord
% and the FIRST connecting chord (reference).
%
% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
%              could also be FAULTS). Fields needed:
%               -> TRACE.Segment  = structure of trace segments.
%                  Fields needed:
%                       Segment.Chords    = sturcture of connecting chord information
%                           -> Chords.vector   = vector (x,y,z) of each individual chord
%
%                       Segment.ChordsR   = sturcture of connecting chord information
%                                           based on reverse orientation analysis
%                                           same structure as Segment.Chords
% ----------           
% OUTPUT
% TRACE     -> structure containing TRACE information (as input) with added fields:
%               -> TRACE.Segment  = structure of trace segments. 
%                       Segment.Chords    = sturcture of connecting chord information
%                           -> Chords.alpha         = alpha for each connecting chord
%
%                       Segment.ChordsR   = sturcture of connecting chord information
%                                           based on reverse orientation analysis
%                           -> Chords.alpha  = alpha for each connecting chord

                            
%%

% extracting the normal signal
for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    
    for s = 1:length(Segment)
        
        Chords      = Segment(s).Chords;
        n2          = length(Chords);
        vIni        = Chords(1).vector; 
        for i = 1:n2
            vAna            = Chords(i).vector;
            angle           = angleBtwVec(vAna,vIni);
            Chords(i).alpha = angle;
        end
        TRACE(n).Segment(s).Chords = Chords;
    end
end


% extracting the "reverse" signal
for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    
    for s = 1:length(Segment)

        ChordsR     = Segment(s).ChordsR;
        n2          = length(ChordsR);
        vIni        = ChordsR(1).vector; 
        
        for i = 1:n2
            vAna                = ChordsR(i).vector;
            angle               = angleBtwVec(vAna,vIni);
            ChordsR(i).alpha    = angle;
        end
        TRACE(n).Segment(s).ChordsR = ChordsR;
    end
end

