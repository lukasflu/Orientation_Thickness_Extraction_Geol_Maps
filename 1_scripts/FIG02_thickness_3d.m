% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) ----------
% | ---------------- Version: Lukas Nibourel, 07-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ---- FIGURE 2: 3D PLOT OF TOP, BASE TRACES AND THICKNESS VECTORS  -----
% | -----------------------------------------------------------------------

% PATH TO THE IMPUT FILES -------------------------------------------------
load([savePath 'workspace_thickness_extraction_filtered.mat']);

%%

% |------------------------------------------------------------------------
% |--------------------------%  START PLOTTING %---------------------------
% |------------------------------------------------------------------------

% Figure 2, 3D plot top, base traces and thickness vectors ----------------
% -------------------------------------------------------------------------

f=figure(2);clf;

% define image position and size
image_pos_size = [100 100 1800 900];

% plot top and base point clouds
for k = base_trace_fields
    plot3(SegmentsXYZ{1,k}(:,1), ...
        SegmentsXYZ{1,k}(:,2), ...
        SegmentsXYZ{1,k}(:,3), ...
        'Color', [0,0,0,0.9], 'MarkerSize',7); hold on;
end

for k = top_trace_fields
    plot3(SegmentsXYZ{1,k}(:,1), ...
        SegmentsXYZ{1,k}(:,2), ...
        SegmentsXYZ{1,k}(:,3), ...
        'Color', [0,0.3,0.3,1], 'MarkerSize',7); hold on;
end

% plot thickness vectors for basetraces (green)
for j=1:10:length(pointsxyz_base)
    plot3([PR(j,1), P0R(j,1)], ...
        [PR(j,2), P0R(j,2)], ...
        [PR(j,3), P0R(j,3)], ...
        '-g', 'MarkerSize',7);
    plot3([QR(j,1), Q0R(j,1)], ...
        [QR(j,2), Q0R(j,2)], ...
        [QR(j,3), Q0R(j,3)], ...
        '-g','MarkerSize',7);
end

%  plot thickness vectors vectors for toptraces (red)
for i=1:10:length(pointsxyz_top)
    plot3([P(i,1), P0(i,1)], ...
        [P(i,2), P0(i,2)], ...
        [P(i,3), P0(i,3)], ...
        '-r', 'MarkerSize',12);
    plot3([Q(i,1), Q0(i,1)], ...
        [Q(i,2), Q0(i,2)], ...
        [Q(i,3), Q0(i,3)], ...
        '-r','MarkerSize',12);
end

% specify plot
grid on;
axis equal;
title('3D plot top base traces and associated thickness vectors')
xlim([limits(1,1) limits(1,2)]) %set xy to mapextent limits
ylim([limits(2,1) limits(2,2)])
f.Position = image_pos_size;
%view(2)                                        % forces a 2D map view

hold off;

% | ------------------------ % END FIGURE 2 %------------------------------