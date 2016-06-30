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

% --- Executes just before Displayer is made visible.
function Displayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Displayer (see VARARGIN)

% Choose default command line output for Displayer
handles.output = hObject;

% Update handles structure
global getOUT;
global ALL;
handles.masterData = transfer(getOUT);
set(handles.frame,'String','1');

%% Code for tracking mouse movements and clicks

handles.vertexIdx = -1;
handles.isAdd = 0;
handles.zStX = 20; handles.zStoX = size(ALL(:,:,1),2)-19;
handles.zStY = 20; handles.zStoY = size(ALL(:,:,1),1)-19;
guidata(hObject,handles)

showGT_Callback(handles.showGT,eventdata,handles); %Initializes window
set(gca,'Visible','off') %Turns off axes

set(gcf, 'WindowButtonDownFcn', @selectPoint);
set(gcf, 'WindowButtonMotionFcn', @trackPoint);
set(gcf, 'WindowButtonUpFcn', @stopTracking);

%% Sets up initial Voronoi diagram of vertices

handles = guidata(hObject);
handles.DT = setVoronoi(handles);
guidata(hObject,handles)

function selectPoint(hObject, eventdata) % When mouse is clicked
global ALL;

handles = guidata(hObject);
masterData = handles.masterData;
prelimPoint = get(gca,'CurrentPoint');
prelimPoint = prelimPoint(1,1:2);

if prelimPoint(1) > 20 && prelimPoint(2) > 20
    handles.cp = prelimPoint;
else
    handles.cp = [];
end

if handles.isAdd
    next = size(masterData(1).VALL,1);
    masterData(1).VALL{next+1} = handles.cp;
    hold on;
    displayGraph(ALL(:,:,1), masterData(1).VALL,  ...
        masterData(1).EALL, 'on');
    set(gca, 'XLim', [handles.zStX handles.zStoX])
    set(gca, 'YLim', [handles.zStY handles.zStoY])
    handles.isAdd = 0; handles.masterData = masterData;
    handles.DT = setVoronoi(handles);
    guidata(hObject,handles)
    return;
end

% Finds nearest vertex
handles.vertexIdx = nearestNeighbor(handles.DT,handles.cp);

%set(gca,'UserData',state)
display(handles.vertexIdx)

hold on;
displayGraph(ALL(:,:,1), masterData(1).VALL,  ...
    masterData(1).EALL, 'on', handles.vertexIdx);
guidata(hObject,handles)

function trackPoint(hObject,eventdata)
     handles = guidata(hObject);
     if handles.vertexIdx ~= -1
         %move point here
         newcp = get(gca,'CurrentPoint');
         newcp = newcp(1, 1:2)';
         masterData = handles.masterData; %Gets the data struct
         masterData(1).VALL{handles.vertexIdx} = newcp;
%          fprintf('hello');
%          displayGraph(ALL(:,:,1), masterData(1).VALL,  ...
%             masterData(1).EALL, 'on', s.vertexIdx);
%        move spline endpoints
        %idk why there are 10000000 vertices
     end
guidata(hObject,handles)
     
 function stopTracking(hObject,eventdata)
        handles = guidata(hObject);
        handles.vertexIdx = -1;
        guidata(hObject,handles)

% --- Outputs from this function are returned to the command line.
function varargout = Displayer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in showGT.
function showGT_Callback(hObject, eventdata, handles)
% hObject    handle to showGT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ALL;
frame = str2double(get(handles.frame,'String'));
handles = guidata(hObject);
H = displayGraph(ALL(:,:,frame), handles.masterData(frame).VALL, handles.masterData(frame).EALL, 'on');
set(gca, 'XLim', [handles.zStX handles.zStoX])
set(gca, 'YLim', [handles.zStY handles.zStoY])

function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame as text
%        str2double(get(hObject,'String')) returns contents of frame as a double
showGT_Callback(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in add_element.
function add_element_Callback(hObject, eventdata, handles)
% hObject    handle to add_element (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.isAdd = 1;
guidata(hObject,handles)

% --- Executes on button press in showRaw.
function showRaw_Callback(hObject, eventdata, handles)
% hObject    handle to showRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ALL;
frame = str2double(get(handles.frame,'String'));
imagesc(ALL(:,:,frame));

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Starting frame:','Ending frame:'};
dlg_title = 'Tracking Options'; num_lines = 1; defaultans = {'1','2'};
handles = guidata(hObject);
handles.answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
guidata(hObject,handles)