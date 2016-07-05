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

% Get masterData, initialize
global getOUT;
global ALL;
handles.masterData = transfer(getOUT);
set(handles.frame,'String','1');

%% Code for tracking mouse movements and clicks

% Parameters into handles
handles.vertexIdx = -1; % No vertex selected default
handles.isAdd = 0; % Not adding element default
handles.zStX = 20; handles.zStoX = size(ALL(:,:,1),2)-19;
handles.zStY = 20; handles.zStoY = size(ALL(:,:,1),1)-19;
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
global ALL;
    
handles = guidata(hObject);
masterData = handles.masterData;
prelimPoint = get(gca,'CurrentPoint');
prelimPoint = prelimPoint(1,1:2);

if prelimPoint(1) > 20 && prelimPoint(2) > 20
    handles.cp = prelimPoint;
else
    return;
end

if handles.isAdd
    next = size(masterData(1).VALL,1);
    masterData(1).VALL{next+1} = handles.cp;
    masterData(1).ADJLIST{next+1} = [];
    handles.vIndex = next+1;
    hold on;
    [handles.vH, handles.eH, handles.cpH] = customdisplayGraph(ALL(:,:,1), masterData(1).VALL,  ...
        masterData(1).EALL, 'on');
    set(gca, 'XLim', [handles.zStX handles.zStoX]);
    set(gca, 'YLim', [handles.zStY handles.zStoY]);
    handles.isAdd = 0; handles.masterData = masterData;
    handles.vDT = setVVoronoi(handles);
    guidata(hObject,handles)
    return;
end

% Finds nearest vertex
[handles.vertexIdx,handles.vD] = nearestNeighbor(handles.vDT,handles.cp);
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
    handles.prevVIdx = handles.vertexIdx; %Sets previous vertex equal to current
    handles.onE = false;
    handles.onV = true;
    guidata(hObject,handles)
else
    hold on;
    set(eprevProps,'Color','y')
    set(cprevProps,'Visible','off')
    set(vprevProps,'MarkerEdgeColor','r','MarkerFaceColor','r')
    set(eProps,'Color','g')
    set(cProps,'Visible','on')
    handles.prevEIdx = handles.edgeIdx;
    handles.onE = true;
    handles.onV = false;
    guidata(hObject,handles)
end

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
global ALL;
if handles.onV
    index = handles.vIndex;
    set(handles.vH{index},'Visible','off')
    handles.masterData(1).VALL{index} = [];
    adj = handles.masterData(1).ADJLIST{index}; % More deletions
    if isempty(adj)
        return;
    else
        vert = adj(1,:);
        edge = adj(2,:);
        handles.masterData(1).ADJLIST{index} = []; % Get rid of deleted vertex ADJLIST
        for n = 1:numel(edge)
            handles.masterData(1).EALL{edge(n)} = []; % Get rid of incident
            set(handles.eH{edge(n)},'Visible','off') % Edges visible off
            adjMatrix = handles.masterData(1).ADJLIST{vert(n)}; % Adjacent vertices' ADJLIST
            adjMatrix(:,find(adjMatrix(1,:) == index)) = []; % Delete the old entry
            handles.masterData(1).ADJLIST{vert(n)} = adjMatrix; % Reset
        end
        handles.masterData(1).ADJLIST{index} = [];
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
global ALL;
handles = guidata(hObject);

if isempty(ALL) % If ALL is empty, run GraphGUI to get image.
    fprintf('*****Please use GraphGUI to load your image first.*****\n')
    close(handles.figure1)
end

frame = str2double(get(handles.frame,'String'));
mD = handles.masterData;
[handles.vH,handles.eH,handles.cpH] = customdisplayGraph(ALL(:,:,frame), ...
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
showGT_Callback(hObject,eventdata,handles)


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
global ALL;
frame = str2double(get(handles.frame,'String'));
imagesc(ALL(:,:,frame));

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
handles.answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
guidata(hObject,handles)