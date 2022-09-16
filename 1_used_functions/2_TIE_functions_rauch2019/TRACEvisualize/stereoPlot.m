
function stereoPlot(WithCircles)

% STEREONET
% Basis for the visualisation of a stereonet
% based on: Middleton, G.V.(2000). Data analysis in the earth sciences using Matlab®. 
%           Upper Saddle River, NJ: Prentice Hall. 
% ----------
% INPUT
% WithCircles -> if great and small circles should be visualised:
%                WithCirles = 'yes', else 'no';
% ----------
% OUTPUT
% --> streonet figure


%%
N   = 50;
cx  = cos(0: pi/N: 2*pi);
cy  = sin(0: pi/N: 2*pi);
xh  = [-1 1]; 
yh  = [ 0 0];
xv  = [ 0 0]; 
yv  = [-1 1];

axis([-1 1 -1 1]);
axis square

plot(xh,yh,'-k',xv,yv,'k'); 
hold on;
plot(cx,cy,'k'); 

if strcmp(WithCircles,'yes')
    psi = 0:pi/N:pi;
    for i = 1:8 % plot great circles
        rdip    = i*(pi/18); 
        radip   = atan(tan(rdip)*sin(psi));
        rproj   = tan((pi/2-radip)/2);
        x1      = rproj.*sin(psi);
        x2      = rproj.*(-sin(psi));
        y       = rproj.*cos(psi);

        plot(x1,y,':k',x2,y,':k');
    end

    for i = 1:8 % plot small circles
        alpha   = i*(pi/18);
        xlim    = sin(alpha);
        x       = -xlim: 0.01: xlim;
        d       = 1/cos(alpha);
        rd      = d * sin(alpha);
        y0      = sqrt(rd*rd-(x.*x));
        y1      = d  - y0;
        y2      = -d + y0;
        plot(x,y1,':k',x,y2,':k');
    end
end

axis square
hold on



    
