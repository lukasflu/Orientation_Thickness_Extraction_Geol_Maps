% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 07-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ---- FIGURE 4: FILTERED MODEL OUTPUT (ALL EDITABLE VECTOR FEATURES)----
% | -------------- FIGURES 3 AND 4 ARE THOUGHT TO BE USED COMBINED --------
% | -----------------------------------------------------------------------

% PATH TO THE IMPUT FILES -------------------------------------------------
load([savePath 'workspace_thickness_extraction_filtered.mat']);

%%

% |------------------------------------------------------------------------
% |--------------------------%  START PLOTTING %---------------------------
% |------------------------------------------------------------------------

% FIGURE 4, PLOT CONTAINING VECTOR DATA EDITABLE IN ILLUSTRATOR -----------
% -------------------------------------------------------------------------

f=figure(4);clf;

% define symbol size, style and font in plots
symbol_size         = 100;                   % symbol size
symbol_line_size    = 1.5;                   % symbol line size
font_size           = 8;

% define image position and size
image_pos_size = [100 100 1800 900];

% highlight base and top traces (base is black, top is dark green)
for k = base_trace_fields
    plot(SegmentsXYZ{1,k}(:,1),SegmentsXYZ{1,k}(:,2), ...
        '.', 'Color', [0,0,0,0.9], 'MarkerSize',3); hold on;
end
for k = top_trace_fields
    plot(SegmentsXYZ{1,k}(:,1),SegmentsXYZ{1,k}(:,2), ...
        '.', 'Color', [0,0.3,0.3,1], 'MarkerSize',3); hold on;
end

% ORIENTATION MEASUREMENTS ------------------------------------------------
visOrientMeasnew(ORcoor, ORattr, fieldAzim, fieldDip, X, Y, Z)

% plot orientation measurements legend
trleg       = ones(1,10)*180;
plleg       = 0:10:90;
[vx,vy,vz]  = angle2vect(trleg,plleg);
cs          = (X(2)-X(1));
barlength   = length(X)*cs/50;

for m = 1:10
     s = m-1;
     [x1,y1]     = stereoLine(trleg,plleg);
     xleg = [X(10+s*12),  X(10+s*12)  + x1(m)*barlength];
     yleg = [Y(10),       Y(10)       + y1(m)*barlength];
     zleg = [max(max(Z)), max(max(Z))                  ];

     plot(xleg, yleg,'k','lineWidth',1.5);
     if m~=10
         hold on
            % correction LN: 2021-12-14, long orientation bars
            % represent large dip!
            text(double(xleg(2)), ...
                double(yleg(2)-10*cs), ...
                double(zleg(1)), ...
                strcat(num2str((9-s)*10),'°'));
     end
     hold on
end

% PLOT ORIENTBARS AND LEGEND ----------------------------------------------

% plot orientation information for base
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

% plot orientation information for top
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


% PLOT THICKNESS DATA ----------------------------------------------------
% % plot automatically extracted and reliability checked thickness data
scatter(outputtable_thickness(filter_combined,1), ...
    outputtable_thickness(filter_combined,2),...
    symbol_size,outputtable_thickness(filter_combined,4),'o','filled');

% % plot literature data
% white background color to enhance visibility
scatter(thickness_data_literature(filter_literature_data,1),...
    thickness_data_literature(filter_literature_data,2),...
    symbol_size*2.5,'w','d','LineWidth',6);
% plot literature date color coded
scatter(thickness_data_literature(filter_literature_data,1),...
    thickness_data_literature(filter_literature_data,2),...
    symbol_size*2.5, ...
    thickness_data_literature(filter_literature_data,4), ...
    'd','LineWidth',2.5);

% PLOT TRACE NUMBERS ----------------------------------------------------
for q = top_base_trace_fields
  text(X_ind(TRACE_BASE_TOP(q).index(1)), ...
      Y_ind(TRACE_BASE_TOP(q).index(1)),num2str(q), ...
      'Color','red','FontSize',10); hold on
end

% PLOT SETTINGS: MAP EXTENT, LEGEND, COLORBAR------------------------------
% limit to map extent
axis equal;
xlim([limits(1,1) limits(1,2)]);
ylim([limits(2,1) limits(2,2)]);
f.Position = image_pos_size;
%axis equal;
% set(gca,'CLim',[min(thickness_mean) max(thickness_mean)]);
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


text(X(1)-1000,Y(1),dist_str);
text(X(1)-1000,Y(1)-100,thickness_str);
text(X(1)-1000,Y(1)-200,angle_str);
text(X(1)-1000,Y(1)-400,MK_str);
text(X(1)-1000,Y(1)-500,Min_SegmentLength_str);

hold off;

% % use export_fig function to preserve editability in illustrator
% imageSavePath = strcat(savePath,'Fig4');
% export_fig(imageSavePath, '-eps');

% | ------------------------ % END FIGURE 4 %------------------------------