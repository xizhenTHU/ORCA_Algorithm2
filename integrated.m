function varargout = integrated(varargin)
% INTEGRATED MATLAB code for integrated.fig
%      INTEGRATED, by itself, creates a new INTEGRATED or raises the existing
%      singleton*.
%
%      H = INTEGRATED returns the handle to a new INTEGRATED or the handle to
%      the existing singleton*.
%
%      INTEGRATED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTEGRATED.M with the given input arguments.
%
%      INTEGRATED('Property','Value',...) creates a new INTEGRATED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before integrated_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to integrated_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help integrated

% Last Modified by GUIDE v2.5 02-Aug-2019 12:13:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @integrated_OpeningFcn, ...
                   'gui_OutputFcn',  @integrated_OutputFcn, ...
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

% --- Executes just before integrated is made visible.
function integrated_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to integrated (see VARARGIN)

% Choose default command line output for integrated
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using integrated.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes integrated wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = integrated_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.Lidar);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%      set(hObject,'BackgroundColor','white');
% end
% 
% set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes during object creation, after setting all properties.
function DeepPic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeepPic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate DeepPic


% --- Executes during object creation, after setting all properties.
function Lidar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lidar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Lidar


% --- Executes on button press in openDir.
function openDir_Callback(hObject, eventdata, handles)
% hObject    handle to openDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selpath = uigetdir;

%%
%加载并处理realsense数据
%读取时间戳

Txtfilename = dir([selpath,'\realsense*\imu.*']);
% Txtfilename = dir([selpath,'\realsense\imu\*.txt']);
Txtfilename = [Txtfilename.folder,'\',Txtfilename.name];
delimiter = ',';
formatSpec = '%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(Txtfilename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
Timestamp = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;
Timestamp=num2str(Timestamp,'%.5f');

%匹配文件名
nameRGB=strings(size(Timestamp,1),1);
nameDeepth=strings(size(Timestamp,1),1);
for ii=1:size(Timestamp,1)
    temp=dir([selpath,'\realsense*\rgb\',strtrim(Timestamp(ii,1:end-2)),'*.jpg']);
    nameRGB(ii,:)=[temp.folder,'\',temp.name];
    temp=dir([selpath,'\realsense*\depth\',strtrim(Timestamp(ii,1:end-2)),'*.jpg']);
    nameDeepth(ii,:)=[temp.folder,'\',temp.name];
end
handles.nameRGB=nameRGB;
handles.nameDeepth=nameDeepth;
guidata(hObject,handles)%(注意，一定是两行连写）
%%
% %加载并处理激光雷达
% filename = 'C:\工程文件\ORCA\代码\2_Algorithm2\Data\data1.csv';
% delimiter = ',';
% formatSpec = '%f%f%f%f%f%[^\n\r]';
% fileID = fopen(filename,'r');
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
% fclose(fileID);
% AngleHorizontal = dataArray{:, 1};
% AngleVertical = dataArray{:, 2};
% dist = dataArray{:, 3}/100;
% reflectivity = dataArray{:, 4};
% time = dataArray{:, 5};
% clearvars filename delimiter formatSpec fileID dataArray ans;
% dist(reflectivity==0)=0;
% z=dist.*sind(AngleVertical);
% x=dist.*cosd(AngleVertical).*cosd(AngleHorizontal);
% y=dist.*cosd(AngleVertical).*sind(AngleHorizontal);
% %需要整合为一帧一帧类似于图像的数据

% --- Executes on button press in begin.
function begin_Callback(hObject, eventdata, handles)
% hObject    handle to begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nameRGB=handles.nameRGB;
nameDeepth=handles.nameDeepth;

for ii=1:size(nameRGB,1)
%     axes(handles.RGBPic);imshow(nameRGB(ii,:));
%     axes(handles.DeepPic);imshow(nameDeepth(ii,:));
    image(handles.RGBPic,imread(nameRGB(ii,:)));set (handles.RGBPic,'Xtick',[],'Ytick',[]);
    image(handles.DeepPic,imread(nameDeepth(ii,:)));set (handles.DeepPic,'Xtick',[],'Ytick',[]);
    pause(0.05)
end
