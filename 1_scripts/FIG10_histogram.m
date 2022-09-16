% | -----------------------------------------------------------------------
% |
% | ------------ CUSTOM HISTOGRAM OF A GIVEN TARGET UNIT SEGMENT ----------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 14-09-2022 ------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ----------------------- FIGURE 10: HISTOGRAM PLOTS ---------------------
% | -----------------------------------------------------------------------

%% LOAD WORKSPACE ---------------------------------------------------------

load([savePath 'workspace_thickness_extraction_filtered.mat']);

% Figure 10, histogram plot for individual target unit segment ------------
% -------------------------------------------------------------------------

figure(10)
clf;

% set size of figure
x0 = 100;
y0 = 100;
width = 500;
height = 400;

% the segment numbers are given in the outputtables and on Fig 4
base_segment = 1;
top_segment = 15;
% top_segment2 = 16;

% select all thickness values (no filtering) for two segments
% with or | operators
segment_unfiltered = find(...
    outputtable_thickness(:,10)==base_segment ...
    & outputtable_thickness(:,12)==top_segment ...
    | outputtable_thickness(:,10)==top_segment ...
    & outputtable_thickness(:,12)==base_segment);

% select filtered thickness values from a given pair of segments
% with or | operators
segment_filtered = find(...
    outputtable_thickness_filtered(:,10)==base_segment ...
    & outputtable_thickness_filtered(:,12)==top_segment ...
    | outputtable_thickness_filtered(:,10)==top_segment ...
    & outputtable_thickness_filtered(:,12)==base_segment);

% create matrix containing the unfiltered thickness values of given segment
thickness_selection_all = outputtable_thickness(...
    segment_unfiltered,4);

% create matrix containing the filtered thickness values of given segment
thickness_selection_filtered = outputtable_thickness_filtered(...
    segment_filtered,4);

% create string for unfiltered thickness data
N_str_all = strcat({'N (unfiltered) = '}, ...
    num2str(numel(thickness_selection_all)));

% create string for filtered thickness data
N_str_filtered = strcat({'N (filtered) = '}, ...
    num2str(numel(thickness_selection_filtered)));
mean_segment_filtered = round(mean(thickness_selection_filtered));
mean_segment_str_filtered = num2str(mean_segment_filtered);
mean_stdv_filtered = round(std(thickness_selection_filtered));
mean_stdv_str_filtered = num2str(mean_stdv_filtered);
mean_segment_str_filtered = strcat({'Mean thickness (filtered) = '}, ...
    mean_segment_str_filtered, {' ±'}, mean_stdv_str_filtered, {' m'});

% histogram plot including all thickness data with no filtering
histogram(thickness_selection_all,'BinWidth',20,'FaceColor','w'); hold on;
% histogram plot including the filtered thickness data only
histogram(thickness_selection_filtered,'BinWidth',20,'FaceColor','r');
% % histogram normalized
% histogram(thickness_selection_filtered,'Normalization','pdf', ...
%     'BinWidth',20,'FaceColor','r'); hold on;
title(strcat({'Segments '}, num2str(base_segment), ...
    {', '}, num2str(top_segment)));
xlim([0 400]); xlabel('Layer thickness (m)');
ylim([0 750]); ylabel('Frequency');
% ylabel('Frequency')
set(gcf,'position',[x0,y0,width,height])
text(10,600,N_str_all)
text(10,700,N_str_filtered)
text(10,650,mean_segment_str_filtered)

hold off;

% | ------------------------ % END FIGURE 10 %-----------------------------