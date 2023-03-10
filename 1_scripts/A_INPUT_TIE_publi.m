% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version 1.0: Lukas Nibourel, 10-03-2022 --------------
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
mapsheet = 'Adelboden';   % Name of maphseet to be analysed

% PATHES FOR GLOBAL AND MAPSHEET INPUTS -----------------------------------
path_globalfiles = strcat(rootpath,'0_input_global\');
path_mapsheet = strcat(rootpath,'0_input_mapsheet\',mapsheet,'\');

% PATH FOR SAVEING OUTPUT FILES -------------------------------------------
savePath = strcat(rootpath,'2_output_mapsheet\',mapsheet,'\');

% DEFINE TARGET UNIT ------------------------------------------------------
target_unit = 'Helvetischer Kieselkalk';         % This string has to be equivalent to the Name of the corresponding sheet in the table HSt_relevant_units.xlsx
% Here is a list of potential target units in the Adelboden area (Helvetics)
%   Helvetics:
%   target_unit = 'Niederhorn-Formation';
%   target_unit = 'Garschella-Formation';
%   target_unit = 'Helvetischer Kieselkalk';

% DEFINE PALEOGEOGRAPHIC AFFILIATION OF TARGET UNIT -----------------------
Helvetics = 'A533:A1527';                                                  % Specify the paleogeographic/tectonic domain of the target unit
% GeolCodes are grouped in the following paleogeographic/tectonic domains:
% Helvetics = 'A533:A1527';         % bedrock Helvetics, Jura and Northalpine Foreland: 'A533:A1527'


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

%% INPUT DATA PREPARATION PER MAPSHEET ------------------------------------
% DEFINE THE COORDINATE LIMITS OF STUDIED AREA ----------------------------
limits      = [2610815, 2615000; 1146010, 1149200];                        % mapsheet Adelboden, test area Lohner [minX, maxX; minY, maxY], coordinates have to be in meters

name        = strcat('Example: ',mapsheet,', (Switzerland)');              % name of region (not important, put something)
geotif      = strcat(path_mapsheet,mapsheet,'_swissALTI3D_epsg2056_pilot.tif');   % filename of DEM
hillshade   = strcat(path_mapsheet,mapsheet,'_swissALTI3D_hs_epsg2056_pilot.tif');% filename of HILLSHADE

bedshape    = strcat(path_mapsheet,mapsheet,'_BED.shp');                   % shapefile of bedrock (polygon format)
fieldbed    = 'SYMBOL_D';                                                  % name of attribute field that distinguishes between rock types (numeric!)
tecshape    = strcat(path_mapsheet,mapsheet,'_TEC.shp');                   % shapefile of tectonic boundaries, faults, thrusts etc. (line format)
fieldtec    = 'SYMBOL_D';                                                  % name of attribute field that distinguishes between fault types (numeric!)

% optional, only needed for plots in part C:
orientshape = strcat(path_mapsheet,mapsheet,'_OM.shp');                    % shapefile containing orientation measurements of bedding
fieldDip    = 'DIP';                                                       % name of attribute field where the dip is defined
fieldAzim   = 'AZIMUT';                                                    % name of attribute field where the dip direction/azimuth is defined. 

% LOAD AND DEFINE FILTERING THRESHOLD VALUES ------------------------------
M_value_threshold = 4;                                                     % value has to be larger than 4 (value represents stability of signal, Fernandez, 2005)
K_value_threshold = 2;                                                     % value has to be smaller than 0.8 (value represents planarity of signal, Fernandez, 2005)
thickness_diff_threshold = 0.6;                                            % relative thickness difference ratio 0.1 (= 10%), the smaller the diffference between the thickness values, the more reliable
norm_angle_diff_threshold = 45;                                            % maximum angular difference
max_distance_threshold = 800;                                              % maximum distance between nearest neighbor top and base pairs P and Q = ca. expected maximum thickness x 2

%% LOAD DEM AND LOAD/RASTERISE GEOLOGICAL VECTOR DATA ---------------------
[X,Y,Z]             = loadCoord(geotif, limits);
[BEDcoor, BEDattr]  = loadBedrock(bedshape, X, Y);
[TECcoor, TECattr]  = loadTecto(tecshape, X, Y);

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
