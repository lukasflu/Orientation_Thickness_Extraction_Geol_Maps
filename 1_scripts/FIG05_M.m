% | -----------------------------------------------------------------------
% |
% | --- PLOT RELIABILITY INDICATOR M (DEGREE OF FIT OF ORIENTATION INFO) --
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 08-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ----------------------- FIGURE 5: PLOT M VALUES -----------------------
% | -----------------------------------------------------------------------

%% LOAD WORKSPACE ---------------------------------------------------------

load([savePath 'workspace_thickness_extraction_filtered.mat']);

%% Figure 5, plot filtering parameter M -----------------------------------
f=figure(5);clf;

% define symbol size, style and font in plots
symbol_size         = 100;                   % symbol size
symbol_line_size    = 1.5;                   % symbol line size
font_size           = 8;

% define bounding box to make sure shaperead loads relevant data only
% [xmin xmax; ymin ymax]
bbox = [limits(1,1) limits(2,1); limits(1,2) limits(2,2)];

% define image position and size
image_pos_size = [100 100 1800 900];

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
tect_line_cell      = {tect_line(:).SYMBOL_D};
tect_line_mat       = cellfun(@str2num,tect_line_cell(1:end)).';
tect_lin_fault      = tect_line_mat == 11;
tect_lin_thrust     = tect_line_mat == 25;
tect_line_faults    = find(tect_lin_fault);
tect_line_thrusts   = find(tect_lin_thrust);

% plot tectonic features
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

% PLOT M VALUES -----------------------------------------------------------

% select values which do or do not fullfill the filter criteria:
% select reliable M-values
ind_M_reliable  = find(M_mat(:,1) >= M_value_threshold);
% select not reliable K-values
ind_M_unreliable  = find(M_mat(:,1) < M_value_threshold);

% create matrix including all XYZ_coordinates
XYZ_Coo = cell2mat(transpose(xyzOrientationData));

% PLOT UNRELIABLE M VALUES FIRST
% for loop plots only every 10th point to enhance visibility
for m = 1:10:length(ind_M_unreliable)
    scatter(...
        XYZ_Coo(ind_M_unreliable(m),1),...
        XYZ_Coo(ind_M_unreliable(m),2),...
        symbol_size*0.4,M_mat(ind_M_unreliable(m)),...
        'o','LineWidth',0.5);
    hold on;
end

% PLOT RELIABLE M VALUES
for m = 1:10:length(ind_M_reliable)
    scatter(...
        XYZ_Coo(ind_M_reliable(m),1),...
        XYZ_Coo(ind_M_reliable(m),2),...
        symbol_size*0.4,M_mat(ind_M_reliable(m)),...
        'o','filled','LineWidth',0.5);
    hold on;
end

hold off;

% PLOT SETTINGS: MAP EXTENT, LEGEND, COLORBAR-----------------------------
% limit to map extent
xlim([limits(1,1) limits(1,2)]);
ylim([limits(2,1) limits(2,2)]);
f.Position = image_pos_size;
% color axis for M-values, the larger the better the fit
c = colorbar; set( c, 'YDir'); caxis([2 8])                                
% invert colormap so that blue always represents the most favourable values
colormap(flipud(parula));
c.Label.String = 'M-value (Fernandez, 2005)';

% | ------------------------ % END FIGURE 5 %------------------------------