
function TRACE = extractChdPlanes(TRACE,mX,mY,Z)

% CHORD PLANES
% Extraction of chord planes based on connecting chords
%
% ----------
% INPUT
% TRACE   -> structure containing basic TRACE information (any TRACE set, -
%            could also be FAULTS). Fields needed:
%               -> TRACE.index    = ordered index array of trace 
%                                   points within the matrix. 
%               -> TRACE.length   = index array of length (in m) between
%                                   two individual points. Sum of the
%                                   array corresponds to the trace length
%               -> TRACE.Segment  = structure of trace segments. Fields
%                                   of structure: 
%                   Segment.index     = indexes of Trace.index. If only
%                                       one segment exists, Segment.index =
%                                       1:length(TRACE.index)
%
%                   Segment.indexR    = indexes of Trace.index by
%                                       starting the analysis at the other end of the
%                                       trace
%
%                   Segment.Chords    = sturcture of connecting chord information
%                           -> Chords.vector     = vector (x,y,z) of each
%                                                  individual chord
%
%                   Segment.ChordsR   = sturcture of connecting chord information
%                                       based on reverse orientation analysis
%                           -> Chords.vector     = vector (x,y,z) of each
%                                                  individual chord                                         
% mX, mY, Z -> Coordinate matrixes of X, Y an Z (see loadCoord.mat). mX
%              and mY are just the meshgrided version of X and Y
%
% ----------            
% OUTPUT
% TRACE  -> structure containing TRACE information (as input) with added fields:           
%                   Segment.ChdPlane  = structure of Chord plane information
%                           -> ChdPlane.normal       = vector (x,y,z) of each
%                                                      normal to chord planes
%                           -> ChdPlane.plane_orient = [dip direction, dip] of each chord plane
%                           -> ChdPlane.pole_orient  = [trend, plunge] of each pole of chord plane
%                           -> ChdPlane.dist         = orthogonal distance between
%                                                      chords that form a chord plane normalized
%                                                      to the total length of the trace
%
%                   Segment.ChdPlaneR = structure of Chord plane information 
%                                       based on reverse orientation analysis
%                                       same structure as Segment.ChdPlane
   
                    
%%

% Normal signal
for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    
    for s = 1:length(Segment)
        
        % definitions & allocations
        Chords      = Segment(s).Chords;
        N           = length(Chords);
        indexseg    = TRACE(n).index(Segment(s).index);
        
        if rem(N,2) == 0 % length of string plane vector depends whether the string length is even or un even   
            step        = N/2; % like delta, but for string planes
            steppoint   = step;
        else
            step        = (N-1)/2;
            steppoint   = step+1;
        end

        ChdPlane = struct('normal',[],'plane_orient',[],'pole_orient',[],'beta',[],'dist',[],'trace',[]);
        
        % calculation of chord planes
        for i = 1:steppoint
            v1          = Chords(i).vector;
            v2          = Chords(i+step).vector;
           
            normal      = cross(v1,v2);
            [azim,dip]  = normal2angle(normal); 

            polepl      = 90 - dip; 
            poletr      = azim-180;    
            if poletr < 0
                poletr  = 360 + poletr;
            end           
                       
            % orthogonal distance between the two chords forming a chord plane
            P1          = [mX(indexseg(i)),     mY(indexseg(i)),        Z(indexseg(i))      ];
            P2          = [mX(indexseg(i+step)),mY(indexseg(i+step)),   Z(indexseg(i+step)) ];
            P1P2        = P2 - P1;
            dist        = abs(dot(cross(v1,v2),P1P2))/norm(cross(v1,v2));
            tracelength = sum(TRACE(n).length);
            distratio   = dist/tracelength;
            
            % storing the information in the structure
            ChdPlane(i).normal          = normal;
            ChdPlane(i).plane_orient    = [azim, dip];
            ChdPlane(i).pole_orient     = [poletr, polepl];
            ChdPlane(i).dist            = distratio;

        end
        
        TRACE(n).Segment(s).ChdPlane    = ChdPlane;
    end
end


%%

% Reverse signal
 for n = 1:length(TRACE)
    Segment = TRACE(n).Segment;
    
    for s = 1:length(Segment)
        
        % definitions & allocations
        ChordsR     = Segment(s).ChordsR;
        N           = length(ChordsR);       
        if rem(N,2) == 0   
            step        = N/2; 
            steppoint   = step;
        else
            step        = (N-1)/2;
            steppoint   = step+1;
        end

        ChdPlaneR = struct('normal',[],'plane_orient',[],'pole_orient',[],'beta',[],'dist',[],'trace',[]);
        
        % calculation of String planes
        for i = 1:steppoint
            v1          = ChordsR(i).vector;
            v2          = ChordsR(i+step).vector;
           
            normal      = cross(v1,v2);
            [azim,dip]  = normal2angle(normal);

            polepl      = 90 - dip; 
            poletr      = azim-180;    
            if poletr < 0
                poletr  = 360 + poletr;
            end
            
                       
            % orthogonal distance between the two chords forming a chord plane
            indexR      = flipud(TRACE(n).index);            
            indexsegR   = indexR(Segment(s).indexR);
            P1          = [mX(indexsegR(i)),mY(indexsegR(i)),Z(indexsegR(i))];
            P2          = [mX(indexsegR(i+step)),mY(indexsegR(i+step)),Z(indexsegR(i+step))];
            P1P2        = P2-P1;
            dist        = abs(dot(cross(v1,v2),P1P2))/norm(cross(v1,v2));
            tracelength = sum(TRACE(n).length);
            distratio   = dist/tracelength;
            
            % storing the information in the structure
            ChdPlaneR(i).normal          = normal;
            ChdPlaneR(i).plane_orient    = [azim, dip];
            ChdPlaneR(i).pole_orient     = [poletr, polepl];
            ChdPlaneR(i).dist            = dist;
            ChdPlaneR(i).distratio       = distratio;

        end
        TRACE(n).Segment(s).ChdPlaneR = ChdPlaneR;
    end
 end

