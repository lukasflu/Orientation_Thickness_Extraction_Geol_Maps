
function visSHdiagram(pth) 

% VISUALIZE SIGNAL HEIGHT DIAGRAM
% visualise basis of signal height diagram with a specific threshold
% indexes

% ----------
% INPUT
% r         -> vector/array of threshold indexes
% ----------
% OUTPUT   --> figure


%%

x1  = [ 0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
x2  = [1.2,1.2,1.5,1.8, 2,2.5 3,3.8,5, 6, 8, 10,15, 20, 30, 40, 50, 60, 70, 90, 180];

x0  = [x1,x2];
y0  = 180./ x0;
p0  = plot(x0,y0,':k'); hold on    
      set(p0,'LineWidth',1)
s0  = plot([0,180],[0,180],'--k'); hold on
      set(s0,'LineWidth',1)
      
for j = 1:length(pth)
    
    x   = x0 +pth(j);
    y   = 180./ (x-pth(j)) + pth(j);
    
    p   = plot(x,y,'k');
          set(p,'LineWidth',1)
          hold on
end

axis equal
axis([0 180 0 180])

