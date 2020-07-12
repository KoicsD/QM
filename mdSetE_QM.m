function varargout = mdSetE_QM(varargin)
% MDSETE_QM M-file for mdSetE_QM.fig
%      MDSETE_QM, by itself, creates a new MDSETE_QM or raises the existing
%      singleton*.
%
%      H = MDSETE_QM returns the handle to a new MDSETE_QM or the handle to
%      the existing singleton*.
%
%      MDSETE_QM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MDSETE_QM.M with the given input arguments.
%
%      MDSETE_QM('Property','Value',...) creates a new MDSETE_QM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mdSetE_QM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mdSetE_QM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mdSetE_QM

% Last Modified by GUIDE v2.5 11-May-2015 12:19:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdSetE_QM_OpeningFcn, ...
                   'gui_OutputFcn',  @mdSetE_QM_OutputFcn, ...
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
function etNes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etNes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etAsFun_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAsFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function etavE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etavE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes just before mdSetE_QM is made visible.
function mdSetE_QM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdSetE_QM (see VARARGIN)

% Choose default command line output for mdSetE_QM
handles.output = false;

handles.Problem = varargin{1};
[handles.indexes, handles.EValues, handles.ECoeffs] = handles.Problem.GetEnergy;
handles.IsNormalized = true;
handles.nes = length(handles.indexes);
assert(handles.nes == length(handles.EValues) && handles.nes == length(handles.EValues))        % assert
set(handles.etNes, 'String', num2str(handles.nes))
%set(handles.etNes, 'UserData', handles.nes)
[handles.ConstNames, handles.ConstVals] = handles.Problem.GetAllConstants;
assert(length(handles.ConstNames) == length(handles.ConstVals))                             % assert
set(handles.tabEStates, 'Data', [handles.indexes.', handles.EValues.',...
    abs(handles.ECoeffs.'), angle(handles.ECoeffs.'),...
    real(handles.ECoeffs.'), imag(handles.ECoeffs.')])
set(handles.tabEStates, 'RowName', {},...
    'ColumnName', {'n', 'E(n) [J]',...
    'abs(C(n))', 'angle(C(n)) [rad]', 'real(C(n))', 'imag(C(n))'})
set(handles.tabEStates, 'ColumnWidth', {20 75 75 100 75 75},...
    'ColumnEditable', [false, false, true, true, true, true])
plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
xlim(handles.axesE, [0 1])
hold(handles.axesE, 'on')
avE = sum(abs(handles.ECoeffs).^2 .* handles.EValues) / sum(abs(handles.ECoeffs).^2);
plot(handles.axesE, linspace(0, 1, 20), avE * ones(1, 20), 'r')
hold(handles.axesE, 'off')
xlabel(handles.axesE, 'Probability')
ylabel(handles.axesE, 'Energy [J]')
set(handles.etavE, 'String', num2str(avE))

%set(handles.etAsFun, 'Callback', {@etAsFun_Callback, handles})

% Update handles structure
guidata(hObject, handles);
set(handles.tabEStates, 'CellEditCallback', @(hObject, eventdata)mdSetE_QM('tabEStates_CellEditCallback', hObject, eventdata, guidata(hObject)))

% UIWAIT makes mdSetE_QM wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Executes on button press in pbP.
function pbP_Callback(hObject, eventdata, handles)
% hObject    handle to pbP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oldnes = handles.nes;
handles.nes = handles.nes + 1;
set(handles.etNes, 'String', num2str(handles.nes))
handles.ECoeffs(handles.nes) = 0; % az utolsó együttható után 0-val bõvítjük a sort
[handles.indexes, handles.EValues] = handles.Problem.CalcEnergy(handles.ECoeffs); % és meghívjuk a probléma objektum metódusát, hogy mondja meg az új energiaértéket
set(handles.tabEStates, 'Data', [handles.indexes.', handles.EValues.',... az adatokat végül mentjük a táblázatba
    abs(handles.ECoeffs.'), angle(handles.ECoeffs.'),...
    real(handles.ECoeffs.'), imag(handles.ECoeffs.')])
plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
if handles.IsNormalized
    hold(handles.axesE, 'on')
    avE = sum(abs(handles.ECoeffs).^2 .* handles.EValues) / sum(abs(handles.ECoeffs).^2);
    plot(handles.axesE, linspace(0, 1, 20), avE * ones(1, 20), 'r')
    hold(handles.axesE, 'off')
end
xlabel(handles.axesE, 'Probability')
ylabel(handles.axesE, 'Energy [J]')
guidata(hObject, handles) % és persze a handles-t is frissítjük, hisz oda is mentettünk egy példányt


% --- Executes on button press in pbM.
function pbM_Callback(hObject, eventdata, handles)
% hObject    handle to pbM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.nes >= 2 % csak ha nem megy 0-ba az energiaértékek száma
    oldnes = handles.nes;
    handles.nes = handles.nes - 1;
    set(handles.etNes, 'String', num2str(handles.nes))
    Data = get(handles.tabEStates, 'Data');
    handles.ECoeffs = handles.ECoeffs(1 : handles.nes); % ezzel eldobunk egy együtthatót
    handles.EValues = handles.EValues(1 : handles.nes); % ezzel eldobunk egy energiaértéket
    handles.indexes = handles.indexes(1 : handles.nes); % ezzel egy indexet
    Data = Data(1:handles.nes,:); % ezzel meg az alsó sort a táblázat adataiból
    set(handles.tabEStates, 'Data', Data)
    handles.IsNormalized = false; % normalizálási igény jelzése
    set(handles.pbOK, 'String', 'Normalize')
    plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
    xlabel(handles.axesE, 'Probability')
    ylabel(handles.axesE, 'Energy [J]')
    xlim(handles.axesE, 'auto')
    set(handles.etavE, 'String', '')
    guidata(hObject, handles) % handles frissítése
else % ha 0-ba menne, bip
    beep
end


function etNes_Callback(hObject, eventdata, handles)
% hObject    handle to etNes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etNes as text
%        str2double(get(hObject,'String')) returns contents of etNes as a double
try
    oldnes = handles.nes;
    handles.nes = floor(str2double(get(hObject, 'String')));
    if imag(handles.nes) || handles.nes < 1 % ha valami komplexet vagy túl kicsit adtunk meg, hiba
        error('Wrong number.')
    end
    if handles.nes < oldnes % akkor csökkentésrõl van szó, lásd: pbM_Callback
        set(handles.etNes, 'String', num2str(handles.nes))
        Data = get(handles.tabEStates, 'Data');
        handles.ECoeffs = handles.ECoeffs(1:handles.nes);
        handles.EValues = handles.EValues(1 : handles.nes);
        handles.indexes = handles.indexes(1 : handles.nes);
        Data = Data(1:handles.nes,:);
        set(handles.tabEStates, 'Data', Data)
    handles.IsNormalized = false; % normalizálási igény jelzése
    set(handles.pbOK, 'String', 'Normalize')
        plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
        xlabel(handles.axesE, 'Probability')
        ylabel(handles.axesE, 'Energy [J]')
        xlim(handles.axesE, 'auto')
        set(handles.avE, 'String', '')
        guidata(hObject, handles) % update handles
    elseif handles.nes > oldnes % akkor növelés, lásd: pbP_Callback
    set(handles.etNes, 'String', num2str(handles.nes))
    handles.ECoeffs(oldnes + 1 : handles.nes) = 0;
    [handles.indexes, handles.EValues] = handles.Problem.CalcEnergy(handles.ECoeffs);
    set(handles.tabEStates, 'Data', [handles.indexes.', handles.EValues.',...
        abs(handles.ECoeffs.'), angle(handles.ECoeffs.'),...
        real(handles.ECoeffs.'), imag(handles.ECoeffs.')])
    plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
    if handles.IsNormalized
        hold(handles.axesE, 'on')
        avE = sum(abs(handles.ECoeffs).^2 .* handles.EValues) / sum(abs(handles.ECoeffs).^2);
        plot(handles.axesE, linspace(0, 1, 20), avE * ones(1, 20), 'r')
        hold(handles.axesE, 'off')
    end
    xlabel(handles.axesE, 'Probability')
    ylabel(handles.axesE, 'Energy [J]')
    guidata(hObject, handles) % update handles
    end
catch ME
    beep
    handles.nes = oldnes;
end
set(hObject, 'String', num2str(handles.nes))


function etAsFun_Callback(hObject, eventdata, handles)
% hObject    handle to etAsFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ha üres a mezõ, letiltjuk az Evaluate gombot, ha van benne, engedélyezzük
if isempty(get(hObject, 'String'))
    set(handles.pbEval, 'Enable', 'off')
else
    set(handles.pbEval, 'Enable', 'on')
end

% Hints: get(hObject,'String') returns contents of etAsFun as text
%        str2double(get(hObject,'String')) returns contents of etAsFun as a double


% --- Executes on button press in pbEval.
function pbEval_Callback(hObject, eventdata, handles)
% hObject    handle to pbEval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


for p = 1 : length(handles.ConstNames) % elõször lokális változókban, megfelelõ néven elhelyezzük a konstansokat
    cmd = [handles.ConstNames{p} '=handles.ConstVals{p};'];
    eval(cmd)
end
Values = zeros(1, handles.nes); % veszünk egy vektort az autoszámolandó együtthatóknak
try
    Data = get(handles.tabEStates, 'Data');
    for p = 1 : handles.nes
        n = Data(p,1);
        Values(p) = eval(get(handles.etAsFun, 'String')); % és autoszámítás
        if isnan(Values(p)) || isinf(Values(p))
            error('Mathematical error.')
        end
    end
    Data(:,3) = abs(Values.');
    Data(:,4) = angle(Values.');
    Data(:,5) = real(Values.');
    Data(:,6) = imag(Values.');
    set(handles.tabEStates, 'Data', Data) % az értékek mehetnek a táblázatba
    handles.ECoeffs = Values;
    handles.IsNormalized = false; % normalizálási igény jelzése
    set(handles.pbOK, 'String', 'Normalize')
    plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
    xlabel(handles.axesE, 'Probability')
    ylabel(handles.axesE, 'Energy [J]')
    xlim(handles.axesE, 'auto')
    set(handles.etavE, 'String', '')
    guidata(hObject, handles) % update handles
catch ME % hiba esetén bip és messageboxban tájékoztatjuk a felhasználót a hibáról
    beep
    msgbox(ME.message)
end


% --- Executes when entered data in editable cell(s) in tabEStates.
function tabEStates_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabEStates (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%handles = guidata(hFigure);

try
    % elõször az adatok frissítése
    switch eventdata.Indices(2)
        case 3 % abszolút érték
            if isnan(eventdata.NewData) || imag(eventdata.NewData) || eventdata.NewData < 0 || eventdata.NewData > 1
                error('Wrong number.') % csak akkor fogadható el a szám, ha 0 és 1 közti valós
            end
            Data = get(hObject, 'Data'); % kinyerjük a táblázatból az adatokat
            handles.ECoeffs(eventdata.Indices(1)) = Data(eventdata.Indices(1),3) * exp(1i * Data(eventdata.Indices(1),4)); % a megfelelõ C együtthatót frissítjük
            Data(eventdata.Indices(1),5) = real(handles.ECoeffs(eventdata.Indices(1))); % majd a real
            Data(eventdata.Indices(1),6) = imag(handles.ECoeffs(eventdata.Indices(1))); % és imag cella adatát is
            set(hObject, 'Data', Data) % végül visszatöltjük a frissített adatokat a táblázatba
        case 4 % fázis
            if isnan(eventdata.NewData) || imag(eventdata.NewData)
                error('Wrong number.') % most már nem kell, hogy 0 és 1 közé essen
            end
            NewData = mod(eventdata.NewData, 2 * pi); % de a nem 0 és 2pi közé esés kedvéért modulo
            Data = get(hObject, 'Data');
            Data(eventdata.Indices(1), eventdata.Indices(2)) = NewData;
            handles.ECoeffs(eventdata.Indices(1)) = Data(eventdata.Indices(1),3) * exp(1i * Data(eventdata.Indices(1),4));
            Data(eventdata.Indices(1),5) = real(handles.ECoeffs(eventdata.Indices(1)));
            Data(eventdata.Indices(1),6) = imag(handles.ECoeffs(eventdata.Indices(1)));
            set(hObject, 'Data', Data)
        case 5 % valós rész
            if isnan(eventdata.NewData) || imag(eventdata.NewData)
                error('Wrong number.')
            end
            Data = get(hObject, 'Data');
            handles.ECoeffs(eventdata.Indices(1)) = Data(eventdata.Indices(1),5) + 1i * Data(eventdata.Indices(1),6); % itt nincs tartományellenõrzés,
            if abs(handles.ECoeffs(eventdata.Indices(1))) > 1 % viszont az új C együttható abszolútértékét ellenõrizzük, s ha szükséges,
                handles.ECoeffs(eventdata.Indices(1)) = handles.ECoeffs(eventdata.Indices(1)) / abs(handles.ECoeffs(eventdata.Indices(1))); % normálunk
                Data(eventdata.Indices(1),5) = real(handles.ECoeffs(eventdata.Indices(1)));
                Data(eventdata.Indices(1),6) = imag(handles.ECoeffs(eventdata.Indices(1)));
            end
            Data(eventdata.Indices(1),3) = abs(handles.ECoeffs(eventdata.Indices(1)));
            Data(eventdata.Indices(1),4) = angle(handles.ECoeffs(eventdata.Indices(1)));
            set(hObject, 'Data', Data)
        case 6 % imag rész
            if isnan(eventdata.NewData) || imag(eventdata.NewData)
                error('Wrong number.')
            end
            Data = get(hObject, 'Data');
            handles.ECoeffs(eventdata.Indices(1)) = Data(eventdata.Indices(1),5) + 1i * Data(eventdata.Indices(1),6);
            if abs(handles.ECoeffs(eventdata.Indices(1))) > 1
                handles.ECoeffs(eventdata.Indices(1)) = handles.ECoeffs(eventdata.Indices(1)) / abs(handles.ECoeffs(eventdata.Indices(1)));
                Data(eventdata.Indices(1),5) = real(handles.ECoeffs(eventdata.Indices(1)));
                Data(eventdata.Indices(1),6) = imag(handles.ECoeffs(eventdata.Indices(1)));
            end
            Data(eventdata.Indices(1),3) = abs(handles.ECoeffs(eventdata.Indices(1)));
            Data(eventdata.Indices(1),4) = angle(handles.ECoeffs(eventdata.Indices(1)));
            set(hObject, 'Data', Data)
    end % switch
    handles.IsNormalized = false; % normalizálási igény jelzése
    set(handles.pbOK, 'String', 'Normalize')
    plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
    xlabel(handles.axesE, 'Probability')
    ylabel(handles.axesE, 'Energy [J]')
    xlim(handles.axesE, 'auto')
    set(handles.etavE, 'String', '')
    guidata(hObject, handles)
catch ME % ha gond van,
    beep
    Data = get(hObject, 'Data');
    Data(eventdata.Indices(1), eventdata.Indices(2)) = eventdata.PreviousData; % visszaállítjuk az elõzõ értéket
    set(hObject, 'Data', Data)
end


% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.IsNormalized % akkor normált
    % módosítások alkalmazása
    handles.Problem.SetEnergy(handles.ECoeffs);
    handles.output = true;
    guidata(hObject, handles)
    uiresume(handles.figure1) % és kilépés
else % akkor nem normált
    % ezért most normálunk
    norma2 = handles.ECoeffs * handles.ECoeffs';
    if norma2 ~= 0 % zéróosztó elkerülése végett
        handles.ECoeffs = handles.ECoeffs / sqrt(norma2);
    else % 1 0 0 0 ... -ra állítjuk
        handles.ECoeffs(1) = 1;
        handles.ECoeffs(2 : handles.nes) = 0;
    end
    % s a táblázatba mentjük
    Data = get(handles.tabEStates, 'Data');
    Data(:,3) = abs(handles.ECoeffs.');
    Data(:,4) = angle(handles.ECoeffs.');
    Data(:,5) = real(handles.ECoeffs.');
    Data(:,6) = imag(handles.ECoeffs.');
    set(handles.tabEStates, 'Data', Data);
    handles.IsNormalized = true; % normáltság jelzése
    set(hObject, 'String', 'OK')
    plot(handles.axesE, abs(handles.ECoeffs).^2, handles.EValues, 'o') % plot
    xlim(handles.axesE, [0 1])
    hold(handles.axesE, 'on')
    avE = sum(abs(handles.ECoeffs).^2 .* handles.EValues) / sum(abs(handles.ECoeffs).^2);
    plot(handles.axesE, linspace(0, 1, 20), avE * ones(1, 20), 'r')
    hold(handles.axesE, 'off')
    xlabel(handles.axesE, 'Probability')
    ylabel(handles.axesE, 'Energy [J]')
    set(handles.etavE, 'String', num2str(avE))
    guidata(hObject, handles)
end


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = false;
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1)
% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = mdSetE_QM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject)
