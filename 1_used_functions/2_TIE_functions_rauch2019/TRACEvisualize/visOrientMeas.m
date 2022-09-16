
function visOrientMeas(ORcoor, ORattr, azim_field, dip_field, X, Y, Z)

% VISUALIZE ORIENTATION MEASUREMENTS
% visualise all orientation measurements with its orientation on the
% map in 3d

% ----------
% INPUT
% shapefile     -> Name of shapefile containing orientation measurements.(point data)
% azim_field    -> attribute field in shapefile that contains the dip azimuth/direction information
% dip_field     -> attribute field in shapefile that contains the dip information
% X, Y, Z       -> Coordinate vectors (see loadCoord.mat)

% ----------
% OUTPUT
% ORcoor        -> Structure from shapefile with the coordinates of orientation measurements
% ORattr        -> Structure from shapefile with the attributes of orientation measurements


%%

for m = 1:length(ORattr)
    
    azim        = ORattr(m).(azim_field);
    dip         = ORattr(m).(dip_field) ;  
    if ~isnumeric(azim)
        azim    = str2double(azim);
        dip     = str2double(dip);
    end        
    
    % defining strike (both possibilites)
    if azim > 90 
        strike      = azim - 90;
    else
        strike      = azim + 90;
    end
    
    % extracting x-y coordinates for the sign orientation
    [xd,yd]     = stereoLine(azim,0);       % small line (dip direction)
    [xs1,ys1]   = stereoLine(strike,0);     % half of strike line
    xs2         = xs1*-1;                   % other half of strike line (in the other direction)
    ys2         = ys1*-1;  

    x = ORcoor(m).X;
    y = ORcoor(m).Y;   
        
    % figure parametres
    amp1    = (length(X)+length(Y))/(2*25); % sign size - how much to amplify vector (small dip vector)
    amp2    = (length(X)+length(Y))/25;     % sign size - how much to amplify vector (large strike vector)
    maxz    = max(max(Z));                  % maximum Z value (set signs at the highest point so that no sign intersects with the topography)
    lwdt    = 3;                            % Line Width

    % plots
    pd  = plot3([x, x + xd*amp1],[y, y + yd*amp1], [maxz, maxz]); hold on
        set(pd,'LineWidth', lwdt)
        pd.Color    = [0,0,0,1];
    ps1 = plot3([x, x+ xs1*amp2],[y, y + ys1*amp2],[maxz, maxz]); hold on
        set(ps1,'LineWidth', lwdt)
        ps1.Color    = [0,0,0,1];
    ps2 = plot3([x, x+ xs2*amp2],[y, y + ys2*amp2],[maxz, maxz]); hold on
        set(ps2,'LineWidth', lwdt)
        ps2.Color    = [0,0,0,1];
    text(double(x - xd*amp1), double(y - yd*amp1), double(maxz+10), num2str(dip),'FontSize', 18);
    hold on
end