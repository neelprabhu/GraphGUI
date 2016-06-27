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
hold on;
handles.masterData = transfer(getOUT);
set(handles.frame,'String','1');
showGT_Callback(handles.showGT,eventdata,handles);
set(gca,'Visible','off')
guidata(hObject, handles);

%% Code for tracking mouse movements and clicks
state.WindowButtonDownFcn = get(gcf, 'WindowButtonDownFcn');
state.WindowButtonMotionFcn = get(gcf, 'WindowButtonMotionFcn');
state.WindowButtonUpFcn = get(gcf, 'WindowButtonUpFcn');
state.vertexIdx = -1;
set(gcf,'UserData',handles.masterData)

set(gca, 'UserData', state);
axes(handles.axes1)
set(gcf, 'WindowButtonDownFcn', @selectPoint);
set(gcf, 'WindowButtonMotionFcn', @trackPoint);
set(gcf, 'WindowButtonUpFcn', @stopTracking);

function selectPoint(~,~) %When mouse is clicked
global ALL;
state = get(gca, 'UserData');
prelimPoint = get(gca,'CurrentPoint');
prelimPoint = prelimPoint(1,1:2)';

if prelimPoint(1) > 20 && prelimPoint(2)>20
    state.cp = prelimPoint;
else
    state.cp = [];
end

masterData = get(gcf,'UserData'); %Gets the data struct
state.vertexIndex = eucDistance(masterData(1).VALL,state.cp); %Finds nearest vertex
VALL = masterData(1).VALL;
vertexIndex = eucDistance(VALL,state.cp);
state.vertexIdx = vertexIndex;

set(gca,'UserData',state)
display(state.vertexIndex)

hold on;
displayGraph(ALL(:,:,1), masterData(1).VALL,  ...
    masterData(1).EALL, 'on', state.vertexIndex);

function trackPoint(~, ~)
     s = get(gca, 'UserData');
     if s.vertexIdx ~= -1
         vertexIndex
     end
     
 function stopTracking(~, ~)
        s = get(gca, 'UserData');
        s.vertexIdx = -1;
        set(gca, 'UserData', s);

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
H = displayGraph(ALL(:,:,frame), handles.masterData(frame).VALL, handles.masterData(frame).EALL, 'on');
zoomStartX = 20; zoomStopX = size(ALL(:,:,1),2)-19;
zoomStartY = 20; zoomStopY = size(ALL(:,:,1),1)-19;
set(gca, 'XLim', [zoomStartX zoomStopX])
set(gca, 'YLim', [zoomStartY zoomStopY])

function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame as text
%        str2double(get(hObject,'String')) returns contents of frame as a double


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
