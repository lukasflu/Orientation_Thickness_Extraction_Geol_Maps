% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 09-14-2022 ------------------
% | ----- Update LN: minor changes for map sheet Muotathal, 02-04-2022 ----
% | ----- Update LN: new direct input of lithostrati, literature data, ----
% | -----------------relevant lithostratigraphic units and mapsheet info --
% | ---------------- tables at lines 66 to 80, 20-06-2022 -----------------
% | ----- Update LN: reorganisation after global and mapsheet input -------
% | ----- Update LN: update of extractTRACEnew in GIT directory to make ---
% | ---------------- sure small traces (i.e. sheet Muotathal) are deleted -
% | ---------------- and do not cause an error ----------------------------
% | ----- Update LN: direct input of filtering parameters (mapsheet) ------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | -------------- FILE A: PREPARE INPUT  & PERFORM TIE OUPUT -------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% |  ---------------- LOAD DATA / DEFINE INPUT PARAMETERS -----------------
% | ----------------------------------------------------------------------- 

clear all; clf;

%% *** MANUAL INPUT ****
rootpath = 'C:\Users\lukasflu\Dropbox\00_FGS\11publications\2020_automated_thickness_extraction\Orientation_Thickness_Extraction_Geol_Maps_Repository\';            % This path contains subfolders containing input data per mapsheet and global (CH-wide) input data
% NAME OF MAPSHEET FOLDER -------------------------------------------------
% mapsheet = 'Muotathal';                                                    % Set the mapsheet name to be analysed (mapsheet names are stored in the file Mapsheetnames_boundaries.xlsx)
mapsheet = 'Adelboden';

% PATHES FOR GLOBAL AND MAPSHEET INPUTS -----------------------------------
path_globalfiles = strcat(rootpath,'0_input_global\');
path_mapsheet = strcat(rootpath,'0_input_mapsheet\',mapsheet,'\');

% PATH FOR SAVEING OUTPUT FILES -------------------------------------------
savePath = strcat(rootpath,'2_output_mapsheet\',mapsheet,'\');

% DEFINE TARGET UNIT ------------------------------------------------------
target_unit = 'Helvetischer Kieselkalk';                                   % This string has to be equivalent to the Name of the corresponding sheet in the table HSt_relevant_units.xlsx
% Here is a list of potential target units stored in HSt_relevant_units.xlsx
%   Helvetics:
%   target_unit = 'Nordhelvetische Flysch-Gruppe';
%   target_unit = 'Niederhorn-Formation';
%   target_unit = 'Garschella-Formation';
%   target_unit = 'Helvetischer Kieselkalk';
%   target_unit = 'Sichel-Kalk';
%   target_unit = 'Lias des Helvetikums';
%   target_unit = 'Brunnistock-Formation';
%   target_unit = 'Sexmor-Formation';
%   target_unit = 'Spitzmeilen-Formation';
%   Penninics:
%   target_unit = 'Griggeli-Formation';
%   target_unit = 'Staldengraben-Formation';
%   target_unit = 'Lias der Klippen-Decke';
%   target_unit = 'Rossiniere-Formation';
%   target_unit = 'Heiti-Formation';
%   target_unit = 'Obflue-Formation';
%   target_unit = 'Petit-Liencon-Formation';
%   Southalpine:
%   target_unit = 'Moltrasio-Formation';

% DEFINE PALEOGEOGRAPHIC AFFILIATION OF TARGET UNIT -----------------------
Helvetics = 'A533:A1527';                                                  % Specify the paleogeographic/tectonic domain of the target unit
% GeolCodes are grouped in the following paleogeographic/tectonic domains:
% Helvetics = 'A533:A1527';         % bedrock Helvetics, Jura and Northalpine Foreland: 'A533:A1527'
% Penninics = 'A1767:A2341';        % bedrock Penninics
% Austroalpine = 'A2341:A2537';     % bedrock Austroalpine
% Southalpine = 'A2538:A2694';      % bedrock Southalpine


% DEFINE SEGMENT LENGTH OF MOVING WINDOW FOR BEST FIT ANALYSIS -----------
MovingWindowMaximumLength   = 249;                                         % equals to 500 m segment length between P1 and P250 at a DEM resolution of 2 m
seg = 'no';                                                                % 'no' -> no segmentation algorithm
                                                                           % 'yes' -> segmentation with default values 100 and 15 (see Rauch et al., 2019)
Min_SegmentLength = 40;                                                    % Segments used for orientation information have to be at least 40 points long

%% *** MANUAL INPUT END ****

%% INPUT DATA PREPARATION GLOBAL ------------------------------------------

% LOAD TABLE WITH STRATIGRAPHIC ORDER AND HIERARCHY OF LITHOSTRATI UNITS --
Strati_GeolCodes            = readmatrix(strcat(path_globalfiles,'StratiCH_LiSt_20220614.xlsx'),'Sheet','LiSt','Range',Helvetics);        % loads strings and numbers stored in excel sheet to a cell, list of GeolCodes, ordered by stratigraphic age and/or hierarchy
Strati_GeolCodes = Strati_GeolCodes(~isnan(Strati_GeolCodes));             % remove all NaNs

% Define target unit with GeolCodes;
target_units = readmatrix(strcat(path_globalfiles,'HSt_relevant_units_20220617.xlsx'),'Sheet',target_unit,'Range','A:A');  % loads all GeolCodes, including eventually mapped sub-units
target_units = target_units(~isnan(target_units));                         % remove all NaNs
                
% Preparation top/base units 
index_target_unit1  = find(Strati_GeolCodes==target_units(1));             % get index from first and last target unit GeolCode in the stratigraphy table
index_target_unit2  = find(Strati_GeolCodes==target_units(end));
top_units           = Strati_GeolCodes(1:index_target_unit1-1);            % defines a vector with all potential top layers
base_units          = Strati_GeolCodes(index_target_unit2+1:end);          % defines a vector with all potential base layers

% LOAD THICKNESS DATA EXTRACTED FROM LITERATURE ---------------------------
LitDataXY = readmatrix(strcat(path_globalfiles,'HSt_thickness_literature_20220601.xlsx'),'Sheet','thickness-data','Range','A:B');                % Load XY coordinate data
LitDataGeolCodeThickness = readmatrix(strcat(path_globalfiles,'HSt_thickness_literature_20220601.xlsx'),'Sheet','thickness-data','Range','H:I'); % Load stratigraphic affiliation (GeolCode) and associated thickness values
thickness_data_literature   = [LitDataXY LitDataGeolCodeThickness];                                    % Combine the two into one literature data matrix
thickness_data_literature(any(isnan(thickness_data_literature), 2), :) = [];                           % remove rows which include at least one or more NaNs
% cross_section_coordinates   = load('cross-section-coordinates.txt');                                 % load thickness data extracted from literature (cross-sections and stratigraphic profiles), from excel, save as ms-dos txt file, tab delimited

%% INPUT DATA PREPARATION PER MAPSHEET ------------------------------------
% DEFINE THE COORDINATE LIMITS OF STUDIED AREA ----------------------------
[mapsheet_num,mapsheet_txt] = xlsread(strcat(path_globalfiles,'Mapsheetnames_boundaries.xlsx'),'D2:H8');     % loads data stored in xls as strings and number arrays separately: https://ch.mathworks.com/matlabcentral/answers/141299-how-to-read-a-string-data-from-excel-sheet-or-to-read-a-single-row-having-charaters
limits_idx = find(strcmp(mapsheet_txt, mapsheet));                         % find the line, in which the map edge coordinates of the studied mapsheet are stored
limits = [mapsheet_num(limits_idx,1),...                                   % read the map sheet limits of the studied mapsheed
              mapsheet_num(limits_idx,2);...
              mapsheet_num(limits_idx,3),...
              mapsheet_num(limits_idx,4)]; 

% overwrite the limits, if a smaller subarea is investigated
limits      = [2610815, 2615000; 1146010, 1149200];                        % sector 1 (pilot area Loner LN) [minX, maxX; minY, maxY]

name        = strcat('Example: ',mapsheet,', (Switzerland)');              % name of region (not important, put something)
geotif      = strcat(path_mapsheet,mapsheet,'_swissALTI3D_epsg2056_pilot.tif');   % filename of DEM
hillshade   = strcat(path_mapsheet,mapsheet,'_swissALTI3D_hs_epsg2056_pilot.tif');% filename of DEM

bedshape    = strcat(path_mapsheet,mapsheet,'_BED.shp');                   % shapefile of bedrock (polygon format)
fieldbed    = 'SYMBOL_D';                                                  % name of attribute field that distinguishes between rock types (numeric!)
tecshape    = strcat(path_mapsheet,mapsheet,'_TEC.shp');                   % shapefile of tectonic boundaries, faults, thrusts etc. (line format)
fieldtec    = 'SYMBOL_D';                                                  % name of attribute field that distinguishes between fault types (numeric!)

% optional, only needed for plots in part C:
orientshape = strcat(path_mapsheet,mapsheet,'_OM.shp');                     % shapefile containing orientation measurements of bedding
fieldDip    = 'DIP';                                                       % name of attribute field where the dip is defined
fieldAzim   = 'AZIMUT';                                                    % name of attribute field where the dip direction/azimuth is defined. 

% LOAD AND DEFINE FILTERING THRESHOLD VALUES ------------------------------
threshold_values = readmatrix(strcat(path_globalfiles,'ParameterSpace.xlsx'),'Sheet',mapsheet,'Range','C:C');  % loads the optimum threshold values for a given area
M_value_threshold = threshold_values(2);                                                   % value has to be larger than 4 (value represents stability of signal, Fernandez, 2005)
K_value_threshold = threshold_values(3);                                                   % value has to be smaller than 0.8 (value represents planarity of signal, Fernandez, 2005)
thickness_diff_threshold = threshold_values(4);                                            % maximum difference thickness vs thicknessR = 0.1 (= 10%)
norm_angle_diff_threshold = threshold_values(5);                                           % maximum angular difference = 10°
max_distance_threshold = threshold_values(6);                                              % maximum distance between nearest neighbor top and base pairs P and Q = ca. expected maximum thickness x 2

%% LOAD DEM AND LOAD/RASTERISE GEOLOGICAL VECTOR DATA ---------------------
[X,Y,Z]             = loadCoord(geotif, limits);
[BEDcoor, BEDattr]  = loadBedrock(bedshape, X, Y);   % LN: 2021-12-09: use loadBedrocknew.m function with boundingbox option for shaperead may safe some time if only a subregoin of a mapsheet wants to be analysed?
[TECcoor, TECattr]  = loadTecto(tecshape, X, Y);     % LN: 2021-12-09: use loadTectonew.m function with boundingbox option for shaperead may safe some time if only a subregoin of a mapsheet wants to be analysed??

BED                 = rasterizeBedrock(BEDcoor, BEDattr, X, Y, fieldbed);
TEC                 = rasterizeTecto(TECcoor,TECattr,X,Y,fieldtec);

% | -----------------------------------------------------------------------
% |  ------------- % END LOAD DATA / DEFINE INPUT PARAMETERS %-------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | --------------------- EXTRACT TOP AND BASE TRACES ---------------------
% | ----------- AND STORE THEM IN THE STRUCTURE 'TRACE_BASE_TOP' ----------
% | ---------------------- PERFORM TIE ANALYSIS ---------------------------
% | -----------------------------------------------------------------------
% adapted function extractTraces from A. Rauch TIE Toolbox, make sure this
% function is linked with HSTfunctions (TIEtoolbox)

[TRACE_BASE_TOP, FAULT]  = extractTRACEnew(BED, TEC, base_units, top_units, target_units);  % updated trace function by J. Morgenthaler

bbox = [limits(1,1) limits(2,1); limits(1,2) limits(2,2)];                   % define bounding box to make sure shaperead loads relevant data only [xmin xmax; ymin ymax]

[ORcoor, ORattr]         = shaperead(orientshape,'BoundingBox',bbox);


% TIE TRACE INFORMATION EXTRACTION, ORIENTATION ---------------------------
% fuction tie from A. Rauch TIE Toolbox, make sure this function is
% linked

TRACE_BASE_TOP          = tie(TRACE_BASE_TOP,X,Y,Z,seg);        
FAULT                   = tie(FAULT,X,Y,Z,seg);  

% | -----------------------------------------------------------------------
% | ------------------------------- % END % -------------------------------
% | --------------------- EXTRACT TOP AND BASE TRACES ---------------------
% | ----------- AND STORE THEM IN THE STRUCTURE 'TRACE_BASE_TOP' ----------
% | ---------------------- PERFORM TIE ANALYSIS ---------------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ------------------------- save to workspace ---------------------------
% | -----------------------------------------------------------------------

save([savePath 'workspace_input_TIE']);

% | ------------------------ % END FILE A %--------------------------------