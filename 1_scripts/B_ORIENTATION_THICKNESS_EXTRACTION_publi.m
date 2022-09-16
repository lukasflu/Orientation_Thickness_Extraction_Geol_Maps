% | -----------------------------------------------------------------------
% |
% | ------- EXTRACT LAYER THICKNESS FROM VECTORISED GEOLOGICAL MAP --------
% | --------- For more information see Nibourel et al. (submitted) --------
% | ---------------- Version: Lukas Nibourel, 09-14-2022 ------------------
% | ----- Update LN: reorganisation of output file to make sure every line 
% | ---------------- only contains one thickness value and the filtering --
% | ---------------- associated to its orientation information ------------
% | ----- Update LN: Two individual outputtables now contain orientation -- 
% | ---------------- and thickness model output and associated reliability 
% | ---------------- indocators -------------------------------------------
% | -----------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ----------------- FILE B: LAYER THICKNESS EXTRACTION ------------------
% | -----------------------------------------------------------------------

%% LOAD WORKSPACE ---------------------------------------------------------
% put workspace directly
%cd(inputpath); % contains input files which can be used for all map sheets are saved in this folder
load([savePath 'workspace_input_TIE.mat']);

%%%*** to be deleted inserted just for temporal use, this was fixed in extractTRACEnew
%%(part of step A), and insures that in the future, all tracess with less
%%than 5 xyz points are eliminated already in step A -> path to corrected
%%extractTRACEnew file: C:\Users\lukasflu\Dropbox\00_FGS\02data\02_thickness_estimation\02_thickness_eval_TIE_intertia_functions\HSTfunctions

% % eliminate small traces
% f = zeros(length(TRACE_BASE_TOP),1);
% for k = 1:length(TRACE_BASE_TOP)
%     if length(TRACE_BASE_TOP(k).index) < 5
%         f(k) = k;
%     end
% end
% 
% f           = f(f~=0);
% TRACE_BASE_TOP(f)    = [];
% %%%*** to be deleted end



% | -----------------------------------------------------------------------
% | --------------------- LAYER THICKNESS EXTRACTION ----------------------
% | -----------------------------------------------------------------------

%% PREPARE BASE AND TOP XYZ POINT CLOUDS FOR THICKNESS EXTRACTION ---------
% select all top and all base trace lines seperately: https://ch.mathworks.com/matlabcentral/answers/120580-finding-structure-array-entries-with-certain-values
GeolCodes = [TRACE_BASE_TOP.type];                                         % 2 = base, 3 = top

X_ind = repmat(X,numel(Y),1);                                              % load and establish a linear indexing matrix for the space x y
Y_ind = repmat(Y,1,numel(X));

for i = 1:numel(GeolCodes)                                                 % loop through all trace segments and extract indices and orientation information
  trace_ind{i} = TRACE_BASE_TOP(i).index(:);
  SegmentsXYZ{i} = [X_ind(trace_ind{i}), Y_ind(trace_ind{i}), Z(trace_ind{i})];
end

%% PREPARE A MOVING WINDOW MATRIX FOR EXTRACTION OF ORIENTATION DATA ------
% maximum length is given in A_INPUT_TIE (MovingWindowMaximumLength)

MovingWindow=[];

for i = 1:numel(GeolCodes)
  MovingWindowLength_flex(i) = round(numel(SegmentsXYZ{i}(:,1))/2)-1;
  if MovingWindowLength_flex(i) > MovingWindowMaximumLength
    MovingWindowLength_flexible(i) = MovingWindowMaximumLength;
  else
    MovingWindowLength_flexible(i) = MovingWindowLength_flex(i);
  end

  for j = 1:numel(SegmentsXYZ{i}(:,1))-MovingWindowLength_flexible(i)
    MovingWindow{1,i}(j,:) = [j:j+MovingWindowLength_flexible(i)];
  end
end

%% RUN INERTIA FUNCTION TO FIND BEST FIT PLANES ALONG MOVING WINDOW -------

for i = 1:numel(GeolCodes)
%  for j = 1:numel(SegmentsXYZ{1,i}(:,1))-MovingWindowLength+1                     % uncomment for fixed segment length
%  for j = 1:MovingWindowLength_flexible(i)

  for j = 1:numel(SegmentsXYZ{i}(:,1))-MovingWindowLength_flexible(i)

    [Dir{1,i}(j,:),M{1,i}(j,:),K_value{1,i}(j,:)] = inertia(SegmentsXYZ{1,i}(MovingWindow{1,i}(j,:),:));

%    xyzOrientationData{1,i}(j,:) = SegmentsXYZ{1,i}(MovingWindow{1,i}(j,round(MovingWindowLength/2)),:);                 % uncomment for fixed MovingWidthLength
    xyzOrientationData{1,i}(j,:) = SegmentsXYZ{1,i}(MovingWindow{1,i}(j,round(MovingWindowLength_flexible(i)/2)),:);

  end
end

%% POINT CLOUDS FOR NEAREST NEIGHBOR SEARCH/THICKNESS EXTRACTION ----------

% select all top and all base trace lines seperately: https://ch.mathworks.com/matlabcentral/answers/120580-finding-structure-array-entries-with-certain-values
% start with base traces
base_hor = GeolCodes == 2;                                                 % select all base traces
base_trace_fields = find(base_hor);                                        % indices for base trace segments in the TOP_BASE_TRACE structure

xyzOrientationDataBase = cell(1,numel(base_trace_fields));

for i = 1:numel(base_trace_fields)                                         % loop through all base segments
  xyzOrientationDataBase{i} = xyzOrientationData{1,i};
end

% remove all cell elements shorter than 1 (required for cell2mat conversion) -> https://ch.mathworks.com/matlabcentral/answers/386219-remove-cell-array-content-with-condition-length-of-element-in-cell-smaller-than-specific-value
xyzOrientationDataBase = xyzOrientationDataBase(cellfun('length',xyzOrientationDataBase)>=1);

pointsxyz_base = cell2mat(transpose(xyzOrientationDataBase));
ptCloud_base = pointCloud(pointsxyz_base);

% same operation for top traces
top_hor = GeolCodes == 3;                                                  % select all top traces
top_trace_fields = find(top_hor);                                          % indices for top trace segments in the TOP_BASE_TRACE structure

xyzOrientationDataTop = cell(1,numel(top_trace_fields));

for m = top_trace_fields                                                   % loop through all top segments
  xyzOrientationDataTop{m} = xyzOrientationData{1,m};
end

xyzOrientationDataTop = xyzOrientationDataTop(cellfun('length',xyzOrientationDataTop)>=1);
pointsxyz_top = cell2mat(transpose(xyzOrientationDataTop));
ptCloud_top = pointCloud(pointsxyz_top);


NormalVectorBase = cell(1,numel(base_trace_fields));

for i = base_trace_fields                                                  % loop through all base segments
  NormalVectorBase{i} = Dir{1,i};
end

NormalVectorBase = NormalVectorBase(cellfun('length',NormalVectorBase)>=1);
Dir_Base = cell2mat(transpose(NormalVectorBase));


NormalVectorTop = cell(1,numel(top_trace_fields));

for m = top_trace_fields                                                   % loop through all base segments
  NormalVectorTop{m} = Dir{1,m};
end

NormalVectorTop = NormalVectorTop(cellfun('length',NormalVectorTop)>=1);
Dir_Top = cell2mat(transpose(NormalVectorTop));

%% NEAREST NEIGHBOR SEARCH ------------------------------------------------
% use nearest neighbor search and dot product to estimate layer thickness:
%   https://ch.mathworks.com/matlabcentral/answers/371665-distance-from-point-to-plane-plane-was-created-from-3d-point-data

K=1;      % K = 1 outputs points

n_top = numel(pointsxyz_top(:,1));
n_base = numel(pointsxyz_base(:,1));


%% FIND NEAREST NEIGHBOR TO EACH TOP TRACE POINT --------------------------
% find nearest neighbor to each top trace point with orientation
% information (inertia output)

for i = 1:n_top
  [indices(i),dists(i)] = findNearestNeighbors(ptCloud_base,pointsxyz_top(i,:),K);         % find nearest neighbor point on base for each TOP x y z coordinate!

  P(i,:) = pointsxyz_base(indices(i),:);                                                   % X Y Z nearest neighbor point on base trace, re-use index number from nearest neighbor calculation
  Q(i,:) = pointsxyz_top(i,:);                                                             % X Y Z point Q on top trace
  V(:,i) = transpose(P(i,:) - Q(i,:));                                                     % (x1-x0, y1-y0, z1-z0), define vector V between Q confined to be on the plane, P the point for which we would like to calculate the distance to the plane
  thickness_raw(i) = dot(V(:,i),Dir_Top(i,:));                                             % dot product corresponds to the horizon thickness estimate, the value can be positive or negative, which indicates on which side of the plane point P is (which is used to plot the vector below)
  thickness(i) = abs(dot(V(:,i),Dir_Top(i,:)));                                            % absolute value of the dot product corresponds to the layer thickness D, this value is to be plotted in the output table (where we do not want to see negative thicnkess values)
  P0(i,:) = P(i,:)-Dir_Top(i,:)*thickness_raw(i);                                          % end point of thickness vector on plane Dir_Top going through point P

  % same calculation with orientation information of ne base trace

  V2(:,i) = transpose(Q(i,:) - P(i,:));                                                    % (x1-x0, y1-y0, z1-z0), define vector V between Q confined to be on the plane, P the point for which we would like to calculate the distance to the plane
  thickness_raw2(i) = dot(V2(:,i),Dir_Base(indices(i),:));                                 % dot product corresponds to the horizon thickness estimate, the value can be positive or negative, which indicates on which side of the plane point P is (which is used to plot the vector below)
  thickness2(i) = abs(dot(V2(:,i),Dir_Base(indices(i),:)));                                % absolute value of the dot product corresponds to layer thickness D', this value is to be plotted in the output table (where we do not want to see negative thicnkess values)
  Q0(i,:) = Q(i,:)-Dir_Base(indices(i),:)*thickness_raw2(i);                               % end point of thickness vector

  % prepare data for output matrix
  xyz_thickness(i,:) = (P(i,:) + Q(i,:))/2;                                                % x y z of a point between P and Q (mean)

  distance_PQ(i,:) = sqrt((P(i,1)-Q(i,1))^2 + (P(i,2)-Q(i,2))^2 + (P(i,3)-Q(i,3))^2);      % distance between P and its nearest neighbor Q

end

% READ OUT GeolCode AT CENTRAL X Y Of D AND D' ----------------------------
% use min(abs()) to get the nearest X Y coordinates of the BED matrix,
%   note that X and Y axes are inversed in BED: https://ch.mathworks.com/matlabcentral/answers/152301-find-closest-value-in-array

% comment LN, 2020-12-11 -> move this block down and do the opperations in one batch?

X_xyz_thickness = xyz_thickness(:,1);
X_rep = repmat(X,numel(X_xyz_thickness),1);
[XminValue,XclosestIndex] = min(abs(transpose(X_rep-X_xyz_thickness)));                   % XclosestIndex contains the indices of the nearest values in X at every X_xzy_thickness position

Y_xyz_thickness = xyz_thickness(:,2);
Y_flip = flipud(Y);                                                                       % this is needed because the Y vector starts with the highest Y value in the topright corner in map view, while the BED matrix starts in the lower left corner of a map view with the lowest Y and X values (in inverted position BED(Y,X))
Y_rep = repmat(transpose(Y_flip),numel(Y_xyz_thickness),1);
[YminValue,YclosestIndex] = min(abs(transpose(Y_rep-Y_xyz_thickness)));                   % YclosestIndex contains the indices of the nearest values in X at every X_xzy_thickness position


for i = 1:n_top
  GeolCode(i) = BED(YclosestIndex(i),XclosestIndex(i));
  thicknessDiff(i) = abs(thickness(i)-thickness2(i))/max(thickness(i),thickness2(i));     % relative thickness difference (must be lower than 0.1)
  AngularDiffN(i) = rad2deg(atan2(norm(cross(Dir_Top(i,:),Dir_Base(indices(i),:))), dot(Dir_Top(i,:),Dir_Base(indices(i),:))));     % calculate angular difference between normal vectors of P and Q
  if AngularDiffN(i) > 90
    AngularDiffN(i) = 180-AngularDiffN(i);      %* correct values if > 90°
  end
end


%% FIND NEAREST NEIGHBOR TO EACH BASE TRACE POINT -------------------------
% find nearest neighbor to each base trace point with orientation
% information (inertia output)

for j = 1:n_base
  [indicesR(j),distsR(j)] = findNearestNeighbors(ptCloud_top,pointsxyz_base(j,:),K);        % find nearest neighbor on top trace for each base trace point

  PR(j,:) = pointsxyz_top(indicesR(j),:);                                                   % X Y Z nearest neighbor point on top trace, re-use index number from nearest neighbor calculation
  QR(j,:) = pointsxyz_base(j,:);                                                            % X Y Z point Q on base trace
  VR(:,j) = transpose(QR(j,:) - PR(j,:));                                                   % (x1-x0, y1-y0, z1-z0), define vector V between Q confined to be on the plane, P the point for which we would like to calculate the distance to the plane
  thickness_rawR(j) = dot(VR(:,j),Dir_Base(j,:));                                           % dot product corresponds to the horizon thickness estimate, the value can be positive or negative, which indicates on which side of the plane point P is (which is used to plot the vector below)
  thicknessR(j) = abs(dot(VR(:,j),Dir_Base(j,:)));                                          % absolute value of the dot product corresponds to layer thickness DR, this value is to be plotted in the output table (where we do not want to see negative thicnkess values)
  P0R(j,:) = PR(j,:)+Dir_Base(j,:)*thickness_rawR(j);                                       % end point of thickness vector on plane Dir_Base going through point PR

  % same calculation in opposite direction, calculate DR'

  V2R(:,j) = transpose(PR(j,:) - QR(j,:));                                                  % (x1-x0, y1-y0, z1-z0), define vector V between Q confined to be on the plane, P the point for which we would like to calculate the distance to the plane
  thickness_raw2R(j) = dot(V2R(:,j),Dir_Top(indicesR(j),:));                                % dot product corresponds to the horizon thickness estimate, the value can be positive or negative, which indicates on which side of the plane point P is (which is used to plot the vector below)
  thickness2R(j) = abs(dot(V2R(:,j),Dir_Top(indicesR(j),:)));                               % absolute value of the dot product corresponds to laye thickness DR', this value is to be plotted in the output table (where we do not want to see negative thicnkess values)
  Q0R(j,:) = QR(j,:)+Dir_Top(indicesR(j),:)*thickness_raw2R(j);                             % end point of thickness vector

  % prepare data for output matrix
  xyz_thicknessR(j,:) = (PR(j,:) + QR(j,:))/2;                                              % x y z of a point between P and Q (mean)

  distance_PQR(j,:) = sqrt((PR(j,1)-QR(j,1))^2 + (PR(j,2)-QR(j,2))^2 + (PR(j,3)-QR(j,3))^2);  % distance between P and its nearest neighbor Q

end


%% READ OUT GeolCode AT CENTRAL X Y Of DR AND DR' -------------------------
% use min(abs()) to get the nearest X Y coordinates of the BED matrix,
%   note that X and Y axes are inversed in BED: https://ch.mathworks.com/matlabcentral/answers/152301-find-closest-value-in-array


X_xyz_thicknessR = xyz_thicknessR(:,1);
X_repR = repmat(X,numel(X_xyz_thicknessR),1);
[XminValueR,XclosestIndexR] = min(abs(transpose(X_repR-X_xyz_thicknessR)));               % XclosestIndex contains the indices of the nearest values in X at every X_xzy_thickness position

Y_xyz_thicknessR = xyz_thicknessR(:,2);
Y_flip = flipud(Y);                                                                       % this is needed because the Y vector starts with the highest Y value in the topright corner in map view, while the BED matrix starts in the lower left corner of a map view with the lowest Y and X values (in inverted position BED(Y,X))
Y_repR = repmat(transpose(Y_flip),numel(Y_xyz_thicknessR),1);
[YminValueR,YclosestIndexR] = min(abs(transpose(Y_repR-Y_xyz_thicknessR)));               % YclosestIndex contains the indices of the nearest values in X at every X_xzy_thickness position


for j = 1:n_base
  GeolCodeR(j) = BED(YclosestIndexR(j),XclosestIndexR(j));
  thicknessDiffR(j) = abs(thicknessR(j)-thickness2R(j))/max(thicknessR(j),thickness2R(j));     % relative thickness difference (must be lower than 0.1)
  AngularDiffNR(j) = rad2deg(atan2(norm(cross(Dir_Base(j,:),Dir_Top(indicesR(j),:))), dot(Dir_Base(j,:),Dir_Top(indicesR(j),:))));
  if AngularDiffNR(j) > 90
    AngularDiffNR(j) = 180-AngularDiffNR(j);      % correct values > 90°
  end
end

% | -----------------------------------------------------------------------
% | -----------------% END LAYER THICKNESS EXTRACTION %--------------------
% | -----------------------------------------------------------------------


%% PREPARE VECTOR field_numbers FOR OURPUTMATRIX --------------------------

top_segment_nrs = 1:numel(NormalVectorTop);
top_segment_numbers = cell(1,numel(top_segment_nrs));

for i = 1:numel(top_segment_nrs)
  top_segment_numbers{i} = repmat(top_segment_nrs(i), numel(NormalVectorTop{1,i}(:,1)), 1);
end

top_segment_numbers_mat = cell2mat(transpose(top_segment_numbers))+numel(NormalVectorBase);                   % combine vectors from cell into one matrix (respectively vector)


base_segment_nrs = 1:numel(NormalVectorBase);
base_segment_numbers = cell(1,numel(base_segment_nrs));

for i = 1:numel(base_segment_nrs)
  base_segment_numbers{i} = repmat(base_segment_nrs(i), numel(NormalVectorBase{1,i}(:,1)), 1);
end

base_segment_numbers_mat = cell2mat(transpose(base_segment_numbers));                                          % combine vectors from cell into one matrix (respectively vector)

% |------------------------------------------------------------------------
% |-- ADD M, K, values evaluating the goodness of orientation inf.  --
% |------------------------------------------------------------------------

%% ADD M AND K VALUES EVALUATING GOODNESS OF PLANAR FIT -------------------
number_of_base_elements = numel(base_segment_numbers_mat);
number_of_top_elements = numel(top_segment_numbers_mat);

M_mat = cell2mat(transpose(M));                                            % M reflects the co-planarity of nodes (Fernandez, 2005)
M_mat_top = M_mat(number_of_base_elements+1:end);
M_mat_base = M_mat(1:number_of_base_elements);

K_mat = cell2mat(transpose(K_value));                                      % K reflects the co-linearity of nodes (Fernandez, 2005)
K_mat_top = K_mat(number_of_base_elements+1:end);
K_mat_base = K_mat(1:number_of_base_elements);


%% ADD M AND K VALUES EVALUATING GOODNESS OF PLANA FIT --------------------
% prepare matrix containing the number of elements of each segment in the dip cell
for i = 1:numel(top_segment_nrs)
  top_segment_numbers{i} = numel(NormalVectorTop{1,i}(:,1));
end

for i = 1:numel(base_segment_nrs)
  base_segment_numbers{i} = numel(NormalVectorBase{1,i}(:,1));
end

top_base_segment_nmbrs = [base_segment_numbers top_segment_numbers];
top_base_segment_numbers = cell2mat(top_base_segment_nmbrs);

% read out segment length from TIE output
top_base_trace_fields = [base_trace_fields top_trace_fields];                     % vector contains all top and base traces

% ha = cell(1,numel(top_base_segment_numbers));                  % h(alpha) = TRACE_BASE_TOP(l).Segment.signalheight(1)
% hb = cell(1,numel(top_base_segment_numbers));                  % h(beta) = TRACE_BASE_TOP(l).Segment.signalheight(2)
% stability_values = cell(1,numel(top_base_segment_numbers));    % stability index after Rauch et al. (2019), one value per segment/trace
% planarity_values = cell(1,numel(top_base_segment_numbers));    % planarity index after Rauch et al. (2019), one value per segment/trace
% stability_val = cell(1,numel(top_base_segment_numbers));
% planarity_val = cell(1,numel(top_base_segment_numbers));
segment_len = cell(1,numel(top_base_segment_numbers));
segment_length = cell(1,numel(top_base_segment_numbers));

for l = 1:numel(top_base_segment_numbers)
%   ha{l} = TRACE_BASE_TOP(l).Segment.signalheight(1);
%   hb{l} = TRACE_BASE_TOP(l).Segment.signalheight(2);
%   stability_values{l} = hb{l} / ha{l};         % s = hb/ha
%   planarity_values{l} =ha{l}/2 + hb{l}/2 - (ha{l}^2 - 2*ha{l}*hb{l} + hb{l}^2 + 720)^(1/2)/2;  % output from solver: see also 20210205-planarity-index-problem-Rauch2020.txt
%   stability_val{l} = repmat(stability_values{l}, top_base_segment_numbers(l), 1);
%   planarity_val{l} = repmat(planarity_values{l}, top_base_segment_numbers(l), 1);
  segment_len{l} = numel(TRACE_BASE_TOP(l).index);
  segment_length{l} = repmat(segment_len{l}, top_base_segment_numbers(l), 1);
end

% stability_values_mat = cell2mat(transpose(stability_val));
% planarity_values_mat = cell2mat(transpose(planarity_val));
segment_length_mat = cell2mat(transpose(segment_length));

% |------------------------------------------------------------------------
% |-- end M, K, P, S values evaluating the goodness of orientation inf.  --
% |------------------------------------------------------------------------

% |------------------------------------------------------------------------
% |------------- WRITE OUTPUT TXT FILE and SAVE WORKSPACE------------------
% |------------------------------------------------------------------------

%% CREATE ORIENTATION OUTPUTTABLE -----------------------------------------

% prepare data for storage in orientation outputtable
XYZ_CooOrientTop = cell2mat(transpose(xyzOrientationDataTop));
XYZ_CooOrientBase = cell2mat(transpose(xyzOrientationDataBase));

% calculate dip-direction and dip from normal vector Dip (top)
for i = 1:numel(Dir_Top(:,1))

    [tr_N_top(i),pl_N_top(i)] = vect2angle(Dir_Top(i,:));

    if tr_N_top(i) >= 180
        azi_top(i) = tr_N_top(i)-180;
    else
        azi_top(i) = tr_N_top(i)+180;
    end
end

dip_top = abs(pl_N_top-90);

% calculate dip-direction and dip from normal vector Dip (base)
for i = 1:numel(Dir_Base(:,1))

    [tr_N_base(i),pl_N_base(i)] = vect2angle(Dir_Base(i,:));

    if tr_N_base(i) >= 180
        azi_base(i) = tr_N_base(i)-180;
    else
        azi_base(i) = tr_N_base(i)+180;
    end
end

dip_base = abs(pl_N_base-90);

% write orientation outputtable for top traces
output_orientationdata_top = transpose([...
        transpose(XYZ_CooOrientTop(:,1));...
        transpose(XYZ_CooOrientTop(:,2));...
        transpose(XYZ_CooOrientTop(:,3));...
        transpose(Dir_Top(:,1));...
        transpose(Dir_Top(:,2));...
        transpose(Dir_Top(:,3));...
        azi_top;...
        dip_top;...
        transpose(M_mat_top);...
        transpose(K_mat_top);...
        transpose(top_segment_numbers_mat);...
        transpose(segment_length_mat(numel(base_segment_numbers_mat)+1:end))]);                                                        % transpose matrices to consistent format

% write orientation outputtable for top traces
output_orientationdata_base = transpose([...
        transpose(XYZ_CooOrientBase(:,1));...
        transpose(XYZ_CooOrientBase(:,2));...
        transpose(XYZ_CooOrientBase(:,3));...
        transpose(Dir_Base(:,1));...
        transpose(Dir_Base(:,2));...
        transpose(Dir_Base(:,3));...
        azi_base;...
        dip_base;...
        transpose(M_mat_base);...
        transpose(K_mat_base);...
        transpose(base_segment_numbers_mat);...
        transpose(segment_length_mat(1:numel(base_segment_numbers_mat)))]);                                                        % transpose matrices to consistent format

% CREATE THICKNESS OUTPUTTABLE
outputtable_orientation = [output_orientationdata_top; output_orientationdata_base];                                                 % consider all elements!
% outputmatrix = [outputmatrix_top; outputmatrix_base(n_base2,:)];                                    % from outputmatrix_base, only PQ pairs which were not previously considered in the outputmatrix_top section are considered!
% savePath = 'C:\Users\lflue\Dropbox\00_FGS\02data\02_thickness_estimation\1_test_kk_blatt-adelboden\2_output\';
fileID = fopen([savePath 'output_orientation_unfiltered.txt'],'w');
fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'X','Y','Z','Dir_X','Dir_Y','Dir_Z','Dip_Direction','Dip',...
        'M','K','T','n(T)');                                                                     % add HeaderLines
fprintf(fileID,'%.7g %.7g %.4g %.4f %.4f %.4f %.2f %.2f %.2f %.2f %d %d \r\n',transpose(outputtable_orientation));                                                                                                                                                      % transpose in order to read the array in the correct order
fclose(fileID);

%% CREATE THICKNESS OUTPUTTABLE -------------------------------------------

% read out values to nearest neighbor point
indices_top_nearest_neighbors = indicesR+numel(indicesR);                         % plots the indices of the nearest neighbor top row in outputmatrix compatible format

%%%*** LN: 2022-06-20, 7 not necessary fields removed,
% orientation information (DIR, or dip, dipazimuth) fields have to be added
% prepare outputmatrix for the top and base trace results
% n_base2 = setdiff((1:n_base),indices);                                                              % n_base2 contains all matrix elements except the ones previously used in indices, this has to be done to avoid duplicate thickness values !!
output_top_thickness1 = transpose([...
        transpose(xyz_thickness(:,1));...
        transpose(xyz_thickness(:,2));...
        transpose(xyz_thickness(:,3));...
        thickness;...
%        thickness2;...
        transpose(M_mat_top);...
        transpose(K_mat_top);...
        thicknessDiff;...
        AngularDiffN;...
        transpose(distance_PQ);...
        transpose(top_segment_numbers_mat);...
        transpose(segment_length_mat(numel(base_segment_numbers_mat)+1:end));...
        transpose(base_segment_numbers_mat(indices));...
        GeolCode]);                                                        % transpose matrices to consistent format

output_top_thickness2 = transpose([...
        transpose(xyz_thickness(:,1));...
        transpose(xyz_thickness(:,2));...
        transpose(xyz_thickness(:,3));...
%        thickness;...
        thickness2;...
        transpose(M_mat_base(indices));...
        transpose(K_mat_base(indices));...
        thicknessDiff;...
        AngularDiffN;...
        transpose(distance_PQ);...
        transpose(base_segment_numbers_mat(indices));...
        transpose(segment_length_mat(indices));...
        transpose(top_segment_numbers_mat);...
        GeolCode]);                                                        % transpose matrices to consistent format

output_base_thickness1 = transpose([...
        transpose(xyz_thicknessR(:,1));...
        transpose(xyz_thicknessR(:,2));...
        transpose(xyz_thicknessR(:,3));...
        thicknessR;...
%        thickness2R;...
        transpose(M_mat_base);...
        transpose(K_mat_base);...
        thicknessDiffR;...
        AngularDiffNR;...
        transpose(distance_PQR);...
        transpose(base_segment_numbers_mat);...
        transpose(segment_length_mat(1:numel(base_segment_numbers_mat)));...
        transpose(top_segment_numbers_mat(indicesR));...
        GeolCodeR]);                                                       % transpose matrices to consistent format

output_base_thickness2 = transpose([...
        transpose(xyz_thicknessR(:,1));...
        transpose(xyz_thicknessR(:,2));...
        transpose(xyz_thicknessR(:,3));...
%        thicknessR;...
        thickness2R;...
        transpose(M_mat_top(indicesR));...
        transpose(K_mat_top(indicesR));...
        thicknessDiffR;...
        AngularDiffNR;...
        transpose(distance_PQR);...
        transpose(top_segment_numbers_mat(indicesR));...
        transpose(segment_length_mat(indices_top_nearest_neighbors));...
        transpose(base_segment_numbers_mat);...
        GeolCodeR]);                                                       % transpose matrices to consistent format

outputtable_thickness = [output_top_thickness1; output_top_thickness2; output_base_thickness1; output_base_thickness2];                                                 % consider all elements!
% outputmatrix = [outputmatrix_top; outputmatrix_base(n_base2,:)];                                    % from outputmatrix_base, only PQ pairs which were not previously considered in the outputmatrix_top section are considered!
% savePath = 'C:\Users\lflue\Dropbox\00_FGS\02data\02_thickness_estimation\1_test_kk_blatt-adelboden\2_output\';
fileID = fopen([savePath 'output_thickness_unfiltered.txt'],'w');
fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s\n',...
        'X','Y','Z','thickness','M','K','thicknessDiff','AngularDiffN','distance_PQ','T1','n(T1)',...
        'T2','GeolCode');                                                                     % add HeaderLines
fprintf(fileID,'%.7g %.7g %.4g %.0f %.2f %.2f %.2f %.3f %.0f %d %d %d %d \r\n',transpose(outputtable_thickness));                                                                                                                                                      % transpose in order to read the array in the correct order
fclose(fileID);


% structure of outputmatrix with indices for overview:
% X(1), Y(2), Z(3), Thickness1(4), M(5), K(6), ThicknessDiff(7), AngularDiffN(8), DistancePQ(9), SN1 (10), SN1Length(11), NeighboringSegmentNumber(12), GeolCode(13)

% |------------------------------------------------------------------------
% |-------------------%  END WRITE OUTPUT TXT FILE %-----------------------
% |------------------------------------------------------------------------

% | -----------------------------------------------------------------------
% | ------------------------- save to workspace ---------------------------
% | -----------------------------------------------------------------------

save([savePath 'workspace_thickness_extraction']);

% | ------------------------ % END FILE B %--------------------------------