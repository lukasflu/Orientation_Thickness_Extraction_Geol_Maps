% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 09-14-2022 ------------------
% | ----- Update LN: filtering was simplified according to the structure -- 
% | ---------------- of the new outputtable -------------------------------
% | ----- Update LN: Two individual outputtables now contain the filtered -
% | ---------------- orientation and thickness model outputs and associated  
% | ---------------- reliability indocators -------------------------------
% | - Update LN: an error in the outputtable structure was resolved -------
% | ---------------- on the 2022-08-24 ------------------------------------
% | - Update LN: all Figures 1-9 were outsourced to individual scripts-----
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ----------------- FILE C: FILTERING AND PLOTTING  ---------------------
% | -----------------------------------------------------------------------

% PATH TO THE IMPUT FILES -------------------------------------------------
load([savePath 'workspace_thickness_extraction.mat']);

%%

% |------------------------------------------------------------------------
% |-----------%  START FILTERING RELIABLE THICKNESS VALUES %---------------
% |------------------------------------------------------------------------

% THICKNESS DATA FILTERING THRESHOLD VALUES -------------------------------
% overwrite default values if necessary
% M_value_threshold = 5.0;        % 4.0 def.                                 % value has to be larger than 4 (value represents stability of signal, Fernandez, 2005)
% K_value_threshold = 2.5;        % 2.0 def.                                 % value has to be smaller than 0.8 (value represents planarity of signal, Fernandez, 2005)
% thickness_diff_threshold = 0.4;                                            % maximum difference thickness vs thicknessR = 0.01 (= 10%)
% norm_angle_diff_threshold = 80;                                            % maximum angular difference = 10°
% max_distance_threshold = 2000;                                             % maximum distance between nearest neighbor top and base pairs P and Q = expected maximum thickness x 2
% Min_SegmentLength = 40;                                                    % Segments used for orientation information hav to be at least 40 points long

%% PREPARE ORIENTATION DATA FOR FILTERING -----------------------------------
outputtable_orientation4filtering              =  outputtable_orientation;                       % create a matrix containing only the GeolCode fields

% apply filters on orientation outputtable
filter_orient_combined  = find(outputtable_orientation4filtering(:,9)    >  M_value_threshold         & ...
                               outputtable_orientation4filtering(:,10)    <  K_value_threshold         & ...
                               outputtable_orientation4filtering(:,12)   >  Min_SegmentLength);

%% PREPARE THICKNESS DATA FOR FILTERING -----------------------------------
thickness_data_literature4filtering = thickness_data_literature;           % literature data for filtering
outputtable4filtering              =  outputtable_thickness;                       % create a matrix containing only the GeolCode fields

% Select only target units
for r = 1:length(target_units)                                             % loop through the vector target_units
  outputtable4filtering(outputtable4filtering == target_units(r))                           = 2;  % replace all target unit values with a '2', leave the other matrix entries as they are
  thickness_data_literature4filtering(thickness_data_literature4filtering == target_units(r)) = 2;  % replace all target unit values with a '2', leave the other matrix entries as they are
end

filter_literature_data  = find(thickness_data_literature4filtering(:,3) == 2); %select only literature data from target units

% apply filters on thickness outputtable
filter_combined  = find(outputtable4filtering(:,5)    >  M_value_threshold         & ...
                        outputtable4filtering(:,6)    <  K_value_threshold         & ...
                        outputtable4filtering(:,7)    <  thickness_diff_threshold  & ...
                        outputtable4filtering(:,8)    <  norm_angle_diff_threshold & ...
                        outputtable4filtering(:,9)    <  max_distance_threshold    & ...
                        outputtable4filtering(:,11)   >  Min_SegmentLength         & ...
                        outputtable4filtering(:,13)   == 2);

%%

% |------------------------------------------------------------------------
% |% SAVE OUTPUT TXT FILE CONTAINING RELIABILITY CHECKED ORIENTATION DATA %
% |------------------------------------------------------------------------

% Prepare second outputtable containing only reliability checked thickness values
outputtable_orientation_filtered = outputtable_orientation(filter_orient_combined,:);

fileID = fopen([savePath 'output_orientation_filtered.txt'],'w');
fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'X','Y','Z','Dir_X','Dir_Y','Dir_Z','Dip_Direction','Dip',...
        'M','K','T','n(T)');                                                                     % add HeaderLines
fprintf(fileID,'%.7g %.7g %.4g %.4f %.4f %.4f %.2f %.2f %.2f %.2f %d %d \r\n',transpose(outputtable_orientation_filtered));                                                                                                                                                      % transpose in order to read the array in the correct order
fclose(fileID);

%%

% |------------------------------------------------------------------------
% |-% SAVE OUTPUT TXT FILE CONTAINING RELIABILITY CHECKED THICKNESS DATA %-
% |------------------------------------------------------------------------

% Prepare second outputtable containing only reliability checked thickness values
outputtable_thickness_filtered = outputtable_thickness(filter_combined,:);

fileID = fopen([savePath 'output_thickness_filtered.txt'],'w');
fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'X','Y','Z','thickness','M','K','thicknessDiff','AngularDiffN','distance_PQ','SN1','SN1Length',...
        'SN2','GeolCode');                                                                     % add HeaderLines
fprintf(fileID,'%.7g %.7g %.4g %.0f %.2f %.2f %.2f %.3f %.0f %d %d %d %d \r\n',transpose(outputtable_thickness_filtered));                                                                                                                                                      % transpose in order to read the array in the correct order
fclose(fileID);

% |------------------------------------------------------------------------
% |----------- %  END WRITE FILTERED OUTPUT TXT FILES %--------------------
% |------------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ------------------------- save to workspace ---------------------------
% | -----------------------------------------------------------------------

save([savePath 'workspace_thickness_extraction_filtered']);

% | ------------------------ % END FILE C %--------------------------------