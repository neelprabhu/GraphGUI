function varargout = Displayer(varargin)
% DISPLAYER MATLAB code for Displayer.fig
%      DISPLAYER, by itself, creates a new DISPLAYER or raises the existing
%      singleton*.
%
%      H = DISPLAYER returns the handle to a new DISPLAYER or the handle to
%      the existing singleton*.
%
%      DISPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYER.M with the given input arguments.
%
%      DISPLAYER('Property','Value',...) creates a new DISPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Displayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Displayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Displayer_OpeningFcn, ...
    'gui_OutputFcn',  @Displayer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function Displayer_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for Displayer
handles.output = hObject;

% Lots of parameters, some unnecessary...

l = 17;                 % width of edge window
w = 25;                 % width of vertex window
alpha = 0.5;            % scaling edge cost contributions
interval = 1;           % merge vertices if distance is less or equal
spacing = 15;           % spacing of control points on splines
parallel = false;       % parallelization with parfor
verboseE = 0;           % verbose flag for edge optimization
verboseG = 0;           % verbose flag for vertex optimization
siftflow = true;        % SIFT flow flag
fname = ['tmp_grid2_', datestr(clock, 'mmddyy_HH:MM:SS')];
handles.options = struct('l',l,'w',w,'alpha',alpha,'interval',interval, ...
    'spacing',spacing,'parallel',parallel,'verboseE',verboseE, ...
    'verboseG',verboseG,'siftflow',siftflow,'fname',fname);

global ALL;
GT = imread('myGT.png');
handles.GT = padarray(GT, [20,20]);
handles.ALL = padarray(ALL, [20,20,0]);
[V,E,A,F] = embryoInitGraph(handles.GT,20,false);
handles.masterData = struct('VALL',{V},'EALL',{E},'ADJLIST',{A},'FACELIST',{F});
set(handles.frame,'String','1');

%% Code for tracking mouse movements and clicks

% Parameters into handles
handles.vertexIdx = -1; % No vertex selected default
handles.isAdd = 0; % Not adding element default
handles.addEdge = 0;
handles.zStX = 20; handles.zStoX = size(handles.ALL(:,:,1),2)-19;
handles.zStY = 20; handles.zStoY = size(handles.ALL(:,:,1),1)-19;
handles.prevVIdx = 1; handles.onV = false;
handles.prevEIdx = 1; handles.onE = false;
guidata(hObject,handles)

showGraph_Callback(handles.showGraph,eventdata,handles); % Initializes window
set(gca,'Visible','off') %Turns off axes

set(gcf, 'WindowButtonDownFcn', @selectPoint);
set(gcf, 'WindowButtonMotionFcn', @trackPoint);
set(gcf, 'WindowButtonUpFcn', @stopTracking);
set(gcf, 'KeyPressFcn', @buttonPress);

%% Sets up initial Voronoi diagram of vertices and edge midpoints

handles = guidata(hObject);
handles.vDT = setVVoronoi(handles);
handles.eDT = setEVoronoi(handles);
guidata(hObject,handles)

function selectPoint(hObject,eventdata) % When mouse is clicked
    
handles = guidata(hObject);
masterData = handles.masterData;
prelimPoint = get(gca,'CurrentPoint');
prelimPoint = prelimPoint(1,1:2);

if inpolygon(prelimPoint(1),prelimPoint(2), ...
        [handles.zStX handles.zStoX],[handles.zStY handles.zStoY])
    handles.cp = prelimPoint;
else
    return;
end

% Find nearest vertex and edge
[handles.vertexIdx,handles.vD] = nearestNeighbor(handles.vDT,handles.cp);
[handles.edgeIdx,handles.eD] = nearestNeighbor(handles.eDT,handles.cp);

% Adding vertex
if handles.isAdd
    next = size(masterData(1).VALL,1);
    masterData(1).VALL{next+1} = handles.cp;
    masterData(1).ADJLIST{next+1} = [];
    handles.vIndex = next+1;
    hold on;
    frame = str2double(get(handles.frame,'String'));
    [handles.vH, handles.eH, handles.cpH] = ...
        customdisplayGraph(handles.ALL(:,:,frame), ...
        masterData(frame).VALL, masterData(frame).EALL, 'on');
    set(gca, 'XLim', [handles.zStX handles.zStoX]);
    set(gca, 'YLim', [handles.zStY handles.zStoY]);
    handles.isAdd = 0; handles.masterData = masterData;
    handles.vDT = setVVoronoi(handles);
    guidata(hObject,handles)
    return;
end

if handles.addEdge == 1    
    handles.addE(1) = handles.vertexIdx;
    handles.addEdge = 2;
    display(handles.addE(1));
    guidata(hObject,handles)
end

if handles.addEdge == 2
    handles.addE(2) = handles.vertexIdx;
    handles.addEdge = 0;
    display(handles.addE(2));
    
    masterData = handles.masterData;
    
    k = 2; % Number of interior control points
    nctr = k + 2; % Number of control points
    mult = ones(1, nctr - 3);
    
    control = [masterData(1).VALL{handles.addE(1)}, ...
        masterData(1).VALL{handles.addE(1),1}+(masterData(1).VALL{handles.addE(2),1}-handles.masterData(1).VALL{handles.addE(1),1}).*(1/3), ...
        masterData(1).VALL{handles.addE(1),1}+(handles.masterData(1).VALL{handles.addE(2),1}-masterData(1).VALL{handles.addE(1),1}).*(2/3), ...
        masterData(1).VALL{handles.addE(2),1}];
    order = 3;
    open = true;
    n = 101;
    makeNeedles = false;
    
    s = splineMake(control, order, mult, open, n, makeNeedles);
    
    next = size(masterData(1).EALL,1);
    masterData(1).EALL{next+1} = s;
    
    tmp = [handles.addE(2);next+1];
    masterData(1).ADJLIST{handles.addE(1),1} = [masterData(1).ADJLIST{handles.addE(1),1},...
        tmp];
    tmp = [handles.addE(1);next+1];
    masterData(1).ADJLIST{handles.addE(2),1} = [masterData(1).ADJLIST{handles.addE(2),1},...
        tmp];
    frame = str2double(get(handles.frame,'String'));
    [handles.vH, handles.eH, handles.cpH] = ...
        customdisplayGraph(handles.ALL(:,:,frame), ...
        masterData(frame).VALL, masterData(frame).EALL, 'on');
    set(gca, 'XLim', [handles.zStX handles.zStoX]);
    set(gca, 'YLim', [handles.zStY handles.zStoY]);
    handles.addEdge = 0;
    handles.masterData = masterData;
    handles.eDT = setEVoronoi(handles);
    guidata(hObject,handles)
end

% Finds nearest edge and compare, change colors
[handles.edgeIdx,handles.eD] = nearestNeighbor(handles.eDT,handles.cp);
handles.vIndex = handles.vertexIdx;
handles.eIndex = handles.edgeIdx;
guidata(hObject,handles)

vProps = handles.vH{handles.vertexIdx};
vprevProps = handles.vH{handles.prevVIdx};
eProps = handles.eH{handles.edgeIdx};
eprevProps = handles.eH{handles.prevEIdx};
cProps = handles.cpH{handles.edgeIdx};
cprevProps = handles.cpH{handles.prevEIdx};

if handles.vD < handles.eD
    hold on;
    set(vprevProps,'MarkerEdgeColor','r','MarkerFaceColor','r')
    set(eprevProps,'Color','y')
    set(cprevProps,'Visible','off')
    set(vProps,'MarkerEdgeColor','g','MarkerFaceColor','g')
    handles.prevVIdx = handles.vertexIdx; % Sets previous vertex equal to current
    handles.onE = false; handles.onV = true;
else
    hold on;
    set(eprevProps,'Color','y')
    set(cprevProps,'Visible','off')
    set(vprevProps,'MarkerEdgeColor','r','MarkerFaceColor','r')
    set(eProps,'Color','g')
    set(cProps,'Visible','on')
    handles.prevEIdx = handles.edgeIdx;
    handles.onE = true; handles.onV = false;
end
guidata(hObject,handles)

function trackPoint(hObject,eventdata)
handles = guidata(hObject);
if handles.vertexIdx ~= -1 && handles.vD < handles.eD
    %move point here
    newcp = get(gca,'CurrentPoint');
    newcp = newcp(1, 1:2)';
    masterData = handles.masterData; %Gets the data struct
    masterData(1).VALL{handles.vertexIdx} = newcp;
    
    edge = masterData(1).ADJLIST{handles.vertexIdx};
    edgeSize = size(edge);
    for i = 1:edgeSize(2)
        splineNum = edge(2,i);
        spline1 = masterData(1).EALL{splineNum};
        splineIdx = 1;
        minn = 1000;
        controls = spline1.control;
        for j = 1: length(controls)
            spl = controls(:, j);
            subb = abs(spl(1) - masterData(1).VALL{handles.vertexIdx}(1)) + ...
                abs (spl(2) - masterData(1).VALL{handles.vertexIdx}(2));
            if subb < minn
                minn = subb;
                splineIdx = j;
            end          
        end
        
        controls(:,splineIdx) = newcp;
        masterData(1).EALL{splineNum}.control = controls;
        spline1 = updateSplineEndPts_A(spline1, controls(:,1), controls(:,length(controls)));
        spline1.handles = splineDraw(spline1);
        masterData(1).EALL{splineNum} = spline1;
%         spline1.d = splineEvalEven(spline1.d, true, true, spline1.image);
         redraw(spline1);
         
    end
    set(gca, 'XLim', [handles.zStX handles.zStoX])
    set(gca, 'YLim', [handles.zStY handles.zStoY])
    handles.masterData = masterData;
    guidata(hObject,handles);
    vH = handles.vH; vProp = vH{handles.vertexIdx};
    set(vProp,'XData',newcp(1),'YData',newcp(2))
end

function stopTracking(hObject,eventdata)
handles = guidata(hObject);
handles.vertexIdx = -1;
handles.vDT = setVVoronoi(handles);
guidata(hObject,handles)


    function s = redraw(s)
        splineDraw(s, s.handles);
%         if s.image
 %            title(matchQuality(s.d, s.gradImg))
%         end
    
function buttonPress(hObject,eventdata)
handles = guidata(hObject);
switch eventdata.Key
    case 'backspace' % if backspace is pressed
        newhandles = deleteVE(handles);
        guidata(hObject,newhandles)
    case 'n'
        handles.isAdd = 1;
        guidata(hObject,handles)
    otherwise % do nothing
end

function handles = deleteVE(handles)
if handles.onV
    index = handles.vIndex;
    set(handles.vH{index},'Visible','off')
    handles.masterData(1).VALL{index} = [NaN;NaN];
    adj = handles.masterData(1).ADJLIST{index}; % More deletions
    if isempty(adj)
        return;
    else
        vert = adj(1,:);
        edge = adj(2,:);
        handles.masterData(1).ADJLIST{index} = [NaN;NaN]; % Get rid of deleted vertex ADJLIST
        for n = 1:numel(edge)
            handles.masterData(1).EALL{edge(n)} = []; % Get rid of incident
            set(handles.eH{edge(n)},'Visible','off') % Edges visible off
            adjMatrix = handles.masterData(1).ADJLIST{vert(n)}; % Adjacent vertices' ADJLIST
            adjMatrix(:,find(adjMatrix(1,:) == index)) = []; % Delete the old entry
            handles.masterData(1).ADJLIST{vert(n)} = adjMatrix; % Reset
        end
    end
end
if handles.onE
    index = handles.eIndex;
    ctrlMatrix = handles.masterData(1).EALL{index}.control;
    vIndex1 = nearestNeighbor(handles.vDT,ctrlMatrix(:,1)');
    vIndex2 = nearestNeighbor(handles.vDT,ctrlMatrix(:,end)');
    adjMatrix1 = handles.masterData(1).ADJLIST{vIndex1};
    adjMatrix1(:,find(adjMatrix1(1,:) == vIndex2)) = []; 
    adjMatrix2 = handles.masterData(1).ADJLIST{vIndex2};
    adjMatrix2(:,find(adjMatrix2(1,:) == vIndex1)) = []; % Get rid of adjacencies
    handles.masterData(1).ADJLIST{vIndex1} = adjMatrix1;
    handles.masterData(1).ADJLIST{vIndex2} = adjMatrix2; % Reset
    set(handles.eH{index},'Visible','off')
    set(handles.cpH{index},'Visible','off')
    handles.masterData(1).EALL{index} = [];
end

% --- Outputs from this function are returned to the command line.
function varargout = Displayer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function showGraph_Callback(hObject, eventdata, handles)
% hObject    handle to showGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
mD = handles.masterData;
frame = str2double(get(handles.frame,'String'));
[handles.vH, handles.eH, handles.cpH] = ...
    customdisplayGraph(handles.ALL(:,:,frame), ...
    mD(frame).VALL, mD(frame).EALL, 'on');
set(gca, 'XLim', [handles.zStX handles.zStoX])
set(gca, 'YLim', [handles.zStY handles.zStoY])
guidata(hObject,handles)

function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame as text
%        str2double(get(hObject,'String')) returns contents of frame as a double
showRaw_Callback(hObject,eventdata,handles)


function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function add_element_Callback(hObject, eventdata, handles)
% hObject    handle to add_element (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.isAdd = ~handles.isAdd;
guidata(hObject,handles)


function showRaw_Callback(hObject, eventdata, handles)
% hObject    handle to showRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame = str2double(get(handles.frame,'String'));
imagesc(handles.ALL(:,:,frame));

function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function open_track_Callback(hObject, eventdata, handles)
% hObject    handle to open_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Starting frame:','Ending frame:'};
dlg_title = 'Tracking Options'; num_lines = 1; defaultans = {'1','2'};
handles = guidata(hObject);
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
sFrame = str2double(answer(1)); eFrame = str2double(answer(2));
[handles.masterData] = customMembraneTrack(handles.ALL, handles.GT, ...
    handles.options, handles.masterData,sFrame,eFrame);
guidata(hObject,handles)


% --- Executes on button press in add_edge.
function add_edge_Callback(hObject, eventdata, handles)
% hObject    handle to add_edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.addEdge = 1;
guidata(hObject,handles)


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
[file1, path1] = uigetfile({'*.mat';'*.*'}, 'Choose a pre-processed .mat file.');
data = load([path1,file1]);
handles.masterData = data.data;
[file2, path2] = uigetfile({'*.tif';'*.*'}, 'Choose a pre-processed .tif stack.');
stack = loadtiff([path2,file2]);
handles.ALL = padarray(stack, [20,20,0]);
guidata(hObject,handles)