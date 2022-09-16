
function TRACE = tie(TRACE,X,Y,Z,seg)

% TRACE INFORMATION EXTRACTION (TIE)
% Perform TIE on a trace set, and extract chords, chord planes, alpha, beta
% and the orthogonal distance
%
% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
%              could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.matrix   = matrix size of BED or TEC
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)
% seg       -> stands for segmentation. If traces should be segmented
%              before the TIE, seg = 'yes', otherwise seg = 'no';
%             
% ----------           
% OUTPUT
% TRACE     -> structure containing TRACE information (as input) with added fields:
%               -> TRACE.length   = index array of length (in m) between
%                                   two individual points. Sum of the
%                                   array corresponds to the trace length
%               -> TRACE.Segment  = structure of trace segments. Fields
%                                   of structure: 
%                       Segment.index     = indexes of Trace.index. If only
%                                           one segment exists, Segment.index =
%                                           1:length(TRACE.index)
%
%                       Segment.indexR    = indexes of Trace.index by
%                                           starting the analysis at the other end of the
%                                           trace
%
%                       Segment.delta     = delta (D) value used for the analysis
%
%                       Segment.Chords    = sturcture of connecting chord information
%                           -> Chords.vector        = vector (x,y,z) of each
%                                                     individual chord
%                           -> Chords.axtr          = trend of conncecting chord (plunge azimuth)
%                           -> Chords.axpl          = plunge of connecting chord
%                           -> Chords.alpha         = alpha for each connecting chord
%
%                       Segment.ChordsR   = sturcture of connecting chord information
%                                           based on reverse orientation analysis
%                                           same structure as Segment.Chords
%
%                       Segment.ChdPlane  = structure of Chord plane information
%                           -> ChdPlane.normal       = vector (x,y,z) of each
%                                                      normal to chord planes
%                           -> ChdPlane.plane_orient = [dip direction, dip] of each chord plane
%                           -> ChdPlane.pole_orient  = [trend, plunge] of each pole of chord plane
%                           -> ChdPlane.beta         = beta through each chord plane
%                           -> ChdPlane.dist         = orthogonal distance between
%                                                      chords that form a chord plane normalized
%                                                      to the total length of the trace
%
%                       Segment.ChdPlaneR     = structure of Chord plane information 
%                                               based on reverse orientation analysis
%                                               same structure as Segment.ChdPlane
%                       Segment.signalheight  = [signalheight alpha, signalheight beta]                    
%                       Segment.classID       = ID of classification zone.
%                       Segment.classcode     = colorcode[r,g,b] according to % classID
%
%               -> TRACE.orientbar  = orientation bars for each point on TRACE
%                                     based on the chord planes
           

%%        
           
[mX,mY] = meshgrid(X,Y);
TRACE   = lengthTRACE(TRACE,mX,mY,Z);

if strcmp(seg,'no')
    % make segmentation structure (with only one segment)
    for t = 1:length(TRACE)
        l           = length(TRACE(t).index);
        Segment     = struct('index',1:l,'indexR',1:l);
        TRACE(t).Segment = Segment;
    end
else
    % segmentation according to convexities
    TRACE   = segmentTRACE(TRACE,mX,mY,Z,[100,15]);
end

TRACE   = extractChords(TRACE,mX,mY,Z);
TRACE   = extractAlpha(TRACE);
TRACE   = extractChdPlanes(TRACE,mX,mY,Z);
TRACE   = extractBeta(TRACE);
TRACE   = classifyTRACE(TRACE, [3,9,18]);
TRACE   = extractOrientBars(TRACE);


end
