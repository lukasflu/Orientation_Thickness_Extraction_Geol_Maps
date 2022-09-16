% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 07-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ---- FIGURE 1: MAP OVERVIEW, FILTERED OUTPUTS AND LITERATURE DATA  ----
% | -----------------------------------------------------------------------

% PATH TO THE IMPUT FILES -------------------------------------------------
load([savePath 'workspace_thickness_extraction_filtered.mat']);

%%

% |------------------------------------------------------------------------
% |--------------------------%  START PLOTTING %---------------------------
% |------------------------------------------------------------------------

% Figure 1: combined Figure without legend and a few other features -------
% -------------------------------------------------------------------------

f = figure(1);clf;

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
bed_poly_all_other_units_fields = setdiff((1:numel(bed_poly)), ...
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

% highlight base and top traces (base is black, top is dark green)
for k = base_trace_fields
    plot(SegmentsXYZ{1,k}(:,1),SegmentsXYZ{1,k}(:,2), '.', ...
        'Color', [0,0,0,0.9], 'MarkerSize',3); hold on;
end

for k = top_trace_fields
    plot(SegmentsXYZ{1,k}(:,1),SegmentsXYZ{1,k}(:,2), '.', ...
        'Color', [0,0.3,0.3,1], 'MarkerSize',3); hold on;
end

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


% PLOT ORIENTBARS AND LEGEND ---------------------------------------------

% plot orientation bars

% plot all orientation information at once
% for i = 1:numel(GeolCodes)
%     index       = xyzOrientationData{1,i}(:,:);
%     or_bar      = Dir{1,i}(:,:);
% %    [mX,mY]     = meshgrid(X,Y);
%     cs          = X(2)-X(1);
%     barlength   = length(X)*cs/50;
%     for m = 1:10:length(or_bar(:,1))
%         [tr,pl] = vect2angle(or_bar(m,:));
%         [x1,y1] = stereoLine(tr,pl);
% 
%     p  = plot( [index(m,1),  index(m,1) - x1*barlength],...
%                [index(m,2),  index(m,2) - y1*barlength]); hold on
%     set(p,'LineWidth', 1.5)               % LN: 2019-11-12 from 2.5 to 1
%     p.Color    = [0,0,0,0.9];
%     hold on
%     end
% end

% % plot orientation information for base
% for i = base_trace_fields
%     index       = xyzOrientationData{1,i}(:,:);
%     or_bar      = Dir{1,i}(:,:);
% %    [mX,mY]     = meshgrid(X,Y);
%     cs          = X(2)-X(1);
%     barlength   = length(X)*cs/50;
%     for m = 1:10:length(or_bar(:,1))
%         [tr,pl] = vect2angle(or_bar(m,:));
%         [x1,y1] = stereoLine(tr,pl);
% 
%     p  = plot( [index(m,1),  index(m,1) - x1*barlength],...
%                [index(m,2),  index(m,2) - y1*barlength]); hold on
%     set(p,'LineWidth', 1.5)               % LN: 2019-11-12 from 2.5 to 1
%     p.Color    = [0,0,0,0.9];
%     hold on
%     end
% end
% 
% % plot orientation information for top
% for i = top_trace_fields
%     index       = xyzOrientationData{1,i}(:,:);
%     or_bar      = Dir{1,i}(:,:);
% %    [mX,mY]     = meshgrid(X,Y);
%     cs          = X(2)-X(1);
%     barlength   = length(X)*cs/50;
%     for m = 1:10:length(or_bar(:,1))
%         [tr,pl] = vect2angle(or_bar(m,:));
%         [x1,y1] = stereoLine(tr,pl);
% 
%     p  = plot( [index(m,1),  index(m,1) - x1*barlength],...
%                [index(m,2),  index(m,2) - y1*barlength]); hold on
%     set(p,'LineWidth', 1.5)               % LN: 2019-11-12 from 2.5 to 1
%     p.Color    = [0,0.4,0.4,1];
%     hold on
%     end
% end


% PLOT THICKNESS DATA ----------------------------------------------------
% plot automatically extracted and reliability checked thickness data
scatter(outputtable_thickness(filter_combined,1),...
    outputtable_thickness(filter_combined,2),...
    symbol_size,outputtable_thickness(filter_combined,4),...
    'o','filled');

% uncomment if you wish to plot all values with no filtering applied
% scatter(outputtable_thickness(:,1),outputtable_thickness(:,2),...
%     symbol_size,outputmatrix(:,4),'o','filled');


% plot literature data
% white background color to enhance visibility
scatter(thickness_data_literature(filter_literature_data,1),...
    thickness_data_literature(filter_literature_data,2),...
    symbol_size*2.5,'w','d','LineWidth',6);
% plot literature date color coded
scatter(thickness_data_literature(filter_literature_data,1),...
    thickness_data_literature(filter_literature_data,2),...
    symbol_size*2.5,thickness_data_literature(filter_literature_data,4),...
    'd','LineWidth',2.5);

% % PLOT ORIENTATION MEASUREMENTS FROM GEOCOVER ---------------------------
% visOrientMeasnew(ORcoor, ORattr, fieldAzim, fieldDip, X, Y, Z)

% % PLOT TRACE NUMBERS ----------------------------------------------------
% for q = top_base_trace_fields                                                                                         % plot trace field numbers
%   text(X_ind(TRACE_BASE_TOP(q).index(1)),...
%   Y_ind(TRACE_BASE_TOP(q).index(1)),...
%   num2str(q),'Color','red','FontSize',10); hold on
% end

% PLOT SETTINGS: MAP EXTENT, LEGEND, COLORBAR------------------------------
% limit to map extent
xlim([limits(1,1) limits(1,2)]);
ylim([limits(2,1) limits(2,2)]);
f.Position = image_pos_size;
c = colorbar; set( c, 'YDir'); caxis([0 500]);
colormap(turbo);
c.Label.String = 'Layer thickness [m]';

% FILTERING VALUES AS TEXTBOX ---------------------------------------------
angle_str = strcat({'AngularDiffN < '}, ...
    num2str(norm_angle_diff_threshold),{'°'});
thickness_str = strcat({'ThicknessDiff < '}, ...
    num2str(thickness_diff_threshold));
dist_str = strcat({'DistancePQ < '}, ...
    num2str(max_distance_threshold));
MK_str = strcat({'M > '}, num2str(M_value_threshold), ...
    {', K < '}, num2str(K_value_threshold));
Min_SegmentLength_str = strcat({'SegmentLength > '}, ...
    num2str(Min_SegmentLength), {' points'});


text(X(1)-2500,Y(1),dist_str);
text(X(1)-2500,Y(1)-200,thickness_str);
text(X(1)-2500,Y(1)-400,angle_str);
text(X(1)-2500,Y(1)-600,MK_str);
text(X(1)-2500,Y(1)-800,Min_SegmentLength_str);
% text(X(1)-1000,Y(1)-1500,Nan_str);

hold off;

% % use export_fig function to preserve editability in illustrator
% imageSavePath = strcat(savePath,'Fig1');
% export_fig(imageSavePath, '-png');

% | ------------------------ % END FIGURE 1 %------------------------------