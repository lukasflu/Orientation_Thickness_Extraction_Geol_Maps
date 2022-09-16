
function visOrientBar(TRACE,type,X,Y,Z)

% VISUALIZE ORIENTATION BARS
% Vizualize orientation bars on a trace set in 3d or in stereo (-> type)

% ----------
% INPUT
% TRACE     -> structure containing basic TRACE information (any TRACE set, -
             % could also be FAULTS). Fields needed:
                    % -> TRACE.index        = ordered index array of trace 
                    %                         points within the matrix. 
                    % -> TRACE.orientbar    = orientation bars for each point on TRACE
                    %                         based on the chord planes
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)
% type      -> defines the way the bars should be illustrated. If type =
%              'stereo', the bars are shown in 2d with the length of a stereographic
%              projection

% ----------            
% OUTPUT    -> figure


%%

for t = 1:length(TRACE)   
    index       = TRACE(t).index;
    or_bar      = TRACE(t).orientbar;
    [mX,mY]     = meshgrid(X,Y);
    cs          = X(2)-X(1);
    barlength   = length(X)*cs/20;
    
    
    for m = 1:10:length(or_bar(:,1))
        [tr,pl] = vect2angle(or_bar(m,:));
        [x1,y1] = stereoLine(tr,pl);

        if strcmp(type, 'stereo')
            p  = plot3( [mX(index(m)),  mX(index(m)) + x1*barlength],...
                        [mY(index(m)),  mY(index(m)) + y1*barlength],...
                        [Z(index(m)),   Z(index(m))]                            ); hold on
            set(p,'LineWidth', 2.5)
            p.Color    = [0,0,0,0.9];
            hold on
        else
            p  = plot3( [mX(index(m)),  mX(index(m)) + or_bar(m,1)*barlength],...
                        [mY(index(m)),  mY(index(m)) + or_bar(m,2)*barlength],...
                        [Z(index(m)),   Z(index(m))  + or_bar(m,3)*barlength]    ); hold on
            set(p,'LineWidth', 2.5)
            p.Color    = [0,0,0,0.9];
            hold on
        end
    end   
end