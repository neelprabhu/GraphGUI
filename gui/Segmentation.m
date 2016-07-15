function varargout = Segmentation(varargin)
% Segmentation MATLAB code for Segmentation.fig
%      Segmentation, by itself, creates a new Segmentation or raises the existing
%      singleton*.
%
%      H = Segmentation returns the handle to a new Segmentation or the handle to
%      the existing singleton*.
%
%      Segmentation('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Segmentation.M with the given input arguments.
%
%      Segmentation('Property','Value',...) creates a new Segmentation or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the Segmentation before Segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Segmentation_OpeningFcn via varargin.
%
%      *See Segmentation Options on GUIDE's Tools menu.  Choose "Segmentation allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Segmentation

% Last Modified by GUIDE v2.5 15-Jul-2016 10:09:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @Segmentation_OutputFcn, ...
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

% --- Executes just before Segmentation is made visible.
function Segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Segmentation (see VARARGIN)

% Choose default command line output for Segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.thresh_slide,'Value',0.5);
imshow(ones(150))
setup; clear, clc

% --- Outputs from this function are returned to the command line.
function varargout = Segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_load.
function pb_load_Callback(hObject, eventdata, handles)
% hObject    handle to pb_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global TIFF; global ALL;
[filename, pathname] = uigetfile({'*.tif';'*.*'}, 'Pick an Image File');
img = imread([pathname,filename]);
TIFF = loadtiff([pathname,filename]);
ALL = TIFF;
set(handles.edit1,'String',[pathname,filename]);
axes(handles.img_display);
imshow(img);
set(handles.img_display,'Visible','off');
guidata(hObject, handles);


% --- Executes on button press in segment_button.
function segment_button_Callback(hObject, eventdata, handles)
% hObject    handle to segment_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global B;

hminima = get(handles.thresh_slide, 'Value') .* 100;                                                 % the h parameter for matlab's imhmin function optimized to this data set                                                 % SEG holds the segmentations of image stack
L = watershed(imhmin(medfilt2(img,[3,3]), hminima));          % watershed segmentation on each frame (after light median filtering for noise removal)
B = imreadgroundtruth(L==0, true);                            % convert segmentation to ground truth format
imshow(B);

% --- Executes on slider movement.
function thresh_slide_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global current;
segment_button_Callback(handles.segment_button, eventdata, handles);
overlay_button_Callback(handles.overlay_button,eventdata,handles);
global junk;
imshow(junk)


% --- Executes during object creation, after setting all properties.
function thresh_slide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imsave;

% --- Executes on button press in overlay_button.
function overlay_button_Callback(hObject, eventdata, handles)
% hObject    handle to overlay_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global B;
global junk;
junk = img;
junk = repmat(double(img)./255,[1 1 3]);
sizee = size(B);
for r = 1:sizee(1)
    for c = 1:sizee(2)
        if B(r,c) == 1
            junk(r,c,:) = [0,0,1];
        end
    end
end


% --- Executes on selection change in pull_down.
function pull_down_Callback(hObject, eventdata, handles)
% hObject    handle to pull_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pull_down contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pull_down
global current; global B; global junk; global img;
str = get(hObject, 'String');
val = get(hObject, 'Value');
switch str{val}
    case 'GT'
        current = B;
    case 'Overlay'
        overlay_button_Callback(handles.overlay_button,eventdata,handles)
        current = junk;
    case 'Raw'
        current = img;
end
imshow(current);

% --- Executes during object creation, after setting all properties.
function pull_down_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pull_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and CsOMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in send_button.
function send_button_Callback(hObject, eventdata, handles)
% hObject    handle to send_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global B; global TIFF;
imwrite(B,'myGT.png');
assignin('base','TIFF',TIFF);
closereq;
GraphGUI;


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Do nothing

% --------------------------------------------------------------------
function view_Callback(hObject, eventdata, handles)
% hObject    handle to view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Do nothing

% --------------------------------------------------------------------
function gtShow_Callback(hObject, eventdata, handles)
% hObject    handle to gtShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global B;
imshow(B)

% --------------------------------------------------------------------
function overlayShow_Callback(hObject, eventdata, handles)
% hObject    handle to overlayShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
overlay_button_Callback(handles.overlay_button,eventdata,handles)
global junk;
imshow(junk)

% --------------------------------------------------------------------
function rawShow_Callback(hObject, eventdata, handles)
% hObject    handle to rawShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
imshow(img)

% --------------------------------------------------------------------
function dataLoad_Callback(hObject, eventdata, handles)
% hObject    handle to dataLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pb_load_Callback(handles.pb_load, eventdata, handles)

% --------------------------------------------------------------------
function graphSend_Callback(hObject, eventdata, handles)
% hObject    handle to graphSend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
send_button_Callback(handles.send_button, eventdata, handles)
