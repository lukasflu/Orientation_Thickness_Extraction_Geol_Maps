               
function TRACE = extractChords(TRACE,mX,mY,Z)

% CONNECTING CHORDS
% Extraction of connecting chords from traces (part of the TIE)
%
% ----------
% INPUT
% TRACE      -> structure containing basic TRACE information (any TRACE set, -
%               could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.Segment  = structure of trace segments. 
%                       Segment.index     = indexes of Trace.index. If only
%                                           one segment exists, Segment.index =
%                                           1:length(TRACE.index)
%
%                       Segment.indexR    = indexes of Trace.index by
%                                           starting the analysis at the other end of the
%                                           trace
% mX, mY, Z  -> Coordinate matrixes of X, Y an Z (see loadCoord.mat). mX
%               and mY are just the meshgrided version of X and Y
%             
% ----------            
% OUTPUT
% TRACE      -> structure containing TRACE information (as input) with added fields:
%               -> TRACE.Segment  = structure of trace segments. 
%                       Segment.delta     = delta (D) value used for the analysis
%
%                       Segment.Chords    = sturcture of connecting chord information
%                           -> Chords.vector        = vector (x,y,z) of each individual chord                         
%                           -> Chords.axtr          = trend of conncecting chord (plunge azimuth)
%                           -> Chords.axpl          = plunge of connecting chord
%
%                       Segment.ChordsR   = sturcture of connecting chord information
%                                           based on reverse orientation analysis
%                                           same structure as Segment.Chords
                            
                            
%%

% Normal trace
for n = 1:length(TRACE)   
    for s = 1:length(TRACE(n).Segment)
        
        % scalar definitions
        l       = length(TRACE(n).Segment(s).index);    % indexes of segments
        indtr   = TRACE(n).index;                       % indexes of trace
        
        if mod(l,2) % length of chord vector depends whether the trace length is even or un even   
            DELTA   = (l-1)/2;
            lstr    = DELTA+1;
        else
            DELTA   = l/2;
            lstr    = DELTA;
        end
        
        TRACE(n).Segment(s).delta   = DELTA; % storing delta, might be usful
        
        % allocations
        chords     = zeros(lstr,3);
        Chords     = struct('vector',cell(1)); % creating a String structure
        trend      = zeros(lstr,1);
        plunge     = zeros(lstr,1);

        % chord vector calculation
        i = 1:lstr;
        pti              = TRACE(n).Segment(s).index(i);                    % indexes of initial anchor point on TRACE segment
        ptf              = TRACE(n).Segment(s).index(i+DELTA);              % indexes of point of 'DELTA pixels' further on TRACE segment
        chords(i,1)      = mX(indtr(pti))  - mX(indtr(ptf));
        chords(i,2)      = mY(indtr(pti))  - mY(indtr(ptf));
        chords(i,3)      = Z(indtr(pti))   - Z(indtr(ptf));
        
        % converting chord vector from cartesian (x,y,z) to angles (plunge and
        % trend)
        for j = 1:lstr
            [trend(j),plunge(j)]    = vect2angle([chords(j,1),chords(j,2),chords(j,3)]);       
            Chords(j).vector        = chords(j,:);
            Chords(j).axtr          = trend(j);
            Chords(j).axpl          = plunge(j);
        end        

        % storing the chord structure as a sub-structure of the
        % TRACE.Segment structure  
        
        TRACE(n).Segment(s).Chords  = Chords;
        
    end
end


% Reverse trace
for n = 1:length(TRACE)   
    for s = 1:length(TRACE(n).Segment)
        
        % scalar definitions
        l       = length(TRACE(n).Segment(s).index);    % indexes of segments
        indtr   = flipud(TRACE(n).index);               % !!! inversion of indexes of trace
        DELTA   = TRACE(n).Segment(s).delta;
        
        if mod(l,2) % 
            lstr    = DELTA+1;
        else
            lstr    = DELTA;
        end

        % allocations
        chords      = zeros(lstr,3);
        ChordsR     = struct('vector',cell(1)); % creating a String structure
        trend       = zeros(lstr,1);
        plunge      = zeros(lstr,1);

        % string vector calculation
        i = 1:lstr;
        pti              = TRACE(n).Segment(s).indexR(i);                    % indexes of initial anchor point on TRACE segment
        ptf              = TRACE(n).Segment(s).indexR(i+DELTA);              % indexes of point of 'DELTA pixels' further on TRACE segment
        chords(i,1)      = mX(indtr(pti))  - mX(indtr(ptf));
        chords(i,2)      = mY(indtr(pti))  - mY(indtr(ptf));
        chords(i,3)      = Z(indtr(pti))   - Z(indtr(ptf));
        
        % converting chord vector from cartesian (x,y,z) to angles (plunge and
        % trend)
        for j = 1:lstr
            [trend(j),plunge(j)]  = vect2angle([chords(j,1),chords(j,2),chords(j,3)]);       
            ChordsR(j).vector   = chords(j,:);
            ChordsR(j).axtr     = trend(j);
            ChordsR(j).axpl     = plunge(j);
        end        
                
        % storing the string structure as a sub-structure of the TRACE
        % structure
        TRACE(n).Segment(s).ChordsR = ChordsR;
    end
end

