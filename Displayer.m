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
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Displayer

% Last Modified by GUIDE v2.5 20-Jun-2016 13:07:11

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
global getOUT; global masterData;
hold on;
masterData = transfer(getOUT);
set(handles.frame,'String','1');
showGT_Callback(handles.showGT,eventdata,handles);
set(gca,'Visible','off')
guidata(hObject, handles);

% UIWAIT makes Displayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
global ALL; global masterData;
frame = str2double(get(handles.frame,'String'));                      
displayGraph(ALL(:,:,frame), masterData(frame).VALL, masterData(frame).EALL, 'on');
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
