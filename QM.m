function varargout = QM(varargin)
% QM M-file for QM.fig
%      QM, by itself, creates a new QM or raises the existing
%      singleton*.
%
%      H = QM returns the handle to a new QM or the handle to
%      the existing singleton*.
%
%      QM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QM.M with the given input arguments.
%
%      QM('Property','Value',...) creates a new QM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QM

% Last Modified by GUIDE v2.5 10-May-2015 00:33:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QM_OpeningFcn, ...
                   'gui_OutputFcn',  @QM_OutputFcn, ...
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
function pmProblem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmProblem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etAvPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAvPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etAvMom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAvMom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etAvE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAvE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- OPENING_FCN ---
% --- Executes just before QM is made visible.
function QM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QM (see VARARGIN)

% Choose default command line output for QM
handles.output = hObject;

handles.IsQuantum = true;
handles.QuantedStepping = true;

d = dir;
j = 1;
for i = 1 : length(d)
    if length(d(i).name) > 5 && strcmp(d(i).name(1:3), 'QM_') && strcmp(d(i).name(end-1:end), '.m')
        handles.AllProblems{j} = d(i).name(1:end-2);
        PopupNames{j} = eval([handles.AllProblems{j} '.Popup']);
        j = j + 1;
    end
end
if j == 1
    error('No Problem Definition File (''QM_*.m'') available.')
end
set(handles.pmProblem, 'String', PopupNames)
handles.Choice = 1;
handles.ProblemName = handles.AllProblems{handles.Choice};
handles.Problem = eval(handles.ProblemName);

InitAxes(handles)
RefreshAxes(handles, true)

handles.Timer = timer('ExecutionMode', 'fixedRate', 'StartDelay', 1, 'Period', 3, 'UserData', handles.figure1);
set(handles.Timer, 'TimerFcn', @(hObject, eventdata)QM('Timer_Callback', hObject, eventdata, guidata(hObject.UserData)))
set(handles.Timer, 'StartFcn', @(hObject, eventdata)QM('Timer_Start', hObject, eventdata, guidata(hObject.UserData)))
set(handles.Timer, 'StopFcn', @(hObject, eventdata)QM('Timer_Stop', hObject, eventdata, guidata(hObject.UserData)))

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes QM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = QM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in pmProblem.
function pmProblem_Callback(hObject, eventdata, handles)
% hObject    handle to pmProblem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmProblem contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmProblem

%elõször mentjük az eredeti értékeket
oldChoice = handles.Choice;
oldProblemName = handles.ProblemName;
oldProblem = handles.Problem;
% aztán próbálunk váltani
try
    PopupNames = cellstr(get(hObject, 'String'));
    handles.Choice = get(hObject, 'Value');
    if handles.Choice == oldChoice
        return
    end
    handles.ProblemName = handles.AllProblems{handles.Choice};
    handles.Problem = eval(handles.ProblemName); % itt jöhet a kivétel
    InitAxes(handles)
    RefreshAxes(handles, true) % RefreshAxes ugye nem használja a guidata függvényt? Csak mert hatástalan lenne.
    delete(oldProblem)
    guidata(hObject, handles)
catch ME % ha hiba van
    set(hObject, 'Value', oldChoice) % popup érték visszaállítás
    %handles.Problem = oldProblem; % probléma visszaállítása (ez csak az újraábrázolás könnyítéséhez kell)
    % újra plot, bár szükségtelen, ha ugyanis a vezérlés eljutott a plotig,
    % s aztán történt hiba, az régen rossz
    %[x, V, ~, ~, ~] = handles.Problem.GetPotential;
    %[~, E, A] = handles.Problem.GetEnergy;
    %plot(handles.axePot, x, V)
    %xlabel(handles.axePot, 'Place [m]')
    %ylabel(handles.axePot, 'Potential [J]')
    %plot(handles.axeE, abs(A).^2, E, 'o')
    %xlabel(handles.axeE, 'Probability')
    %ylabel(handles.axeE, 'Energy [J]')
    %RefreshAxes(handles) % ugye most se guidatázik?
    beep
    msgbox(['New instance of Problem ''' PopupNames{handles.Choice} ''' cannot be created. '...
        '(Perhaps file ''' handles.ProblemName '.m' ''' is not available.)']) % itt handles.Choice és handles.ProblemName a bukott értéket tartalmazzák
end


% --- Executes on button press in pbSwitch.
function pbSwitch_Callback(hObject, eventdata, handles)
% hObject    handle to pbSwitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSetTime.
function pbSetTime_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = mdSetTime_QM(handles.Problem, handles.Timer, handles.IsQuantum, handles.QuantedStepping);
if answer == 1
    handles.QuantedStepping = false;
    RefreshAxes(handles, false)
elseif answer == 2
    handles.QuantedStepping = true;
    RefreshAxes(handles, false)
end
guidata(hObject, handles)


% --- Executes on button press in pbSetPot.
function pbSetPot_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetPot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mdSetPot_QM(handles.Problem, handles.ProblemName, handles.IsQuantum)
    InitAxes(handles)
    RefreshAxes(handles, true)
end


% --- Executes on button press in pbSetE.
function pbSetE_Callback(hObject, eventdata, handles)
% hObject    handle to pbSetE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mdSetE_QM(handles.Problem)
    InitAxes(handles)
    RefreshAxes(handles, true)
end


% --- Executes on writing in etTime
function etTime_Callback(hObject, eventdata, handles)
% hObject    handle to etTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etTime as text
%        str2double(get(hObject,'String')) returns contents of etTime as a
%        double
T = handles.Problem.GetPeriod;
dt = handles.Problem.GetTimeStep;
try
    time = eval(get(hObject, 'String'));
    if ~strcmp(class(time), 'double') || length(time) > 1 || isnan(time) ||...
            isinf(time) || imag(time)
        error('Wrong string.')
    end
    if handles.QuantedStepping
        oldtime = get(hObject, 'UserData');
        handles.Problem.StepForward(floor((time - oldtime) / dt))
    else
        handles.Problem.SetTime(time)
    end
    time = handles.Problem.GetTime;
    set(hObject, 'String', num2str(time))
    set(hObject, 'UserData', time)
    RefreshAxes(handles, false)
catch ME
    beep
    oldtime = get(hObject, 'UserData');
    set(hObject, 'String', num2str(oldtime))
end



% --- Executes on button press in pbPrev.
function pbPrev_Callback(hObject, eventdata, handles)
% hObject    handle to pbPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Problem.StepReverse;
%guidata(hObject, handles)
RefreshAxes(handles, false)


% --- Executes on button press in pbNext.
function pbNext_Callback(hObject, eventdata, handles)
% hObject    handle to pbNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Problem.StepForward;
%guidata(hObject, handles)
RefreshAxes(handles, false)


% --- Executes on button press in pbPlay.
function pbPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pbPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.Timer, 'Running'), 'on')
    stop(handles.Timer);
    set(handles.pbPlay, 'String', 'play')
    set(handles.pbNext, 'Enable', 'on')
    set(handles.pbPrev, 'Enable', 'on')
    set(handles.pbSetTime, 'Enable', 'on')
    set(handles.pbSetE, 'Enable', 'on')
    set(handles.pbSetPot, 'Enable', 'on')
else
    start(handles.Timer);
end


% --- executes on Timer event
function Timer_Callback(hObject, eventdata, handles)
handles.Problem.StepForward;
RefreshAxes(handles, false)


function Timer_Start(hObject, eventdata, handles)
    set(handles.pmProblem, 'Enable', 'off')
    set(handles.pbSetPot, 'Enable', 'off')
    set(handles.pbSetE, 'Enable', 'off')
    set(handles.pbSetTime, 'Enable', 'off')
    set(handles.pbPrev, 'Enable', 'off')
    set(handles.pbNext, 'Enable', 'off')
    set(handles.etTime, 'Enable', 'off')
    set(handles.pbPlay, 'String', 'pause')


function Timer_Stop(hObject, eventdata, handles)
    set(handles.pbPlay, 'String', 'play')
    set(handles.etTime, 'Enable', 'on')
    set(handles.pbNext, 'Enable', 'on')
    set(handles.pbPrev, 'Enable', 'on')
    set(handles.pbSetTime, 'Enable', 'on')
    set(handles.pbSetE, 'Enable', 'on')
    set(handles.pbSetPot, 'Enable', 'on')
    set(handles.pmProblem, 'Enable', 'on')


% --- For Inicializing axes
function InitAxes(handles)

[x, V, ~, ~, ~] = handles.Problem.GetPotential;
[~, E, A] = handles.Problem.GetEnergy;
[~, ~, ~, avE] = handles.Problem.GetAverage;
plot(handles.axePot, x, V)
xlabel(handles.axePot, 'Position [m]')
ylabel(handles.axePot, 'Potential [J]')
plot(handles.axeE, abs(A).^2, E, 'o')
xlabel(handles.axeE, 'Probability')
ylabel(handles.axeE, 'Energy [J]')
xlim(handles.axeE, [0 1])
PotLim = ylim(handles.axePot);
ELim = ylim(handles.axeE);
Lim(1) = min(PotLim(1), ELim(1));
Lim(2) = max(PotLim(2), ELim(2));
ylim(handles.axePot, Lim);
ylim(handles.axeE, Lim);
hold(handles.axeE, 'on')
plot(handles.axeE, linspace(0, 1, 20), avE * ones(1, 20), 'r')
hold(handles.axeE, 'off')
set(handles.etAvE, 'String', num2str(avE))
set(handles.axePhaseField, 'UserData', 0)


% --- for refreshing axes
function RefreshAxes(handles, IsFirst)

% átlagértékek
[t, avx, avp, ~] = handles.Problem.GetAverage;
set(handles.etTime, 'String', num2str(t))
set(handles.etTime, 'UserData', t)
set(handles.etAvPos, 'String', num2str(avx))
set(handles.etAvMom, 'String', num2str(avp))

% hely
[x, X] = handles.Problem.GetState;
[p, P] = handles.Problem.GetMomentum;
if ~IsFirst
    orng = axis(handles.axeState);
end
plot(handles.axeState, x, real(X), 'g', x, imag(X), 'r')
legend(handles.axeState, 'Real', 'Imag')
xlabel(handles.axeState, 'Position [m]')
ylabel(handles.axeState, 'Wave Function [m^-^1^/^2]')
if ~IsFirst
    nrng = axis(handles.axeState);
    rng = [];
    rng([1 3]) = min(orng([1 3]), nrng([1 3]));
    rng([2 4]) = max(orng([2 4]), nrng([2 4]));
    axis(handles.axeState, rng)
    orng = axis(handles.axeCurveState);
end

plot3(handles.axeCurveState, x, real(X), imag(X))
%rotate(handles.axeCurveState, 10, 60)
xlabel(handles.axeCurveState, 'Position [m]')
ylabel(handles.axeCurveState, 'Real<Wave Function> [m^-^1^/^2]')
zlabel(handles.axeCurveState, 'Imag<Wave Function> [m^-^1^/^2]')
if ~IsFirst
    nrng = axis(handles.axeCurveState);
    rng = [];
    rng([1 3 5]) = min(orng([1 3 5]), nrng([1 3 5]));
    rng([2 4 6]) = max(orng([2 4 6]), nrng([2 4 6]));
    axis(handles.axeCurveState, rng);
end

% impulzus
if ~IsFirst
    orng = axis(handles.axeFTState);
end
plot(handles.axeFTState, p, real(P), 'g', p, imag(P), 'r')
legend(handles.axeFTState, 'Real', 'Imag')
xlabel(handles.axeFTState, 'Momentum [kg * m * s^-^1]')
ylabel(handles.axeFTState, 'Wave Function [kg^-^1^/^2 * m^-^1^/^2 * s^1^/^2]')
if ~IsFirst
    nrng = axis(handles.axeFTState);
    rng = [];
    rng([1 3]) = min(orng([1 3]), nrng([1 3]));
    rng([2 4]) = max(orng([2 4]), nrng([2 4]));
    axis(handles.axeFTState, rng);
    orng = axis(handles.axeCurveFTState);
end

plot3(handles.axeCurveFTState, p, real(P), imag(P))
%rotate(10, 60)
xlabel(handles.axeCurveFTState, 'Momentum [kg * m * s^-^1]')
ylabel(handles.axeCurveFTState, 'Real<Wave Function> [kg^-^1^/^2 * m^-^1^/^2 * s^1^/^2]')
zlabel(handles.axeCurveFTState, 'Imag<Wave Function> [kg^-^1^/^2 * m^-^1^/^2 * s^1^/^2]')
if ~IsFirst
    nrng = axis(handles.axeCurveFTState);
    rng = [];
    rng([1 3 5]) = min(orng([1 3 5]), nrng([1 3 5]));
    rng([2 4 6]) = max(orng([2 4 6]), nrng([2 4 6]));
    axis(handles.axeCurveFTState, rng);
end

% fázistér
KSIx = abs(X).^2;
KSIp = abs(P).^2;
if ~IsFirst
    orng = axis(handles.axeDensPos);
end
plot(handles.axeDensPos, x, KSIx, 'b')
if ~IsFirst
    nrng = axis(handles.axeDensPos);
    rng = [];
    rng([1 3]) = min(orng([1 3]), nrng([1 3]));
    rng([2 4]) = max(orng([2 4]), nrng([2 4]));
    rng(3) = 0;
    axis(handles.axeDensPos, rng)
else
    rng = axis(handles.axeDensPos);
    rng(3) = 0;
    axis(handles.axeDensPos, rng)
end
hold(handles.axeDensPos, 'on')
yy = linspace(rng(3), rng(4), 20);
xx = avx * ones(1,20);
plot(handles.axeDensPos, xx, yy, 'r')
hold(handles.axeDensPos, 'off')
xlabel(handles.axeDensPos, 'Position [m]')
ylabel(handles.axeDensPos, 'Probability Density [m^-^1]')

if ~IsFirst
    orng = axis(handles.axeDensMom);
end
plot(handles.axeDensMom, p, KSIp)
if ~IsFirst
    nrng = axis(handles.axeDensMom);
    rng = [];
    rng([1 3]) = min(orng([1 3]), nrng([1 3]));
    rng([2 4]) = max(orng([2 4]), nrng([2 4]));
    rng(3) = 0;
    axis(handles.axeDensMom, rng)
else
    rng = axis(handles.axeDensMom);
    rng(3) = 0;
    axis(handles.axeDensMom, rng)
end
hold(handles.axeDensMom, 'on')
yy = linspace(rng(3), rng(4), 20);
xx = avp * ones(1,20);
plot(handles.axeDensMom, xx, yy, 'r')
hold(handles.axeDensMom, 'off')
xlabel(handles.axeDensMom, 'Momentum [kg * m * s^-^1]')
ylabel(handles.axeDensMom, 'Probability Density [kg^-^1 * m^-^1 * s]')

% ez a változat (imagesc) timerrel mûködtetve külsõ ábrára akar plotolni, mintha az axes() parancs nem is lett volna.
%set(handles.axePhaseField, 'HandleVisibility', 'on')
axes(handles.axePhaseField) % valamért hasztalan, ha timerbõl van meghívva

if ~IsFirst
    oN = get(handles.axePhaseField, 'UserData');
else 
    oN = 0;
end
Data = KSIp.' * KSIx;
N = max(oN, max(max(Data)));
Data = Data / N;
%Data(:,:,2) = Data;
%Data(:,:,3) = Data(:,:,2);
%for i = 1 : length(x)
%    if x(i) > avx
%        break
%    end
%end
%for j = 1 : length(p)
%    if p(j) > avp
%        break
%    end
%end
%Data(j, :, 1) = 1;
%Data(j, :, 2 : 3) = Data(j, :, 2 : 3) / 2;
%Data(:, i, 1) = 1;
%Data(:, i, 2 : 3) = Data(:, i, 2 : 3) / 2;
imagesc(x, p, Data)
set(gca, 'YDir', 'normal')
colormap(gray)
hold on
plot(x, avp * ones(1, length(x)), 'r')
plot(avx * ones(1, length(p)), p, 'r')
hold off
set(handles.axePhaseField, 'UserData', N)

% ez a változat (surf) viszont összeonlasztja a MATLAB-ot, ha az ATI videokártya aktív
%h = surf(handles.axePhaseField, x, p, KSIp.' * KSIx);
%view(handles.axePhaseField, 0, 90)
%set(h, 'LineStyle', 'none')
%ylim(handles.axePhaseField, [p(1),p(end)])
%xlim(handles.axePhaseField, [x(1),x(end)])
%colormap(handles.axePhaseField, gray)
%close(figure(1))

xlabel(handles.axePhaseField, 'Position [m]')
ylabel(handles.axePhaseField, 'Momentum [kg * m * s^-^1]')


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.Timer, 'Running'), 'on')
    stop(handles.Timer)
end
close(figure(1))
delete(handles.Problem)
delete(handles.Timer)


% Hint: delete(hObject) closes the figure
delete(hObject);
