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
handles.output = false; % az alap�rtelmezett �rt�k hamis

% a probl�m�t r�gz�tj�k, s kiolvassuk bel�le a param�tereket
handles.Problem = varargin{1}; % els� argumentum a probl�maobjektum
handles.ProblemName = varargin{2}; % m�sodik a probl�ma neve
handles.IsQuantum = varargin{3}; % harmadik a t�pusa
handles.StringPotential = eval([handles.ProblemName '.StringPotential']); % a potenci�l sztringk�nt, hogy megjelen�thess�k az ablak tetej�n
set(handles.stPot, 'String', handles.StringPotential) % meg is jelen�tj�k
[x, V, handles.names, handles.units, handles.vals, handles.deps] = handles.Problem.GetPotential; % a param�terek s a potenci�l konkr�t kiolvas�sa
assert(isequal(length(handles.names), length(handles.units),...     assert: ugye names, units,
    length(handles.vals), length(handles.deps)))                %           vals �s deps egyforma hossz�s�g�
if handles.IsQuantum % majd ha a probl�ma kvantumos,
    [handles.ConstNames, handles.ConstValues] = handles.Problem.GetPhysConstants; % a QM �lland�k kiolvas�sa
else % ha nem, praktikus okokb�l akkor is defini�ljuk a cellat�mb�ket, melyekben t�roln�nk �ket,
    handles.ConstNames = {}; % csak ez esetben e t�mb�k �resek leszhek
    handles.ConstValues = {};
end
handles.nparam = length(handles.names); % s meg is sz�moljuk a QM �lland�kat
assert(handles.nparam == length(handles.vals) && handles.nparam == length(handles.deps)) % assert

% el�sz�r a be�rkezett adatnak megfelel� mennyis�g� sz�vegmez�t gy�rtunk
handles.stDep = []; % kezdetnek csak �res vektrorok, ez itt a statikus mez�k t�mbje a f�gg� v�ltoz�knak
handles.stIndep = []; % statikus mez�k a f�ggetlen param�tereknek
handles.etDep = []; % "szerkeszthet�" mez�k a f�gg� param�tereknek
handles.etIndep = []; % szerkeszthet� mez�k a f�ggetlen param�tereknek
vpos = 28; % ennek a f�gg�leges poz�ci�hoz van k�ze, mai napig nem �rtem a megjelen�s hely�nek pixelkoordin�t�it
ind = 1;
for i = 1 : handles.nparam % el�bb a f�ggetlen, param�tereknek gy�rtunk sz�vegmez�ket
    if ~handles.deps(i)
        % el�sz�r statikus sz�vegek l�trehoz�sa
        handles.stIndep(ind) = uicontrol(handles.Panel, 'Style', 'text', 'Tag', ['stIdnep' num2str(ind)],...
            'Position', [0 (vpos*10) 110 20], 'HorizontalAlignment', 'right');
        if isempty(handles.units{i})
            set(handles.stIndep(ind), 'String', [handles.names{i} ':']) % kett�spont a n�v ut�n
        else
            set(handles.stIndep(ind), 'String', [handles.names{i} ' [' handles.units{i} ']:']) % ha m�rt�kegys�g van, azt is hozz��rjuk
        end
        temp = {handles.names{i}, handles.units{i}};
        set(handles.stIndep(ind), 'UserData', temp) % a n�v �s a m�rt�kegys�g cellat�mbk�nt bemegy a UserData-ba is, hogy k�s�bb egyszer�bb legyen az �let�nk
         % majd a szerkeszthet� sz�vegmez�k
        handles.etIndep(ind) = uicontrol(handles.Panel, 'Style', 'edit', 'Tag', ['etIndep' num2str(ind)],...
            'CreateFcn', @(hObject, eventdata)mdSetPot_QM('et_CreateFcn', hObject, eventdata, guidata(hObject)),...
            'Position', [110 (vpos*10) 110 20], 'String', num2str(handles.vals{i}),...
            'HorizontalAlignment', 'left', 'Enable', 'on', 'UserData', handles.vals{i});
        vpos = vpos - 4;
        ind = ind + 1;
    end
end
ind = 1;
for j = 1 : handles.nparam % majd a f�gg� param�tereknek
    if handles.deps(j)
        % statikus
        handles.stDep(ind) = uicontrol(handles.Panel, 'Style', 'text', 'Tag', ['stDep' num2str(ind)],...
            'Position', [0 (vpos*10) 110 20], 'HorizontalAlignment', 'right');
        if isempty(handles.units{j})
            set(handles.stDep(ind), 'String', [handles.names{j} ':']) % csak kett�spont
        else
            set(handles.stDep(ind), 'String', [handles.names{j} ' [' handles.units{j} ']:']) % m�rt�kegys�g is
        end
        temp = {handles.names{j}, handles.units{j}};
        set(handles.stDep(ind), 'UserData', temp) % n�v �s egys�g UserData-ba
        % szerkeszthet�
        handles.etDep(ind) = uicontrol(handles.Panel, 'Style', 'edit', 'Tag', ['etDep' num2str(ind)],...
            'Position', [110 (vpos*10) 110 20], 'String', num2str(handles.vals{j}),...
            'HorizontalAlignment', 'left', 'Enable', 'off', 'UserData', handles.vals{j});
        vpos = vpos - 4;
        ind = ind + 1;
    end
end
handles.nDep = length(handles.etDep);
handles.nIndep = length(handles.etIndep);
assert(length(handles.stDep) == handles.nDep)             % assert: ugye stDep �s etDep ugyanannyian vannak?
assert(length(handles.stIndep) == handles.nIndep)         % assert: ugye stIndep �s etIndep ugyanannyian vannak?
assert(length(handles.names) == handles.nDep + handles.nIndep) % assert: ugye names teljes m�rete nDep + nIndep?

% majd be�ll�tjuk a callback f�ggv�nyt, �s rendezz�k a handles-ben l�v�
% adatokat:
%handles.names = cell(1, length(handles.etIndep));
%handles.vals = cell(1, length(handles.etIndep));
ind = 1;
for i = 1 : length(handles.etIndep) % el�re ker�lnek a f�ggetlen adatok
    set(handles.etIndep(i), 'Callback', @(hObject, callbackdata)et_Callback(handles.etIndep(i), [], guidata(hObject), i)) % callback
    temp = get(handles.stIndep(i), 'UserData'); % most lesz k�nnyebb az �let�nk
    handles.names{ind} = temp{1}; % nevek
    handles.units{ind} = temp{2}; % m�rt�kegys�gek
    handles.vals{ind} = get(handles.etIndep(i), 'UserData'); % sz�m�rt�kek
    handles.deps(ind) = false; % f�gg�s�g
    ind = ind + 1;
end
for j = 1 : length(handles.etDep) % ut�nuk a f�gg�ek
    temp = get(handles.stDep(j), 'UserData'); % ahogy most is k�nnyebb lesz
    handles.names{ind} = temp{1};
    handles.units{ind} = temp{2};
    handles.vals{ind} = get(handles.etDep(j), 'UserData');
    handles.deps(ind) = true;
    ind = ind + 1;
end

% v�g�l plot
plot(handles.axes, x, V)
xlabel(handles.axes, 'Place [m]')
ylabel(handles.axes, 'Potential [J]')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mdSetPot_QM wait for user response (see UIRESUME)
uiwait(handles.figure1);


function et_Callback(hObject, ~, handles, index)
try
    % el�sz�r kiolvassuk cella t�mb�kbe a neveket �s �rt�keket
    indep_names = cell(1, length(handles.etIndep));
    indep_units = cell(1, length(handles.etIndep));
    indep_vals = cell(1, length(handles.etIndep));
    for p = 1 : length(handles.etIndep)
        temp = get(handles.stIndep(p), 'UserData'); % most is k�nnyebb az �let
        indep_names{p} = temp{1};
        indep_units{p} = temp{2};
        indep_vals{p} = get(handles.etIndep(p), 'UserData'); % a legt�bb esetben a UserData-ban double form�tumban m�r rendelkez�sre �ll az �rt�k
    end
    for p = 1 : length(handles.ConstNames)
        eval([handles.ConstNames{p} '=' num2str(handles.ConstValues{p}) ';'])
    end
    indep_vals{index} = eval(get(hObject, 'String')); % kiv�ve az �pp �t�rt mez�t, mert ott m�g nem friss�lt a UserData. Itt a legval�sz�n�bb a kiv�tel.
    if ~strcmp(class(indep_vals{index}), 'double') || length(indep_vals{index}) > 1 % az�rt ellen�rizz�k, hogy 1x1-es double-e
        error('Wrong string.')
    end
    set(hObject, 'String', num2str(indep_vals{index}))
    % megh�vjuk r�juk a potenci�lsz�m�t�t, s az �rt�keket be�rjuk a mez�kbe
    [x, V, dep_names, dep_units, dep_vals] = handles.Problem.CalcPotential(indep_names, indep_vals); % itt is lehet kiv�tel, ha a probl�maobjektum nem fogadja el az adatokat
    assert(length(handles.etDep) == length(dep_names) && length(handles.etDep) == length(dep_vals)) % assert
    for i = 1 : length(handles.etDep)
        set(handles.etDep(i), 'String', num2str(dep_vals{i}))
    end
    
    % ha minden j�l ment, menthetj�k a UserDataba az adatokat, s
    % fel�l�rhatjuk a c�mk�ket, ha esetleg m�s sorrendben adta volna vissza
    % az �rt�keket a CalcPotential f�ggv�ny
    set(hObject, 'UserData', str2double(get(hObject, 'String'))) % el�bb a user �ltal �t�rtat mentj�k
    for i = 1 : length(handles.etDep) % majd a sz�m�tottakat
        if ~isempty(dep_units{i}) % a c�mke friss�t�se
            set(handles.stDep(i), 'String', [dep_names{i} ' [' dep_units{i} ']:'])
        else
            set(handles.stDep(i), 'String', [dep_names{i}  ':'])
        end
        temp = {dep_names{i}, dep_units{i}};
        set(handles.stDep(i), 'UserData', temp) % n�v �s egys�g ment�se a c�mke userdata-j�ba
        set(handles.etDep(i), 'UserData', str2double(get(handles.etDep(i), 'String'))) % adat ment�se a mez� UserData-j�ba
    end
    
    % v�g�l a handlesbe is elmentj�k a sikeresen �tpasszolt �rt�keket
    
    %assert(isequal(handles.deps(1 : handles.nIndep), false(1, handles.nIndep)))         % assert: ugye deps nIndep-ig terjed� r�sze v�gig hamis?
    %assert(isequal(handles.deps(handles.nIndep + 1 : end), true(1, handles.nDep)))      % assert: ugye deps nIndep ut�ni r�sze nDep hossz�, �s v�gig igaz?
    
    handles.names = [indep_names, dep_names];    % names friss�t�se
    handles.units = [indep_units, dep_units];    % units friss�t�se
    handles.vals = [indep_vals, dep_vals];      % vals friss�t�se
    guidata(handles.figure1, handles)
    
    % plot
    plot(handles.axes, x, V)
    xlabel(handles.axes, 'Place [m]')
    ylabel(handles.axes, 'Potential [J]')
    
catch ME
    beep
    % hiba eset�n visszat�ltj�k a mez�kbe a UserDatajukban t�rolt �rt�keket
    set(hObject, 'String', num2str(get(hObject, 'UserData'))) % user �ltal �t�rt
    for i = 1 : length(handles.etDep)
        set(handles.etDep(i), 'String', num2str(get(handles.etDep(i), 'UserData'))) % sz�m�tott
    end
end

% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, ~, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% akkor most alkalmazzuk a param�tereket, s igazzal visszat�r�nk
handles.Problem.SetPotential(handles.names(1 : handles.nIndep), handles.vals(1 : handles.nIndep));
handles.output = true;
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, ~, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hamissal visszat�r�nk
handles.output = false;
guidata(hObject, handles)
uiresume(handles.figure1)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% az alap�rtelmezett �rt�kkel visszat�r�nk
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
