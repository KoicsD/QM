function varargout = mdSetPot_QM(varargin)
% MDSETPOT_QM M-file for mdSetPot_QM.fig
%      MDSETPOT_QM, by itself, creates a new MDSETPOT_QM or raises the existing
%      singleton*.
%
%      H = MDSETPOT_QM returns the handle to a new MDSETPOT_QM or the handle to
%      the existing singleton*.
%
%      MDSETPOT_QM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MDSETPOT_QM.M with the given input arguments.
%
%      MDSETPOT_QM('Property','Value',...) creates a new MDSETPOT_QM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mdSetPot_QM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mdSetPot_QM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mdSetPot_QM

% Last Modified by GUIDE v2.5 11-May-2015 18:37:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdSetPot_QM_OpeningFcn, ...
                   'gui_OutputFcn',  @mdSetPot_QM_OutputFcn, ...
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
function et_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etAvE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes just before mdSetPot_QM is made visible.
function mdSetPot_QM_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdSetPot_QM (see VARARGIN)

% Choose default command line output for mdSetPot_QM
handles.output = false; % az alapértelmezett érték hamis

% a problémát rögzítjük, s kiolvassuk belõle a paramétereket
handles.Problem = varargin{1}; % elsõ argumentum a problémaobjektum
handles.ProblemName = varargin{2}; % második a probléma neve
handles.IsQuantum = varargin{3}; % harmadik a típusa
handles.StringPotential = eval([handles.ProblemName '.StringPotential']); % a potenciál sztringként, hogy megjeleníthessük az ablak tetején
set(handles.stPot, 'String', handles.StringPotential) % meg is jelenítjük
[x, V, handles.names, handles.units, handles.vals, handles.deps] = handles.Problem.GetPotential; % a paraméterek s a potenciál konkrét kiolvasása
assert(isequal(length(handles.names), length(handles.units),...     assert: ugye names, units,
    length(handles.vals), length(handles.deps)))                %           vals és deps egyforma hosszúságú
if handles.IsQuantum % majd ha a probléma kvantumos,
    [handles.ConstNames, handles.ConstValues] = handles.Problem.GetPhysConstants; % a QM állandók kiolvasása
else % ha nem, praktikus okokból akkor is definiáljuk a cellatömböket, melyekben tárolnánk õket,
    handles.ConstNames = {}; % csak ez esetben e tömbök üresek leszhek
    handles.ConstValues = {};
end
handles.nparam = length(handles.names); % s meg is számoljuk a QM állandókat
assert(handles.nparam == length(handles.vals) && handles.nparam == length(handles.deps)) % assert

% elõször a beérkezett adatnak megfelelõ mennyiségû szövegmezõt gyártunk
handles.stDep = []; % kezdetnek csak üres vektrorok, ez itt a statikus mezõk tömbje a függõ változóknak
handles.stIndep = []; % statikus mezõk a független paramétereknek
handles.etDep = []; % "szerkeszthetõ" mezõk a függõ paramétereknek
handles.etIndep = []; % szerkeszthetõ mezõk a független paramétereknek
vpos = 28; % ennek a függõleges pozícióhoz van köze, mai napig nem értem a megjelenés helyének pixelkoordinátáit
ind = 1;
for i = 1 : handles.nparam % elõbb a független, paramétereknek gyártunk szövegmezõket
    if ~handles.deps(i)
        % elõször statikus szövegek létrehozása
        handles.stIndep(ind) = uicontrol(handles.Panel, 'Style', 'text', 'Tag', ['stIdnep' num2str(ind)],...
            'Position', [0 (vpos*10) 110 20], 'HorizontalAlignment', 'right');
        if isempty(handles.units{i})
            set(handles.stIndep(ind), 'String', [handles.names{i} ':']) % kettõspont a név után
        else
            set(handles.stIndep(ind), 'String', [handles.names{i} ' [' handles.units{i} ']:']) % ha mértékegység van, azt is hozzáírjuk
        end
        temp = {handles.names{i}, handles.units{i}};
        set(handles.stIndep(ind), 'UserData', temp) % a név és a mértékegység cellatömbként bemegy a UserData-ba is, hogy késõbb egyszerûbb legyen az életünk
         % majd a szerkeszthetõ szövegmezõk
        handles.etIndep(ind) = uicontrol(handles.Panel, 'Style', 'edit', 'Tag', ['etIndep' num2str(ind)],...
            'CreateFcn', @(hObject, eventdata)mdSetPot_QM('et_CreateFcn', hObject, eventdata, guidata(hObject)),...
            'Position', [110 (vpos*10) 110 20], 'String', num2str(handles.vals{i}),...
            'HorizontalAlignment', 'left', 'Enable', 'on', 'UserData', handles.vals{i});
        vpos = vpos - 4;
        ind = ind + 1;
    end
end
ind = 1;
for j = 1 : handles.nparam % majd a függõ paramétereknek
    if handles.deps(j)
        % statikus
        handles.stDep(ind) = uicontrol(handles.Panel, 'Style', 'text', 'Tag', ['stDep' num2str(ind)],...
            'Position', [0 (vpos*10) 110 20], 'HorizontalAlignment', 'right');
        if isempty(handles.units{j})
            set(handles.stDep(ind), 'String', [handles.names{j} ':']) % csak kettõspont
        else
            set(handles.stDep(ind), 'String', [handles.names{j} ' [' handles.units{j} ']:']) % mértékegység is
        end
        temp = {handles.names{j}, handles.units{j}};
        set(handles.stDep(ind), 'UserData', temp) % név és egység UserData-ba
        % szerkeszthetõ
        handles.etDep(ind) = uicontrol(handles.Panel, 'Style', 'edit', 'Tag', ['etDep' num2str(ind)],...
            'Position', [110 (vpos*10) 110 20], 'String', num2str(handles.vals{j}),...
            'HorizontalAlignment', 'left', 'Enable', 'off', 'UserData', handles.vals{j});
        vpos = vpos - 4;
        ind = ind + 1;
    end
end
handles.nDep = length(handles.etDep);
handles.nIndep = length(handles.etIndep);
assert(length(handles.stDep) == handles.nDep)             % assert: ugye stDep és etDep ugyanannyian vannak?
assert(length(handles.stIndep) == handles.nIndep)         % assert: ugye stIndep és etIndep ugyanannyian vannak?
assert(length(handles.names) == handles.nDep + handles.nIndep) % assert: ugye names teljes mérete nDep + nIndep?

% majd beállítjuk a callback függvényt, és rendezzük a handles-ben lévõ
% adatokat:
%handles.names = cell(1, length(handles.etIndep));
%handles.vals = cell(1, length(handles.etIndep));
ind = 1;
for i = 1 : length(handles.etIndep) % elõre kerülnek a független adatok
    set(handles.etIndep(i), 'Callback', @(hObject, callbackdata)et_Callback(handles.etIndep(i), [], guidata(hObject), i)) % callback
    temp = get(handles.stIndep(i), 'UserData'); % most lesz könnyebb az életünk
    handles.names{ind} = temp{1}; % nevek
    handles.units{ind} = temp{2}; % mértékegységek
    handles.vals{ind} = get(handles.etIndep(i), 'UserData'); % számértékek
    handles.deps(ind) = false; % függõség
    ind = ind + 1;
end
for j = 1 : length(handles.etDep) % utánuk a függõek
    temp = get(handles.stDep(j), 'UserData'); % ahogy most is könnyebb lesz
    handles.names{ind} = temp{1};
    handles.units{ind} = temp{2};
    handles.vals{ind} = get(handles.etDep(j), 'UserData');
    handles.deps(ind) = true;
    ind = ind + 1;
end

% végül plot
plot(handles.axes, x, V)
xlabel(handles.axes, 'Place [m]')
ylabel(handles.axes, 'Potential [J]')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mdSetPot_QM wait for user response (see UIRESUME)
uiwait(handles.figure1);


function et_Callback(hObject, ~, handles, index)
try
    % elõször kiolvassuk cella tömbökbe a neveket és értékeket
    indep_names = cell(1, length(handles.etIndep));
    indep_units = cell(1, length(handles.etIndep));
    indep_vals = cell(1, length(handles.etIndep));
    for p = 1 : length(handles.etIndep)
        temp = get(handles.stIndep(p), 'UserData'); % most is könnyebb az élet
        indep_names{p} = temp{1};
        indep_units{p} = temp{2};
        indep_vals{p} = get(handles.etIndep(p), 'UserData'); % a legtöbb esetben a UserData-ban double formátumban már rendelkezésre áll az érték
    end
    for p = 1 : length(handles.ConstNames)
        eval([handles.ConstNames{p} '=' num2str(handles.ConstValues{p}) ';'])
    end
    indep_vals{index} = eval(get(hObject, 'String')); % kivéve az épp átírt mezõt, mert ott még nem frissült a UserData. Itt a legvalószínûbb a kivétel.
    if ~strcmp(class(indep_vals{index}), 'double') || length(indep_vals{index}) > 1 % azért ellenõrizzük, hogy 1x1-es double-e
        error('Wrong string.')
    end
    set(hObject, 'String', num2str(indep_vals{index}))
    % meghívjuk rájuk a potenciálszámítót, s az értékeket beírjuk a mezõkbe
    [x, V, dep_names, dep_units, dep_vals] = handles.Problem.CalcPotential(indep_names, indep_vals); % itt is lehet kivétel, ha a problémaobjektum nem fogadja el az adatokat
    assert(length(handles.etDep) == length(dep_names) && length(handles.etDep) == length(dep_vals)) % assert
    for i = 1 : length(handles.etDep)
        set(handles.etDep(i), 'String', num2str(dep_vals{i}))
    end
    
    % ha minden jól ment, menthetjük a UserDataba az adatokat, s
    % felülírhatjuk a címkéket, ha esetleg más sorrendben adta volna vissza
    % az értékeket a CalcPotential függvény
    set(hObject, 'UserData', str2double(get(hObject, 'String'))) % elõbb a user által átírtat mentjük
    for i = 1 : length(handles.etDep) % majd a számítottakat
        if ~isempty(dep_units{i}) % a címke frissítése
            set(handles.stDep(i), 'String', [dep_names{i} ' [' dep_units{i} ']:'])
        else
            set(handles.stDep(i), 'String', [dep_names{i}  ':'])
        end
        temp = {dep_names{i}, dep_units{i}};
        set(handles.stDep(i), 'UserData', temp) % név és egység mentése a címke userdata-jába
        set(handles.etDep(i), 'UserData', str2double(get(handles.etDep(i), 'String'))) % adat mentése a mezõ UserData-jába
    end
    
    % végül a handlesbe is elmentjük a sikeresen átpasszolt értékeket
    
    %assert(isequal(handles.deps(1 : handles.nIndep), false(1, handles.nIndep)))         % assert: ugye deps nIndep-ig terjedõ része végig hamis?
    %assert(isequal(handles.deps(handles.nIndep + 1 : end), true(1, handles.nDep)))      % assert: ugye deps nIndep utáni része nDep hosszú, és végig igaz?
    
    handles.names = [indep_names, dep_names];    % names frissítése
    handles.units = [indep_units, dep_units];    % units frissítése
    handles.vals = [indep_vals, dep_vals];      % vals frissítése
    guidata(handles.figure1, handles)
    
    % plot
    plot(handles.axes, x, V)
    xlabel(handles.axes, 'Place [m]')
    ylabel(handles.axes, 'Potential [J]')
    
catch ME
    beep
    % hiba esetén visszatöltjük a mezõkbe a UserDatajukban tárolt értékeket
    set(hObject, 'String', num2str(get(hObject, 'UserData'))) % user által átírt
    for i = 1 : length(handles.etDep)
        set(handles.etDep(i), 'String', num2str(get(handles.etDep(i), 'UserData'))) % számított
    end
end

% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, ~, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% akkor most alkalmazzuk a paramétereket, s igazzal visszatérünk
handles.Problem.SetPotential(handles.names(1 : handles.nIndep), handles.vals(1 : handles.nIndep));
handles.output = true;
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, ~, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hamissal visszatérünk
handles.output = false;
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% az alapértelmezett értékkel visszatérünk
uiresume(handles.figure1)

% Hint: delete(hObject) closes the figure
% delete(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = mdSetPot_QM_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject)
