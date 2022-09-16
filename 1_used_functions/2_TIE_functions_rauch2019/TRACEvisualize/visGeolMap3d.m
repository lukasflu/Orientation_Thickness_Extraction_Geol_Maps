
function visGeolMap3d(X,Y,Z,BED,tran)

% VISUALIZE GEOLOGICAL MAP
% Visualize geological map in 3d

% ----------
% INPUT
% X, Y, Z   -> Coordinate vectors (see loadCoord.mat)
% BED       -> matrix with Bedrock data (see loadBedrock and rasterizeBedrock)
% tran      -> transparency of map (between 0 and 1)

% ----------
% OUTPUT    -> figure


%%

cnX     = length(BED(:,1));
cnY     = length(BED(1,:));

rock = unique(BED(BED>0));
if ~isnumeric(rock)
    rock = str2double(rock);
end

% create matrix with equal bedrock distinction 
bed = zeros(cnX,cnY);
for r = 1:length(rock)
    bed(BED==rock(r)) = r;
end

% colormap for bedrock visualisation
grey        = [0.9 0.9 0.9];
rock_color  = summer(length(rock));
cmap_rocks  = [grey;rock_color];

topo = surf(X,Y,Z,flipud(bed));

        alpha(topo,tran)
        colormap(cmap_rocks)
        shading flat
        axis equal
        camlight(100,50)
        lighting gouraud
        view(2)

hold on