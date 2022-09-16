

function visBetaStereo(TRACE,n,s)

% VISUALIZE CHORD PLANES
% visualise stereographic projection of chord planes -> great circles and
% plane poles

% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.ChdPlane  = structure of Chord plane information
                            %   -> ChdPlane.plane_orient = [dip direction, dip] of each chord plane
                            %   -> ChdPlane.pole_orient  = [trend, plunge] of each pole of chord plane
                           
% n, s      -> n - trace number (within TRACE structure) and s - segment
             % number within a trace
% ----------             
% OUTPUT    -> figure


%%

ChdPl   = TRACE(n).Segment(s).ChdPlane;
N       = length(ChdPl);

stereoPlot('no')
hold on

cmap    = flipud(autumn(N));

for i = 1:N

    azim    = ChdPl(i).plane_orient(1);
    dip     = ChdPl(i).plane_orient(2);
    [x,y]   = greatCircle(azim,dip);
    
    % draw great circles
    p       = plot(x,y);
            set(p,'Color',cmap(i,:));
            hold on
            
    % draw pole points
    [x_stereo,y_stereo] = stereoLine(ChdPl(i).pole_orient(1),ChdPl(i).pole_orient(2));
    scatter(x_stereo,y_stereo, 50, cmap(i,:), 'filled');
    
end
hold off

