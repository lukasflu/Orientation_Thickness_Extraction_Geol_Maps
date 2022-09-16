% | -----------------------------------------------------------------------
% |
% | --------------- PLOT RELIABILITY INDICATOR DISTANCE P-Q ---------------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 08-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ----------------------- FIGURE 9: PLOT DISTANCE P-Q -------------------
% | -----------------------------------------------------------------------

%% LOAD WORKSPACE ---------------------------------------------------------

load([savePath 'workspace_thickness_extraction_filtered.mat']);

%% Figure 9, plot filtering parameter alpha--------------------------------

f=figure(9);clf;

% define symbol size, style and font in plots
symbol_size         = 100;                   % symbol size
symbol_line_size    = 1.5;                   % symbol line size
font_size           = 8;

% define bounding box to make sure shaperead loads relevant data only
% [xmin xmax; ymin ymax]
bbox = [limits(1,1) limits(2,1); limits(1,2) limits(2,2)];

% define image position and size
image_pos_size = [100 100 1800 900];

% create two subsets with distP-Q values classified reliable / unreliable
% select reliable data
ind_distPQ_reliable = find(...
    outputtable4filtering(:,9)   <  max_distance_threshold         & ...
    outputtable4filtering(:,13)   == 2);
% select unreliable data
ind_distPQ_unreliable = find(...
    outputtable4filtering(:,9)   >=  max_distance_threshold         & ...
    outputtable4filtering(:,13)   == 2);

% SELECT AND PLOT BACKGROUND MAP AND UNITS --------------------------------
% select polygons target unit
bed_poly        = shaperead(bedshape,'BoundingBox',bbox);
bed_poly_cell   = {bed_poly(:).SYMBOL_D};
bed_poly_mat    = cellfun(@str2num,bed_poly_cell(1:end)).';
bed_pol         = bed_poly_mat;

% loop through the vector target_units
for r = 1:length(target_units)
    % replace all target unit values with a '2',
    % leave the other matrix entries as they are
    bed_pol(bed_poly_mat==target_units(r)) = 2;
end

% select polygons other bedrock units
bed_poly_layer_fields           = find(bed_pol==2);
bed_poly_all_other_units_fields = setdiff(( ...
    1:numel(bed_poly)),bed_poly_layer_fields);
%n_base2                         = setdiff((1:n_base),indices);

% plot hillshade and bedrock units
mapshow(hillshade,'AlphaData',0.3); hold on;
mapshow(bed_poly(bed_poly_all_other_units_fields), ...
    'FaceColor', 'black', ...
    'FaceAlpha',0.15, ...
    'EdgeColor', 'black', ...
    'LineWidth', 0.5);
mapshow(bed_poly(bed_poly_layer_fields), ...
    'FaceColor', 'black', ...
    'FaceAlpha', 0.4, ...
    'EdgeColor', 'black', ...
    'LineWidth', 0.5);

% select tectonic features
tect_line           = shaperead(tecshape,'BoundingBox',bbox);
tect_line_cell = {tect_line(:).SYMBOL_D};
tect_line_mat = cellfun(@str2num,tect_line_cell(1:end)).';
tect_lin_fault = tect_line_mat == 11;
tect_lin_thrust = tect_line_mat == 25;
tect_line_faults = find(tect_lin_fault);
tect_line_thrusts = find(tect_lin_thrust);
mapshow(tect_line(tect_line_faults), 'Color','red','LineWidth',1);
mapshow(tect_line(tect_line_thrusts), 'Color','blue','LineWidth',1);

% plot orientation information for base -----------------------------------
for i = base_trace_fields
    index       = xyzOrientationData{1,i}(:,:);
    or_bar      = Dir{1,i}(:,:);
%    [mX,mY]     = meshgrid(X,Y);
    cs          = X(2)-X(1);
    barlength   = length(X)*cs/50;
    for m = 1:10:length(or_bar(:,1))
        [tr,pl] = vect2angle(or_bar(m,:));
        [x1,y1] = stereoLine(tr,pl);

    p  = plot( [index(m,1),  index(m,1) - x1*barlength],...
               [index(m,2),  index(m,2) - y1*barlength]); hold on
    set(p,'LineWidth', 1.5)               % LN: 2019-11-12 from 2.5 to 1
    p.Color    = [0,0,0,0.9];
    hold on
    end
end

% plot orientation information for top ------------------------------------
for i = top_trace_fields
    index       = xyzOrientationData{1,i}(:,:);
    or_bar      = Dir{1,i}(:,:);
%    [mX,mY]     = meshgrid(X,Y);
    cs          = X(2)-X(1);
    barlength   = length(X)*cs/50;
    for m = 1:10:length(or_bar(:,1))
        [tr,pl] = vect2angle(or_bar(m,:));
        [x1,y1] = stereoLine(tr,pl);

    p  = plot( [index(m,1),  index(m,1) - x1*barlength],...
               [index(m,2),  index(m,2) - y1*barlength]); hold on
    set(p,'LineWidth', 1.5)               % LN: 2019-11-12 from 2.5 to 1
    p.Color    = [0,0.4,0.4,1];
    hold on
    end
end

% PLOT UNRELIABLE distPQ VALUES FIRST -------------------------------------
% for loop plots only every 10th point to enhance visibility
for m = 1:10:length(ind_distPQ_unreliable)
    scatter(...
        outputtable_thickness(ind_distPQ_unreliable(m),1),...
        outputtable_thickness(ind_distPQ_unreliable(m),2),...
        symbol_size*0.4,outputtable_thickness(ind_distPQ_unreliable(m),9),...
        'o','LineWidth',0.5);
    hold on;
end

% PLOT RELIABLE distPQ VALUES ---------------------------------------------
% for loop plots only every 10th point to enhance visibility
for m = 1:10:length(ind_distPQ_reliable)
    scatter(...
        outputtable_thickness(ind_distPQ_reliable(m),1),...
        outputtable_thickness(ind_distPQ_reliable(m),2),...
        symbol_size*0.4,outputtable_thickness(ind_distPQ_reliable(m),9),...
        'o','filled','LineWidth',0.5);
    hold on;
end

hold off;

% set(gca,'CLim',[min(thickness_mean) max(thickness_mean)]);
axis equal;
xlim([min(X) max(X)]);
ylim([min(Y) max(Y)]);
f.Position = image_pos_size;
c = colorbar; set( c, 'YDir'); caxis([0 800]);
colormap(parula);
c.Label.String = 'Distance between nearest neighbors [m]';

% | ------------------------ % END FIGURE 9 %------------------------------