# Orientation_Thickness_Extraction_Geol_Maps
Routine to automatically extract the orientation and stratigraphic thickness of a given geological bedrock unit from geological maps

PURPOSE:

The "Orientation_Thickness_Extraction_Geol_Maps" routine is designed to automatically extract quantitative geometric informations from geological maps. The routine (A) first automatically extracts the top and base contacts of a specified lithostratigraphic unit. (B) A second script extracts the orientation along these contacts and estimates the stratigraphic thickness of the target unit at a given locality based on the automatically extracted orientation information. (C) Different numeric parameters are proposed to evaluate the reliability of the extracted orientation and thickness model output. An example input data set was added to the repository and helps to test and get used to the presented toolbox. For more information, see Nibourel et al. (submitted): *add doi here*

TECHNICAL REQUIREMENTS:

The routine is written and tested in Matlab (version 2021b). Therefore, Matlab must be installed to run the scripts.
The routine uses some third party functions from the TIE toolbox (Rauch et al. 2019) and the moment of inertia function (Fernandez, 2005).
References are given below. All necessary new and existing scripts are stored in the subfolder "1_used_functions" of this data repository.

INPUT DATA AND REQUIREMENTS:

The geological map vector data must be loaded in a projected coordinate system (typically a national projected system, CH1903+ / LV95, epsg: 2056 in the example data set), where the units are expressed in meters.
All input data must be loaded with the same projected coordinate system. It is recommended to work on one map sheet at once. This avoids mapsheet boundary effects and saves calculation time. Additionally, the filtering parameters might vary from map sheet to map sheet.
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

SUPPLEMENTARY INPUT DATA FOR OUTPUT VALIDATION AND VISUALISATION (USED IN THE EXAMPLE DATA SET)
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
ORGANISATION OF THE TOOLBOX:

The TIE-toolbox contains four folders and one master running script.

The folders are:

- LOADfunctions
	-> contains all functions that are needed to load the data and put the data in 
	   the TIE compatible format.
- TRACEfuntions
	-> contains all functions that are related to traces (and thus to the TIE)
	   to add/analyse information in a structural array
- GENERALfunctions
	-> contains all functions that are per se independent from trace or mapping
	   information -> mostly linear algebra functions
- TRACEvisualize
	-> contains all functions that are needed to visualise trace data

The script master.m allows to:

-> define the personal input data
-> load the data and perform the TIE
-> visualize results

	-> figure(1): map in 3d with traces and trace numbers
	-> figure(2): map in 3d with classified traces and chord plane bars
	-> figure(3): signals of alpha, beta and dist of a specific trace
	-> figure(4): chords and chord plane evolution of a specific trace in a stereonet
	-> figure(5): signal height diagram

    Make sure the TIE-toolbox with all its subfolders is registered as a Matlab search path.

EXAMPLE:

In the "Example Data" folder we propose a practical example in order to get used to TIE.

The data are presented and discussed in detail in Rauch et al. (2019): https://doi.org/10.1016/j.jsg.2019.06.007

The example data are already set as initial data set of the TIE-toolbox. Run the master in order to see the TIE results. If you wish to run your own data, just change the INPUT data in the master file.

ADVICE:

    Do not analyse a great zone at once. Firstly, the rasterizing function is not set up for a big amount of data and thus might be time consuming. In addition, the TIE is conceived for the detailed understanding of each individual trace. A large view of hundreds of traces is usually confusing and not helpful. We suggest to subdivide a bigger zone in smaller subzones containing 10 to 30 traces in a trace set.
    Save the loaded data (including the TRACE and FAULT structures) in a mat-file after the first run in order to avoid potentially time-consuming data-loading. The loading section in the master script can thereafter be skipped or commented.
    The TIE algorithm itself does not require the Mapping Toolbox. So if you do not have the Mapping Toolbox and do not want to purchase it, but would like to try out the TIE method on your data, there is the possibility to find somebody who has it, load the data and save them in a mat-file. If this somebody does not exist around you, contact me.

CONTACT:

Lukas Nibourel // ETH Zurich // lukas.nibourel@erdw.ethz.ch
