function [data] = customMembraneTrack(ALL, options, preData,sFrame,eFrame)
%MEMBRANETRACK Track graph structure in image stream.
%
% INPUTS
% ALL: 3D image stack.
% GT: ground truth.
% options: options struct.
%
% CALLEE functions
%   embryoInitGraph
%   updateGraph
%   optIterGraph
%
% @author Roger Zou, edited by Neel K. Prabhu
% @date 8/15/15
l = 17; w = 25; alpha = 1; interval = 0; spacing = 20;
verboseE = false; verboseG = false; siftflow = true; parallel = false;
edgetype = 'A';
fname = ['tmp_', datestr(clock)];
if nargin==nargin('membraneTrack') && ~isempty(options)
    if any(strcmp('l',fieldnames(options)))
        l = options.l;
    end
    if any(strcmp('w',fieldnames(options)))
        w = options.w;
    end
    if any(strcmp('alpha',fieldnames(options)))
        alpha = options.alpha;
    end
    if any(strcmp('interval',fieldnames(options)))
        interval = options.interval;
    end
    if any(strcmp('spacing',fieldnames(options)))
        spacing = options.spacing;
    end
    if any(strcmp('verboseE',fieldnames(options)))
        verboseE = options.verboseE;
    end
    if any(strcmp('verboseG',fieldnames(options)))
        verboseG = options.verboseG;
    end
    if any(strcmp('parallel',fieldnames(options)))
        parallel = options.parallel;
    end
    if any(strcmp('siftflow',fieldnames(options)))
        siftflow = options.siftflow;
    end
    if any(strcmp('edgetype',fieldnames(options)))
        edgetype = options.edgetype;
    end
    if any(strcmp('fname',fieldnames(options)))
        fname = options.fname;
    end
end
if edgetype=='C' || edgetype=='D'
    ALL = max(ALL(:)) - ALL;
end

% optionally start parallel pool
if parallel && isempty(gcp('nocreate'))
    parpool
end

% set up some optimization structs
optOptions = struct('parallel',parallel,'verboseE',verboseE,'verboseG',verboseG,'siftflow',siftflow);
structC = struct('alpha',alpha,'l',l,'w', w,'interval',interval,'spacing',spacing);

% select edge type
if edgetype=='A'
    structD = getStructD_A;
elseif edgetype=='B'
    structD = getStructD_B;
elseif edgetype=='C'
    structD = getStructD_C;
elseif edgetype=='D'
    structD = getStructD_D;
else
    error('MEMBRANETRACK: invalid edgetype parameter');
end

VALL = cell(1, eFrame); EALL = cell(1, eFrame);
ADJLIST = cell(1, eFrame); FACELIST = cell(1, eFrame);
VALL{1} = preData(sFrame).VALL;
EALL{1} = preData(sFrame).EALL;
ADJLIST{1} = preData(sFrame).ADJLIST;
FACELIST{1} = preData(sFrame).FACELIST; % Allocate frame 1 data

for ii=(sFrame+1):eFrame
    
    disp('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    fprintf('Tracking images %d -> %d\n', ii-1, ii);
    tic
    
    % compute optimal graph
    I1 = ALL(:,:,ii-1);
    I2 = ALL(:,:,ii);
    
    % get image struct
	structA = struct('I1', {I1}, 'I2', {I2}, 'I2x', {grad(I2)});
    
	% update graph
    structUG = struct('I',{I1},'V',{VALL{ii-1}},'E',{EALL{ii-1}}, ...
        'adjList',{ADJLIST{ii-1}},'faceList',{FACELIST{ii-1}}); % Absorb data
    
    [ structUG ] = updateGraph(structUG, structC, structD, parallel);
    V = structUG.V;
    E = structUG.E;
    adjList = structUG.adjList;
    faceList = structUG.faceList;
    ADJLIST{ii} = adjList;
    FACELIST{ii} = faceList;
    
    % get graph struct
	structB = struct('V1', {V},'V2',{V},'E1',{E},'E2',{E},'E2new',{E},'adjList',{adjList});
    
	% find optimal graph
	[V, E, ~] = optIterGraph(structA, structB, structC, structD, optOptions);
    VALL{ii} = V;
    EALL{ii} = E;

	toc
    
end

data = struct('VALL',VALL,'EALL',EALL,'ADJLIST',ADJLIST,'FACELIST',FACELIST); % output everything.
end