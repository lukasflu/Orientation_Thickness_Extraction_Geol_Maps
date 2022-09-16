% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | ---- For more information see Nibourel et al. (submitted to JSG) ------
% | ---------------- Version: Lukas Nibourel, 14-09-2022 ------------------
% | ------- This version was developed and tested in Matlab R2021b --------
% | 
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ------------------------ FILE 0: READ_ME ------------------------------
% | -----------------------------------------------------------------------

% BEFORE START ------------------------------------------------------------
% Link the folder 1_used_functions* in Home -> Set path -> Add with
% Subfolder! This folder contains all the functions needed by the thickness
% extraction routine

% FUNCTION OVERVIEW -------------------------------------------------------
% the functions used in the approach are listed below and are stored at:
% *your_rootpath*\Orientation_Thickness_Extraction_Geol_Maps_Repository

% 1_thickness_extr_nibourel2022 -------------------------------------------
% This folder contains functions which were developed for the thickness
% extraction routine (these functions are modified TIE functions, 
% Rauch et al., 2019, reference appended below)
% * extractTRACEnew.m
% * loadBedrocknew.m
% * loadTectonew.m
% * visOrientMeasnew.m

% 2_TIE_functions_rauch2019 -----------------------------------------------
% Functions from TIE, Rauch et al. (2019), reference appended below
% * GENERALfunctions (TIE, Rauch et al., 2019, reference is appended below)
% * LOADfunctions (TIE)
% * TRACEfunctions (TIE)
% * TRACEvisualize (TIE)

% 3_moment_of_inertia_fernandez2005 ---------------------------------------
% The function intertia.m from Fernandez (2005) is used for the extraction
% of the orientation information, reference appended below

% 4_other_existing_matlab_functions ---------------------------------------
% This folder contains other not built-in Matlab functions
% * turbo.m includes a colormap used in the study

% | -----------------------------------------------------------------------
% | --------------------- DESCRIPTION OF INPUT/OUTPUT ---------------------
% | -----------------------------------------------------------------------

% INPUT  ------------------------------------------------------------------
% mapsheet_BED.shp:                     shapefile containins only bedrock units, excl. gravitational slope instabilities (CH1903+ / LV95, epsg: 2056)
% mapsheet_TEC.shp:                     shapefile conataining faults and other tectonic boundaries (CH1903+ / LV95, epsg: 2056)
% mapsheet_OM.shp:                      shapefile containing orientation measurements (dip/dipazimuth, CH1903+ / LV95, epsg: 2056)
% mapsheet_swissALTI3D_epsg2056.tif:    digital elevation model raster data, resolution 2m
% mapsheet_swissALTI3D_hs_epsg2056.tif: hillshade derived from digital elevation model raster data, resolution 2m, only for visualisation
%
% -> Preparation of the above GIS data input for the Matlab routine is described in:
%    C:\Users\lflue\Dropbox\00_FGS\02data\02_thickness_estimation\01_Matlab_routine_Fernandez_LN_20211209\0_input\20211216_preparation_GIS-data4thickness_eval.docx        
% -> Projection of input files: CH1903+/LV95, epsg 2056 (use reproject to change projection if other input CRS are used)
% -> It is recommended to work on one 1:25'000 map sheet at once. This
%    avoids mapsheet boundary effects and saves calculation time.
%    Additionally, the filtering parameters might vary depending on the
%    quality of a given map sheet.

% HSt_relevant_units_20220617.xls: table containing the GeolCodes of the
%    potentially hard rock bearing lithostratigraphic units in Switzerland
%
% HSt_thickness_literature_20220601.xls: layer thickness estimates based on
%    stratigraphic descriptions or geological cross sections
%    (CH1903+ / LV95, epsg: 2056)
% 
% Mapsheetnames_boundaries.xls: mapsheet boundaries of the mapsheet data
%    stored in the individual folders
%
% ParameterSpace.xls: table containing the optimal filtering parameter set
%    for each mapsheet
%
% StratiCH_LiSt_20220614.xls: table containing
%    a harmonised list of lithostratigraphic units, needed for the 
%    top base definition, the table was received on the 2022-06-14 by A.
%    Morard (swisstopo)

% TRACE -------------------------------------------------------------------
% TRACE.index:                          ordered index array of trace points within the matrix.
% TRACE.Segment:                        structure of trace segments. Fields of structure:
% Segment.index:                        indexes of Trace.index. If only
%                                       one segment exists, Segment.index = 1:length(TRACE.index)
% TRACE.orientbar:                      orientation bars for each point on TRACE based on the chord planes
% BED:                                  GeolCode for every cell of the yx matrix

% OUTPUT ------------------------------------------------------------------

% ORIENTATION DATA
% output_orientation_unfiltered.txt: 
%   column 1: 'X', x coordinate of orientation information = center coordinate of moving window
%   column 2: 'Y', y coordinate of orientation information = center coordinate of moving window
%   column 3: 'Z', z coordinate of orientation information = center coordinate of moving window
%   column 4: 'DIR_X', x component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005) 
%   column 5: 'DIR_Y', y component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
%   column 6: 'DIR_Z', z component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
%   column 7: 'DIP_DIRECTION', dip direction calculated by the moment of inertia function in moving window mode
%   column 8: 'DIP', dip calculated by the moment of inertia function in moving window mode
%   column 9: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 10: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 11: 'T', index number of analysed trace
%   column 12: 'n(T)', length of the analysed trace (number of points considered, not in meters)

%
% output_orientation_filtered.txt:    -> selection of reliability assessed thickness values, additional field 22 with plotted thickness values 
%   column 1: 'X', x coordinate of orientation information = center coordinate of moving window
%   column 2: 'Y', y coordinate of orientation information = center coordinate of moving window
%   column 3: 'Z', z coordinate of orientation information = center coordinate of moving window
%   column 4: 'DIR_X', x component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005) 
%   column 5: 'DIR_Y', y component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
%   column 6: 'DIR_Z', z component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
%   column 7: 'DIP_DIRECTION', dip direction calculated by the moment of inertia function in moving window mode
%   column 8: 'DIP', dip calculated by the moment of inertia function in moving window mode
%   column 9: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 10: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 11: 'T', index number of analysed trace
%   column 12: 'n(T)', length of the analysed trace (number of points considered, not in meters)


% THICKNESS DATA
% output_thickness_unfiltered.txt: 
%   column 1: 'X', x coordinate of central thickness point = center of thickness vector D or D'
%   column 2: 'Y', y coordinate of central thickness point = center of thickness vector D or D'
%   column 3: 'Z', z coordinate of central thickness point = center of thickness vector D or D'
%   column 4: 'thickness', estimated layer thickness, length of vector D, calculated from base trace
%   column 5: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 6: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 7: 'thicknessDiff', rel. difference "delta" between D and D'
%   column 8: 'AngularDiffN', angular difference "alpha" between vectors D and D'
%   column 9: 'distance_PQ', shortest distance between nearest neighbor points P and Q on top and base trace
%   column 10: 'T1', index number of first trace to be analysed
%   column 11: 'n(T1)', length of the trace (number of points considered, not in meters)
%   column 12: 'T2', index number of nearest neighbor trace
%   column 13: 'GeolCode', geol. unit at the center position of vectors D or D' (see also X,Y)

%
% output_thickness_filtered.txt:    -> selection of reliability assessed thickness values, additional field 22 with plotted thickness values 
%   column 1: 'X', x coordinate of central thickness point = center of thickness vector D or D'
%   column 2: 'Y', y coordinate of central thickness point = center of thickness vector D or D'
%   column 3: 'Z', z coordinate of central thickness point = center of thickness vector D or D'
%   column 4: 'thickness', estimated layer thickness, length of vector D, calculated from base trace
%   column 5: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 6: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
%   column 7: 'thicknessDiff', rel. difference "delta" between D and D'
%   column 8: 'AngularDiffN', angular difference "alpha" between vectors D and D'
%   column 9: 'distance_PQ', shortest distance between nearest neighbor points P and Q on top and base trace
%   column 10: 'T1', index number of first trace to be analysed
%   column 11: 'n(T1)', length of the trace (number of points considered, not in meters)
%   column 12: 'T2', index number of nearest neighbor trace
%   column 13: 'GeolCode', geol. unit at the center position of vectors D or D' (see also X,Y)


% FIGURES -----------------------------------------------------------------
% Figure 1:     All in one figure including DEM (hillshade), geological map, extracted orientation data and reliability assessed thickness point data
% Figure 2:     3D Plot showing extracted top and base horizons
% Figure 3:     Background map, DEM, geological map with target unit (Figure 3 is a raster format output, even when exported as *.svg)
% Figure 4:     Model output, layer orientation and thickness estimates for target layer (Figure 4 does not contain any raster data,
%               all vectors can be edited, very useful for production of
%               final figures, uncomment export_fig function to enhance editability in Ai) -> combine Figures 3 and 4!
% Figure 5:     Figure including the orientation reliability indicator M
% Figure 6:     Figure including the orientation reliability indicator K
% Figure 7:     Figure including the thickness reliability indicator delta
% Figure 8:     Figure including the thickness reliability indicator alpha
% Figure 9:     Figure including the thickness reliability indicator distPQ
% Figure 10:    Histogram plot of thickness values a long a given target unit segment


% KEY REFERENCES:  --------------------------------------------------------
% Rauch et al., 2019. Trace Information Extraction (TIE): A new approach to extract structural
% information from traces in geological maps. Journal of Structural
% Geology, 125, 268-300, doi: 10.1016/j.jsg.2019.06.007
% 
% Fernandez, 2005. Obtaining a best fitting plane through 3D georeferenced
% data. Journal of Structural Geology, 125, 268-300, doi: 10.1016/j.jsg.2004.12.004
%

% | -----------------------------------------------------------------------
% | ------------------% END DESCRIPTION OF INPUT/OUTPUT %------------------
% | -----------------------------------------------------------------------

% Open points LN:

% -> add option segmentation in Fernandez version? Not necessary with
%       moving window..
% -> inverse P and Q through the entire code?
% -> start with sensitivity analysis (test all filtering parameters)
% -> notify A. Rauch on Segmentation error

% Done:
% -> Segmentation fails at element number 53 and 71 and 209 in function "tie" when "segmentTRACE" input must be positive integer or logical?? -> resolved and saved in segmentTRACE! 20210202

% | ------------------------ % END FILE 0 %--------------------------------