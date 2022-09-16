% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) ----------
% | ---------------- Version: Lukas Nibourel, 07-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ---- FIGURE 3: FILTERED MODEL OUTPUT (ALL NON EDITABLE FEATURES)  -----
% | -------------- FIGURES 3 AND 4 ARE THOUGHT TO BE USED COMBINED --------
% | -----------------------------------------------------------------------

% PATH TO THE IMPUT FILES -------------------------------------------------
load([savePath 'workspace_thickness_extraction_filtered.mat']);

% |------------------------------------------------------------------------
% |--------------------------%  START PLOTTING %---------------------------
% |------------------------------------------------------------------------

% FIGURE 3, PLOT CONTAINING NON-EDITABLE ALL BACKGROUND MAP LAYERS --------
% -------------------------------------------------------------------------

f=figure(3);clf;

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
    % replace all target unit values with a '2'
    % leave the other matrix entries as they are
    bed_pol(bed_poly_mat==target_units(r)) = 2;
end

% select polygons other bedrock units
bed_poly_layer_fields           = find(bed_pol==2);
bed_poly_all_other_units_fields = setdiff(( ...
    1:numel(bed_poly)), ...
    bed_poly_layer_fields);
% n_base2                         = setdiff((1:n_base),indices);

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


% PLOT SETTINGS: MAP EXTENT, LEGEND, COLORBAR------------------------------
% limit to map extent
xlim([limits(1,1) limits(1,2)]);
ylim([limits(2,1) limits(2,2)]);
f.Position = image_pos_size;


hold off;

% % use export_fig function to preserve editability in illustrator
% imageSavePath = strcat(savePath,'Fig3');
% export_fig(imageSavePath, '-png');

% | ------------------------ % END FIGURE 3 %------------------------------