% | ----------------------------------------------------------------------
% | --------------------- EXTRACT TOP AND BASE TRACES --------------------
% | ----------- AND STORE THEM IN THE STRUCTURE 'TRACE_BASE_TOP' ---------
% |  modified extract from A. Rauch's TIE toolbox, function extractTRACES
% | -------------------------- by Lukas Nibourel -------------------------
% | ----------------------------------------------------------------------

% TRACE EXTRACTION
% Extract bedrock interface traces and fault traces in an individual,
% sorted and oriented way
%
% ----------
% INPUT
% BED           -> matrix with Bedrock data (see loadBedrock and rasterizeBedrock)    
% TEC           -> matrix with data of tectonic boundaries(see loadTecto and rasterizeTecto)
%                  TEC and BED must be of the same size
% base_units    ->
% top_units     ->
% target_units  ->
%
% ----------
% OUTPUT
% TRACE_BASE_TOP  -> structure containing TRACE information
%                   -> TRACE.index    = index array of trace points within the
%                                       matrix. The order of indexes matter!
%                   -> TRACE.type     = type of trace (which bedrock type is it)
%                   -> TRACE.matrix   = matrix size of BED or TEC
% FAULT  -> structure containing FAULT information
%               -> FAULT.index    = index array of fault points within the
%                                   matrix. The order of indexes matter!
%               -> FAULT.type     = type of fault (thrust, normal fault...)
%               -> TRACE.matrix   = matrix size of BED or TEC



function [TRACE_BASE_TOP,FAULT] = extractTRACEnew(BED,TEC,base_units, top_units, target_units)

% EXTRACT FAULTS ---------------------------------------------------------
% (modified extract from A. Rauch's TIE toolbox, function extractTRACES)
cnX   = length(BED(:,1));
cnY   = length(BED(1,:));

% find pixels which are at the border to outcrops
Bfl             = flipud(BED);
Bb              = Bfl;
Bb(Bb>0)        = 1;
Bb(isnan(Bb))   = 0;
Bbp             = cell2mat(bwboundaries(Bb,4)); % positive border - inside of bedrock
if ~isempty(Bbp)
    Bbp         = sub2ind([cnX,cnY],Bbp(:,1),Bbp(:,2));
end

BbNeg           = imcomplement(Bb);
Bbn             = cell2mat(bwboundaries(BbNeg,4)); % negative border - outside of bedrock
if ~isempty(Bbn)
    Bbn         = sub2ind([cnX,cnY],Bbn(:,1),Bbn(:,2));
end

% remove all fault values within unconsolidated deposits - except of border pixels
Bfl([Bbp;Bbn])  = 5;
TEC(isnan(Bfl)) = NaN;

% individualize things
kind    = unique(TEC(TEC>0));
FAULT   = struct('index', [], 'type', [], 'matrix', []);

n = 1;
for r = 1:length(kind)
    tec                 = zeros(cnX,cnY);
    tec(TEC==kind(r))   = 1;
    brp                 = bwmorph(tec,'branchpoints');
    tec(brp)            = 0;

    CC = bwconncomp(tec);
    for k = 1:CC.NumObjects
        index = cell2mat(CC.PixelIdxList(k));
        if length(index) > 2
            FAULT(n).index  = index';
            FAULT(n).type   = kind(r);
            FAULT(n).matrix = size(TEC);
            n               = n+1;
        end
    end
end
FAULT = FAULT(1:n-1);

% eliminate small fault sticks
f   = zeros(length(FAULT),1);
for k = 1:length(FAULT)
    if length(FAULT(k).index) < 5
        f(k) = k;
    end
end
f   = f(f~=0);
FAULT(f) = [];

% Fault neighbors (needed for the TRACE extraction)
for i = 1:length(FAULT)
    index   = FAULT(i).index;
    N       = [];
    for j = 1:length(index)
        neigh   = neighborPoints8n(index(j),cnX,cnY);
        N       = [N,neigh'];
    end
    FAULT(i).neighbor = unique(N);
end

FAULT = sortTRACE(FAULT);

% IDENTIFY BASE TRACES ---------------------------------------------------
% (script is a modified extract from A. Rauch's TIE toolbox, function extractTRACES)
% ------------------------------------------------------------------------

trace  = zeros(size(BED));
ncell  = nnz(BED);

BED2                = BED;   % set borders values of trace matrix also to NaNs to avoid border complications
BED2(:,1)           = NaN;
BED2(1,:)           = NaN;
BED2(size(BED,1),:) = NaN;
BED2(:,size(BED,2)) = NaN;

% LN: create a new simplified bedrock matrix containing three values, 1 = base units, 2 = target_units, 3 = top_units, all other values are stored as NaNs
BED3 = BED2;        % duplicate matrix BED2

for r = 1:length(base_units)      % loop through the vector base_units
BED3(BED2==base_units(r)) = 1;    % replace all target unit values with a '1', leave the other matrix entries as they are
end

for r = 1:length(target_units)    % loop through the vector target_units
BED3(BED2==target_units(r)) = 2;  % replace all target unit values with a '2', leave the other matrix entries as they are
end

BED3(BED3>3) = NaN;               % replace all other values (outside the Helvetic stratigraphy, or non-defined) by NaNs

% EXTRACT BASE TRACES -----------------------------------------------------

for i = 1:ncell
    if ~isnan(BED3(i))                                          % do not take NaN's into consideration
        neigh   = neighborPoints4n(i,size(BED,1),size(BED,2));
        if any(BED3(neigh)~= BED3(i)& ~isnan(BED3(neigh)))      % find point, which does not have the same neighbour value and which is not a NaN
            trace(i) = BED3(i);
            if any(BED3(neigh)> BED3(i))                        % delete all double traces, which are part of the oldest unity (according to superposition)
                trace(i) = 0;
            end
        end
    end
end

if ~isempty(FAULT)                         % Delete bedrock boundaries that are actually Faults
    faultind    = vertcat(FAULT.index);
    fneighind   = [FAULT.neighbor]';
else
    faultind    = [];
    fneighind   = [];
end

fault               = zeros(size(BED,1),size(BED,2));
fault(faultind)     = 1;
fault(fneighind)    = 1;
fault               = flipud(fault);
trace(fault==1)     = 0;

trace(trace==0)     = NaN;                  % set all zero values to NaN;

% EXTRACT BASE TRACES (individualized) -----------------------------------

rocks  = unique(trace(trace>0));
TRACE_BASE  = struct('index', [], 'type', [], 'matrix', []);

n = 1;
for r = 1:length(rocks)

    tracer                  = zeros(size(trace)); % create new matrix to replace it with TIL-individual values
    tracer(trace==rocks(r)) = 1;
    tracer                  = flipud(tracer);

    CC  = bwconncomp(tracer);
    for k = 1:CC.NumObjects
        index = cell2mat(CC.PixelIdxList(k));
        if length(index)>2
            TRACE_BASE(n).index      = index;
            TRACE_BASE(n).type       = rocks(r);
            TRACE_BASE(n).matrix     = size(trace);
            n = n+1;
        end
    end
end
TRACE_BASE = TRACE_BASE(1:n-1);
TRACE_BASE = sortTRACE(TRACE_BASE);

% eliminate small traces
f = zeros(length(TRACE_BASE),1);
for k = 1:length(TRACE_BASE)
    if length(TRACE_BASE(k).index) < 5
        f(k) = k;
    end
end

% IDENTIFY TOP TRACES ----------------------------------------------------
% (script is a modified extract from A. Rauchs TIE toolbox, function extractTRACES)
% ------------------------------------------------------------------------

BED3 = BED2;                          % duplicate matrix BED2

for r = 1:length(target_units)        % loop through the vector target_units
BED3(BED2==target_units(r)) = 2;      % replace all target unit values with a '2', leave the other matrix entries as they are
end

for r = 1:length(top_units)           % loop through the vector top_units
BED3(BED2==top_units(r)) = 3;         % replace all target unit values with a '3', leave the other matrix entries as they are
end

BED3(BED3>3) = NaN;                   % replace all other values (outside the Helvetic stratigraphy, or non-defined) by NaNs

% EXTRACT TOP TRACES -----------------------------------------------------

for i = 1:ncell
    if ~isnan(BED3(i))                                          % do not take NaN's into consideration
        neigh   = neighborPoints4n(i,size(BED,1),size(BED,2));
        if any(BED3(neigh)~= BED3(i)& ~isnan(BED3(neigh)))      % find point, which does not have the same neighbour value and which is not a NaN
            trace(i) = BED3(i);
            if any(BED3(neigh)> BED3(i))                        % delete all double traces, which are part of the oldest unity (according to superposition)
                trace(i) = 0;
            end
        end
    end
end

if ~isempty(FAULT)                      % Delete bedrock boundaries that are actually Faults
    faultind    = vertcat(FAULT.index);
    fneighind   = [FAULT.neighbor]';
else
    faultind    = [];
    fneighind   = [];
end

fault               = zeros(size(BED,1),size(BED,2));
fault(faultind)     = 1;
fault(fneighind)    = 1;
fault               = flipud(fault);
trace(fault==1)     = 0;

trace(trace==0)     = NaN;               % set all zero values to NaN;

% EXTRACT TOP TRACES (individualized) ------------------------------------

rocks  = unique(trace(trace>0));
TRACE_BASE_TOP  = struct('index', [], 'type', [], 'matrix', []);

n = 1;
for r = 1:length(rocks)

    tracer                  = zeros(size(trace)); % create new matrix to replace it with TIL-individual values
    tracer(trace==rocks(r)) = 1;
    tracer                  = flipud(tracer);

    CC  = bwconncomp(tracer);
    for k = 1:CC.NumObjects
        index = cell2mat(CC.PixelIdxList(k));
        if length(index)>2
            TRACE_BASE_TOP(n).index      = index;
            TRACE_BASE_TOP(n).type       = rocks(r);
            TRACE_BASE_TOP(n).matrix     = size(trace);
            n = n+1;
        end
    end
end
TRACE_BASE_TOP = TRACE_BASE_TOP(1:n-1);
TRACE_BASE_TOP = sortTRACE(TRACE_BASE_TOP);

% eliminate small traces
f = zeros(length(TRACE_BASE_TOP),1);
for k = 1:length(TRACE_BASE_TOP)
    if length(TRACE_BASE_TOP(k).index) < 5
        f(k) = k;
    end
end

f           = f(f~=0);
TRACE_BASE_TOP(f)    = [];

end