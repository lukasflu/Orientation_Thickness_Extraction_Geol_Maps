
function visBarLegend(type,X,Y,Z)

% VISUALIZE BAR LEGEND
% Vizualize the legend of the orientation bars, that is to say: the length 
% with the associated dip in the upper left corner of the map

% ----------
% INPUT
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)
% type      -> defines the way the bars should be illustrated. If type =
%              'stereo', the bars are shown in 2d with the length of a stereographic
%              projection

% ----------            
% OUTPUT    -> added plot on map


%%

trleg       = ones(1,10)*180;
plleg       = 0:10:90;
[vx,vy,vz]  = angle2vect(trleg,plleg);
cs          = (X(2)-X(1));
barlength   = length(X)*cs/20;

for m = 1:10
    s = m-1;
    if strcmp(type,'stereo')
        [x1,y1]     = stereoLine(trleg,plleg);
        xleg = [X(10+s*12),  X(10+s*12)  + x1(m)*barlength];
        yleg = [Y(10),       Y(10)       + y1(m)*barlength];
        zleg = [max(max(Z)), max(max(Z))                  ];

    else
        xleg = [X(10+s*12),  X(10+s*12)  + vx(m)*barlength];
        yleg = [Y(10),       Y(10)       + vy(m)*barlength];
        zleg = [max(max(Z)), max(max(Z)) + vz(m)*barlength];
    end
    plot3(xleg, yleg, zleg,'k','lineWidth',2);
    if m~=10
        hold on
        text(double(xleg(2)), double(yleg(2)-10*cs), double(zleg(1)),strcat(num2str(s*10),'°'));
    end
    hold on
end
