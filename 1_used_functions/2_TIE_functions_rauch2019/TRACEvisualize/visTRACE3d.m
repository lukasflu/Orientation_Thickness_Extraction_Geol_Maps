
function visTRACE3d(TRACE,X,Y,Z,sett)

% VISUALIZE TRACES
% visualise traces in 3D

% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.index    = ordered index array of trace 
                    %                     points within the matrix.
                    % -> TRACE.Segment  = structure of trace segments.  
                            % Segment.index     = indexes of Trace.index. If only
                            %                     one segment exists, Segment.index =
                            %                     1:length(TRACE.index)

% n         -> n - trace number (within TRACE structure) 
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)                  
% sett      -> setting of lines: [colour ([r g b]),linesize,textsize];  
% ----------
% OUTPUT --> figure


%%

[mX, mY] = meshgrid(X,Y);
offset   = abs(X(2)-X(1))*3;

for i = 1:length(TRACE)
    fig = plot3(mX(TRACE(i).index),mY(TRACE(i).index),Z(TRACE(i).index));
          set(fig, 'Color', sett(1:3), 'LineWidth', sett(4))
    if sett(5) > 0 
          text(double(mX(TRACE(i).index(1))+offset),double(mY(TRACE(i).index(1)))+offset,double(Z(TRACE(i).index(1)))+offset,...
          num2str(i),'Color',[0.9 0.9 0.9],'FontSize', sett(5));
    end
    hold on
end
view(2)

