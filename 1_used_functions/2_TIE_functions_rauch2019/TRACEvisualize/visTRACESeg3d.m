
function visTRACESeg3d(TRACE,n,s,X,Y,Z,sett)

% VISUALIZE SEGMENTS
% visualise segments of traces in 3D

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

% n, s      -> n - trace number (within TRACE structure) and s - segment
             % number within a trace
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)                  
% sett      -> setting of lines: [colour ([r g b]),linesize,textsize]; 

% ----------
% OUTPUT --> figure


%%

[mX,mY] = meshgrid(X,Y);

seg     = TRACE(n).Segment(s).index;
ls      = length(seg);
fig     = plot3(mX(TRACE(n).index(seg)),mY(TRACE(n).index(seg)),Z(TRACE(n).index(seg)));
            set(fig, 'Color', sett(1:3), 'LineWidth', sett(4))
hold on
          scatter3( mX(TRACE(n).index(seg([1,ls]))),...
                    mY(TRACE(n).index(seg([1,ls]))),...
                     Z(TRACE(n).index(seg([1,ls]))),...
                    50, 'k', 'filled' );
      
if sett(5) > 0 
      text(double(mX(TRACE(n).index((seg(1)))))+5,double(mY(TRACE(n).index(seg(1))))+20,double(Z(TRACE(n).index(seg(1))))+20,...
      num2str(n),'Color',sett(1:3),'FontSize', sett(5));
end
hold on

view(2)
axis equal
