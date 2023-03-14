# Orientation_Thickness_Extraction_Geol_Maps
Routine to automatically extract the orientation and stratigraphic thickness of a given geological bedrock unit from geological maps

***
PURPOSE:

The "Orientation_Thickness_Extraction_Geol_Maps" routine is designed to automatically extract the orientation (dip direction / dip) and the stratigraphic thickness of a bedrock unit of interest from one, or more, geological vector maps. The routine first (script A) automatically extracts the top and base contacts of a specified lithostratigraphic unit. The second script B extracts the orientation along these contacts and estimates the stratigraphic thickness of the unit at a given locality based on the extracted orientation information. The third script C uses different numeric parameters to evaluate the reliability of the extracted orientation and thickness model output. This repository contains an example input data set to understand and test the routine. For more information and application examples, see **Nibourel et al. (2023)**: *add doi here*.

Key words: geology, thickness, orientation, automated 3d info extraction

***
TECHNICAL REQUIREMENTS:

- MathWorks MATLAB (Version 2021b): The routine was developed and tested with this version

***
GET STARTED:

1. In MATLAB, link the folder `*your_rootpath*\Orientation_Thickness_Extraction_Geol_Maps_Repository\1_used_functions` in Home -> Set path -> Add with Subfolder!
This folder contains all the functions needed by the routine (see section USED FUNCTIONS below)

Run the scripts stored in the folder `*your_rootpath*\Orientation_Thickness_Extraction_Geol_Maps_Repository\1_scripts` in the following order:

2. `A_INPUT_TIE.m`: -> create/define pathes to input data and output folder, all manual inputs and the input data are defined, loaded and the top and base traces are extracted

3. `B_ORIENTATION_THICKNESS_EXTRACTION.m`:
-> the orientation and thickness data are extracted and stored in the output folder with associated reliability indicators

4. `C_FILTERING.m`
-> the orientation and thickness data are classified and filtered by using the reliability threshold values specified in the script A.
   Make sure the "Orientation_Thickness_Extraction_Geol_Maps" routine with all its subfolders is registered as a Matlab search path.

5. Run scripts `FIG01_thickness_model_literature_output.m` and other Figure scripts for visualisation and validation of model output.

***
MANDATORY INPUT DATA AND REQUIREMENTS:

The geological map vector data is a topologically-correct set of polygons in shapefile format that are projected in a EPSG-recognized Coordinate Reference System (e.g. CH1903+ / LV95, EPSG: 2056 in the example data set), where the coordinates are expressed in meters. 
The Digital Terrain Model is in raster format (e.g. GeoTIFF), projected in the same Coordinate Reference System as the geological map vector data. 

If the project intends to process several geological map sheets, it is recommended to work with one sheet after the other. This avoids map sheet boundary truncation effects and saves calculation time. Additionally, the optimal filtering parameters mightare likely to vary from map sheet to map sheet. 

In the following, all the mandatory input data are listed and important requirements of the input data are specified. The file names reflect the input data of our test data set (see Nibourel, et al., submitted):

1. `mapsheet_BED.shp`:                      Geological map vector data set, polygon shapefile containing the mapped bedrock exposures.
                                          In the data set, the different lithostratigraphic units must be expressed as numeric (integer) attributes (see the attribute GeolCodes in the example data set).
2. `mapsheet_TEC.shp`:                      Line shapefile containing faults and other tectonic boundaries.
                                          In the data set, faults must be specified with a numeric attribute field.
3. `mapsheet_swissALTI3D_epsg2056.tif`:     Digital elevation model in raster format.
4. `StratiCH_LiSt_20220614.xls`:            Table containing the mapped lithostratigraphic bedrock units.
                                          In order to have a clear top base definition, these units have to be ordered after stratigraphic age and hierarchy (i.e. Group, Sub-group, Formation, Member)
                                          The example table provided refers to the list obtained from the Lithostratigraphic Lexicon of Switzerland (www.strati.ch), status was June 14th, 2022.

OPTIONAL INPUT DATA:

These input data are not required for the routine to run, but are used in the example data set to visualise and validate the model output.

5. `HSt_relevant_units_20220617.xls`:       Table containing the "GeolCodes" of the potentially hard rock bearing lithostratigraphic units and eventually mapped sub-units
6. `mapsheet_OM.shp`:                       Shapefile containing orientation field orientation measurements (e.g., dip direction/dip of bedding)
                                          These data points are used to validate the model orientation output and to optimise the reliability assessment.
7. `HSt_thickness_literature_20220601.xls`: Layer thickness estimates based on published stratigraphic descriptions or geological cross sections
                                          These data points are used to validate the thickness output and to optimise the reliability assessment of the model output.
10. `mapsheet_swissALTI3D_hs_epsg2056.tif`: Hillshade derived from digital elevation model raster data. Only used for visualisation part.

All input data have to be saved in the current Matlab path or have to be registered in a Matlab search path.

***
STRUCTURE OF THE REPOSITORY:

The "Orientation_Thickness_Extraction_Geol_Maps" routine contains five folders. These are:

- `0_input_global`
	-> contains all input data that are not specific to a map sheet (i.e. stratigraphic list/hierarchy of mapped bedrock units)
- `0_input_mapsheet`
	-> contains all input data that are specific to a given map sheet / area (i.e., bedrock, tectonic lines input, DEM)
- `1_scripts`
	-> contains the main scripts related to the "Orientation_Thickness_Extraction_Geol_Maps" routine
- `1_used_functions`
	-> contains all functions that are per se independent from the "Orientation_Thickness_Extraction_Geol_Maps" routine or functions from other developers (i.e. Fernandez, 2005, Rauch et al., 2019)
- `2_output_mapsheet`
	-> this folder will contain the model ouptut text files and figures

***
USED FUNCTIONS:

The routine builds on and partly uses the following third party functions (References are given below):
- TIE toolbox (Rauch et al. 2019, [Link to GITHub repository](https://github.com/geoloar/TIE-toolbox/))
- Moment of inertia function (Fernandez, 2005, [Link to Matlab file exchange repository](https://ch.mathworks.com/matlabcentral/fileexchange/46840-inertia-m))
- Turbo Colormap ([Link to Matlab file exchange repository](https://ch.mathworks.com/matlabcentral/fileexchange/74662-turbo))

All necessary new and existing functions are listed below and are stored at:
`*your_rootpath*\Orientation_Thickness_Extraction_Geol_Maps_Repository\1_used_functions\`

`1_thickness_extr_nibourel2022`

This folder contains functions which were developed for the thickness
extraction routine (these functions are modified TIE functions, 
Rauch et al., 2019, reference appended below)
* extractTRACEnew.m
* loadBedrocknew.m
* loadTectonew.m
* visOrientMeasnew.m

`2_TIE_functions_rauch2019`

Functions from TIE, Rauch et al. (2019), reference appended below
* GENERALfunctions (TIE, Rauch et al., 2019, reference is appended below)
* LOADfunctions (TIE)
* TRACEfunctions (TIE)
* TRACEvisualize (TIE)

`3_moment_of_inertia_fernandez2005`

* intertia.m the function from Fernandez (2005) is used for the extraction
of the orientation information, reference appended below

`4_other_existing_matlab_functions`

This folder contains other not built-in Matlab functions
* turbo.m includes a colormap used in the routine


***
OUTPUT FILES:

The routine produces 4 output textfiles and optionally 10 figures.
In the output text files, the thickness values and reliability parameters are stored together with separate X Y Z values to facilitate the data import into standard GIS applications.
The figures are optimised to enable a rapid output validation and can be exported to svg format to allow editability in the most commonly used graphics software.
All output files and their structure are listed below.

Text files (points):

1. `output_orientation_unfiltered.txt`: main output file generated at the end of B_ORIENTATION_THICKNESS_EXTRACTION 
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

2. `output_thickness_unfiltered.txt`: main output file generated at the end of B_ORIENTATION_THICKNESS_EXTRACTION
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

3. `output_orientation_filtered.txt`: filtered output file generated at the end of C_FILTERING
	- selection of reliability assessed and filtered orientation outputs, same structure as output_orientation_unfiltered.txt

4. `output_thickness_filtered.txt`: filtered output file generated at the end of C_FILTERING
	- selection of reliability assessed and filtered thickness outputs, same structure as output_thickness_unfiltered.txt

Figures:

- Figure 1:     All in one figure including DEM (hillshade), geological map, extracted orientation data and reliability assessed thickness point data
- Figure 2:     3D Plot showing extracted top and base horizons
- Figure 3:     Background map, DEM, geological map with target unit (Figure 3 is a raster format output, even when exported as .svg)
- Figure 4:     Model output, layer orientation and thickness estimates for target layer (Figure 4 does not contain any raster data, all vector data can be edited, very useful for production of final figures, uncomment ´export_fig´ function (lines 174-176) to enhance editability in graphics software) -> combine Figures 3 and 4!
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
CITATION:

A detailed documentation of the approach and a potential application test case for the mining sector can be found in Nibourel et al. (2023), see below:

**Nibourel L., Morgenthaler J., Grazioli S., Schumacher I., Schlaefli S., Galfetti T., Heuberger S., 2023. Automated extraction of orientation and stratigraphic thickness from geological maps. Journal of Structural Geology, ???, ???-???, doi: ???**

Please, cite this publication if you apply the "Orientation_Thickness_Extraction_Geol_Maps" routine. 

***
REFERENCES:

Rauch et al., 2019. Trace Information Extraction (TIE): A new approach to extract structural information from traces in geological maps. Journal of Structural Geology, 125, 268-300, doi: 10.1016/j.jsg.2019.06.007
 
Fernandez, 2005. Obtaining a best fitting plane through 3D georeferenced data. Journal of Structural Geology, 125, 268-300, doi: 10.1016/j.jsg.2004.12.004

The following data are used as an example and are available at www.swisstopo.ch:

- the 1:25'000 GeoCover geological vector data set of Switzerland, including the bedrock data, the faults and the orientation measurements
- the digital elevation model swissALTI3D

***
CONTACT:

Lukas Nibourel // Georesources Switzerland Group //  ETH Zurich // lukas.nibourel@erdw.ethz.ch

https://georessourcen.ethz.ch/
