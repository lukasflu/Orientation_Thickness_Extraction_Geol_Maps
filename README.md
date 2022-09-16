# Orientation_Thickness_Extraction_Geol_Maps
Routine to automatically extract the orientation and stratigraphic thickness of a given geological bedrock unit from geological maps

***
PURPOSE:

The "Orientation_Thickness_Extraction_Geol_Maps" routine is designed to automatically extract quantitative geometric informations from geological maps. The routine (A) first automatically extracts the top and base contacts of a specified lithostratigraphic unit. (B) A second script extracts the orientation along these contacts and estimates the stratigraphic thickness of the target unit at a given locality based on the automatically extracted orientation information. (C) Different numeric parameters are proposed to evaluate the reliability of the extracted orientation and thickness model output. An example input data set was added to the repository and helps to test and get used to the presented toolbox. For more information, see Nibourel et al. (submitted): *add doi here*

***
TECHNICAL REQUIREMENTS:

The routine was written and tested in Matlab (version 2021b). Therefore, Matlab must be installed to run the scripts.
The routine uses some third party functions from the TIE toolbox (Rauch et al. 2019) and the moment of inertia function (Fernandez, 2005).
References are given below. All necessary new and existing scripts are stored in the subfolder "1_used_functions" of this data repository.

***
INPUT DATA AND REQUIREMENTS:

The geological map vector data must be loaded in a projected coordinate system (typically a national projected system, CH1903+ / LV95, epsg: 2056 in the example data set), where the coordinates are expressed in meters.
All input data must be loaded with the same projected coordinate system. It is recommended to work on one map sheet at once. This avoids mapsheet boundary effects and saves calculation time. Additionally, the optimal filtering parameters might vary from map sheet to map sheet.
In the following, all input data are listed, important requirements of the input data specified. The file names reflect the input data of our test data set (see Nibourel, et al., submitted)

REQUIRED INPUT DATA FOR ORIENTATION AND THICKNESS EXTRACTION:

1. mapsheet_BED.shp:                      Geological map vector data set, shapefile containing mapped bedrock exposures.
                                          In the data set, different lithostratigraphic units must be specified as numeric attribute field (see GeolCodes in the example data set)
2. mapsheet_TEC.shp:                      Shapefile conataining faults and other tectonic boundaries
                                          In the data set, faults must be specified with numeric attribute field
3. mapsheet_swissALTI3D_epsg2056.tif:     Digital elevation model raster data
4. StratiCH_LiSt_20220614.xls:            Table containing a list of the mapped lithostratigraphic bedrock units
                                          These units have to be ordered after stratigraphic age and hierarchy (i.e. Group, Sub-group, Formation, Member)
                                          This list is necessary for the top base definition, the example table was received on the 2022-06-14 by A. Morard (swisstopo)

SUPPLEMENTARY INPUT DATA FOR OUTPUT VALIDATION AND VISUALISATION:

These input data are not required for the routine to run, but are used to in the example data set to enable fast processing of multiple map sheets and to visualise and validate the model output.

5. HSt_relevant_units_20220617.xls:       Table containing the GeolCodes of the potentially hard rock bearing lithostratigraphic units and eventually mapped sub-units
                                          This is particularly helpful if a large number of lithostratigraphic units have to be analysed
6. ParameterSpace.xls:                    Table containing the optimal filtering parameter set for each analysed map sheet
7. Mapsheetnames_boundaries.xls:          Table containing the mapsheet boundaries of each mapsheet to be analysed
                                          This is particularly helpful if a large number of map sheets are to be analysed
8. mapsheet_OM.shp:                       Shapefile containing orientation field measurements (e.g., dip direction/dip of bedding)
                                          These data points are used to validate the model orientation output and to optimise the reliability assessment.
9. HSt_thickness_literature_20220601.xls: Layer thickness estimates based on published stratigraphic descriptions or geological cross sections
                                          These data points are used to validate the thickness output and to optimise the reliability assessment of the model output.
10. mapsheet_swissALTI3D_hs_epsg2056.tif: Hillshade derived from digital elevation model raster data. Only used for visualisation

All input data have to be saved in the current Matlab path or have to be registered in a Matlab search path.

***
ORGANISATION OF DOCUMENTS:

The "Orientation_Thickness_Extraction_Geol_Maps" routine contains five folders. These are:

- 0_input_global
	-> contains all input data that are not specific to a map sheet (i.e. stratigraphic list/hierarchy of mapped bedrock units)
- 0_input_mapsheet
	-> contains all input data that are specific to a given map sheet / area (i.e., bedrock, tectonic lines input, DEM)
- 1_scripts
	-> contains the main scripts related to the "Orientation_Thickness_Extraction_Geol_Maps" routine
- 1_used_functions
	-> contains all functions that are per se independent from the "Orientation_Thickness_Extraction_Geol_Maps" or function from third party developers (i.e. Fernandez, 2005, Rauch et al., 2019)
- 2_output_mapsheet
	-> this folder will contain the model ouptut text files and figures

***
PROCEDURE:

1. run script A_INPUT_TIE.m: -> define pathes to input data and output folder, all manual inputs and the input data are defined, loaded and the top and base traces are extracted

2. run script B_ORIENTATION_THICKNESS_EXTRACTION.m:
-> the orientation and thickness data are extracted and stored with associated reliability indicators

3. run script C_FILTERING.m
-> the orientation and thickness data are classified and filtered by using the reliability threshold values specified in the file "ParameterSpace.xls"
   Make sure the "Orientation_Thickness_Extraction_Geol_Maps" routine with all its subfolders is registered as a Matlab search path.

***
OUTPUT FILES:

The routine produces 4 output textfiles and optionally 10 figures.
The output text files are optimised to facilitate the data export to standard GIS applications.
The figures are optimised to enable a rapid output validation and to allow editability in AdobeIllustrator.
All output files and their structure are listed below:

1. output_orientation_unfiltered.txt: main output file generated at the end of B_ORIENTATION_THICKNESS_EXTRACTION 
	- column 1: 'X', x coordinate of orientation information = center coordinate of moving window
	- column 2: 'Y', y coordinate of orientation information = center coordinate of moving window
	- column 3: 'Z', z coordinate of orientation information = center coordinate of moving window
	- column 4: 'DIR_X', x component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005) 
	- column 5: 'DIR_Y', y component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
	- column 6: 'DIR_Z', z component of unit normal vector DIR to the planar fit at this locality (Fernandez, 2005)
	- column 7: 'DIP_DIRECTION', dip direction calculated by the moment of inertia function in moving window mode
	- column 8: 'DIP', dip calculated by the moment of inertia function in moving window mode
	- column 9: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
	- column 10: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
	- column 11: 'T', index number of analysed trace
	- column 12: 'n(T)', length of the analysed trace (number of points considered, not in meters)

2. output_thickness_unfiltered.txt: main output file generated at the end of B_ORIENTATION_THICKNESS_EXTRACTION
	- column 1: 'X', x coordinate of central thickness point = center of thickness vector D or D'
	- column 2: 'Y', y coordinate of central thickness point = center of thickness vector D or D'
	- column 3: 'Z', z coordinate of central thickness point = center of thickness vector D or D'
	- column 4: 'thickness', estimated layer thickness, length of vector D, calculated from base trace
	- column 5: 'M', co-planarity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
	- column 6: 'K', co-linearity of nodes, reliability assessment of best-fit plane after Fernandez (2005)'
	- column 7: 'thicknessDiff', rel. difference "delta" between D and D'
	- column 8: 'AngularDiffN', angular difference "alpha" between vectors D and D'
	- column 9: 'distance_PQ', shortest distance between nearest neighbor points P and Q on top and base trace
	- column 10: 'T1', index number of first trace to be analysed
	- column 11: 'n(T1)', length of the trace (number of points considered, not in meters)
	- column 12: 'T2', index number of nearest neighbor trace
	- column 13: 'GeolCode', geol. unit at the center position of vectors D or D' (see also X,Y)

3. output_orientation_filtered.txt: filtered output file generated at the end of C_FILTERING
	- selection of reliability assessed and filtered orientation outputs, same structure as output_orientation_unfiltered.txt

4. output_thickness_filtered.txt: filtered output file generated at the end of C_FILTERING
	- selection of reliability assessed and filtered thickness outputs, same structure as output_thickness_unfiltered.txt

FIGURES:
	- Figure 1:     All in one figure including DEM (hillshade), geological map, extracted orientation data and reliability assessed thickness point data
	- Figure 2:     3D Plot showing extracted top and base horizons
	- Figure 3:     Background map, DEM, geological map with target unit (Figure 3 is a raster format output, even when exported as .svg)
	- Figure 4:     Model output, layer orientation and thickness estimates for target layer (Figure 4 does not contain any raster data, all vectors can be edited, very useful for production of final figures, uncomment export_fig function to enhance editability in Ai) -> combine Figures 3 and 4!
	- Figure 5:     Figure including the orientation reliability indicator M
	- Figure 6:     Figure including the orientation reliability indicator K
	- Figure 7:     Figure including the thickness reliability indicator delta
	- Figure 8:     Figure including the thickness reliability indicator alpha
	- Figure 9:     Figure including the thickness reliability indicator distPQ
	- Figure 10:    Histogram plot of thickness values a long a given target unit segment

***
EXAMPLE:

The example data are already set as initial data set in the script "A_INPUT_TIE". If you wish to run your own data, change the INPUT data in "A_INPUT_TIE".
The data are presented and discussed in detail in Nibourel et al. (submitted): *add doi here*

***
REFERENCES:
Rauch et al., 2019. Trace Information Extraction (TIE): A new approach to extract structural information from traces in geological maps. Journal of Structural Geology, 125, 268-300, doi: 10.1016/j.jsg.2019.06.007
 
Fernandez, 2005. Obtaining a best fitting plane through 3D georeferenced data. Journal of Structural Geology, 125, 268-300, doi: 10.1016/j.jsg.2004.12.004

***
CONTACT:

Lukas Nibourel // ETH Zurich // lukas.nibourel@erdw.ethz.ch
