function varargout = mdSetTime_QM(varargin)
% MDSETTIME_QM M-file for mdSetTime_QM.fig
%      MDSETTIME_QM, by itself, creates a new MDSETTIME_QM or raises the existing
%      singleton*.
%
%      H = MDSETTIME_QM returns the handle to a new MDSETTIME_QM or the handle to
%      the existing singleton*.
%
%      MDSETTIME_QM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MDSETTIME_QM.M with the given input arguments.
%
%      MDSETTIME_QM('Property','Value',...) creates a new MDSETTIME_QM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mdSetTime_QM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mdSetTime_QM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mdSetTime_QM

% Last Modified by GUIDE v2.5 12-May-2015 13:56:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdSetTime_QM_OpeningFcn, ...
                   'gui_OutputFcn',  @mdSetTime_QM_OutputFcn, ...
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


% --- Executes during object creation, after setting all properties.
function etPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etTimeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etSecPerFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etSecPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes just before mdSetTime_QM is made visible.
function mdSetTime_QM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdSetTime_QM (see VARARGIN)

% Choose default command line output for mdSetTime_QM
handles.output = 0;

handles.Problem = varargin{1};
handles.Timer = varargin{2};
handles.IsQuantum = varargin{3};
handles.Period = handles.Problem.GetPeriod;
handles.TimeStep = handles.Problem.GetTimeStep;
handles.SecPerFrame = get(handles.Timer, 'Period');
if handles.IsQuantum
    [handles.ConstNames, handles.ConstValues] = handles.Problem.GetAllConstants;
else
    [handles.ConstNames, handles.ConstValues] = handles.Problem.GetConstants;
end
set(handles.etPeriod, 'String', num2str(handles.Period))
set(handles.etTimeStep, 'String', num2str(handles.TimeStep))
set(handles.etSecPerFrame, 'String', num2str(handles.SecPerFrame))
set(handles.cbQuantedStepping, 'Value', double(varargin{4}))
set(handles.etTimeStep, 'UserData', handles.TimeStep)
set(handles.etSecPerFrame, 'UserData', handles.SecPerFrame)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mdSetTime_QM wait for user response (see UIRESUME)
uiwait(handles.figSetTime);


function etTimeStep_Callback(hObject, eventdata, handles)
% hObject    handle to etTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etTimeStep as text
%        str2double(get(hObject,'String')) returns contents of etTimeStep as a double

try
    T = handles.Period;
    for k = 1 : length(handles.ConstNames)
        temp = [handles.ConstNames{k} '=' num2str(handles.ConstValues{k}) ';'];
        eval(temp)
    end
    temp = eval(get(handles.etTimeStep, 'String'));
    if ~strcmp(class(temp), 'double') || length(temp) > 1 ||...
            isnan(temp) || isinf(temp) || imag(temp) || temp <= 0
        error('Wrong value')
    end
    handles.TimeStep = temp;
    set(handles.etTimeStep, 'String', num2str(handles.TimeStep))
    set(handles.etTimeStep, 'UserData', handles.TimeStep);
catch ME
    beep
    handles.TimeStep = get(handles.etTimeStep, 'UserData');
    set(handles.etTimeStep, 'String', num2str(handles.TimeStep))
end
guidata(hObject, handles)


function etSecPerFrame_Callback(hObject, eventdata, handles)
% hObject    handle to etSecPerFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.SecPerFrame = str2double(get(handles.etSecPerFrame, 'String'));
    if isnan(handles.SecPerFrame) || imag(handles.SecPerFrame) || handles.SecPerFrame <= 0
        error('Wrong value')
    end
    set(handles.etSecPerFrame, 'UserData', handles.SecPerFrame);
catch ME
    beep
    handles.SecPerFrame = get(handles.etSecPerFrame, 'UserData');
    set(handles.etSecPerFrame, 'String', num2str(handles.SecPerFrame))
end
guidata(hObject, handles)


% Hints: get(hObject,'String') returns contents of etSecPerFrame as text
%        str2double(get(hObject,'String')) returns contents of etSecPerFrame as a double


% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Problem.SetTimeStep(handles.TimeStep);
set(handles.Timer, 'Period', handles.SecPerFrame)
if get(handles.cbReset, 'Value') == 1
    handles.Problem.ResetTime;
end
if get(handles.cbQuantedStepping, 'Value') == 1
    handles.output = 2;
else
    handles.output = 1;
end
guidata(hObject, handles)
figSetTime_CloseRequestFcn(handles.figSetTime, eventdata, handles)


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = 0;
guidata(hObject, handles)
figSetTime_CloseRequestFcn(handles.figSetTime, eventdata, handles)


% --- Executes when user attempts to close figSetTime.
function figSetTime_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figSetTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figSetTime)

% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = mdSetTime_QM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);
