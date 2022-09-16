
function fig = visSigStereo(TRACE,n,nfig)

% VISUALIZE STEREO DATA
% visualise stereographic projection of connecting chords and chord plane
% poles

% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.Chords    = sturcture of connecting chord information
                            %   -> Chords.axtr  = trend of conncecting chord (plunge azimuth)
                            %   -> Chords.axpl  = plunge of connecting chord
                            % Segment.ChdPlane  = structure of Chord plane information
                            %   -> ChdPlane.plane_orient = [dip direction, dip] of each chord plane
                            %   -> ChdPlane.pole_orient  = [trend, plunge] of each pole of chord plane
                           
% n         -> n - trace number (within TRACE structure)
% nfig      -> number of figure

% ----------         
% OUTPUT 
% fig       -> figure handle


%%

fig = figure(nfig);

ls = length(TRACE(n).Segment);
m  = 1;
for s = 1:length(TRACE(n).Segment)
    subplot(ls,2,m)
    visAlphaStereo(TRACE,n,s);
    xlabel(['Trace',' ',num2str(n),' ','/',' ','Segment',' ',num2str(s)])
    title('Orientation of connecting cords')
    hold off
    m = m + 1;
    
    subplot(ls,2,m)
    visBetaStereo(TRACE,n,s) 
    xlabel(['Trace',' ',num2str(n),' ','/',' ','Segment',' ',num2str(s)])
    title('Poles and great circles of chord planes')
    hold off
    m = m + 1;
end


