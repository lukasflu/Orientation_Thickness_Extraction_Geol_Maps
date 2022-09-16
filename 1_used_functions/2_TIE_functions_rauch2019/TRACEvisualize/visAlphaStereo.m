
function visAlphaStereo(TRACE,n,s)


% VISUALIZE CONNECTING CHORDS
% visualise stereographic projection of connecting chords 

% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.Chords    = sturcture of connecting chord information
                            %   -> Chords.axtr  = trend of conncecting chord (plunge azimuth)
                            %   -> Chords.axpl  = plunge of connecting chord
% n, s      -> n - trace number (within TRACE structure) and s - segment
             % number within a trace
 % ----------            
% OUTPUT    -> figure


%%

stereoPlot('no')

Chords  = TRACE(n).Segment(s).Chords;
l       = length(Chords);  
axChd   = [Chords.axtr];
axPl    = [Chords.axpl];

[x_Ax, y_Ax] = stereoLine(axChd,axPl);
hold on

if rem(l,2)== 0
    half        = l/2;
    halfpoint   = half;
else
    half        = (l-1)/2;
    halfpoint   = half+1;
end
cmaplin = flipud(autumn(halfpoint));

for i = 1:halfpoint
    scatter(x_Ax(i),y_Ax(i),50,cmaplin(i,:),'filled')
    hold on
    scatter(x_Ax(i+half),y_Ax(i+half),50,cmaplin(i,:),'filled')
    hold on
end 
    
hold off

