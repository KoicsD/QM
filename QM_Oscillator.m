classdef QM_Oscillator < QuantumProblem
    properties
        omegha  % klasszikus mechanikai k�rfrekvencia
        D       % rug��lland�
        ks      % seg�dparam�ter
        
        H       % Hermite-polinomok egy�tthat�i
        xN      % hull�mf�ggv�ny norm�l�si egy�tthat�i
        pN      % impulzust�rbeli hull�mf�ggv�ny norm�l�si egy�tthat�i
        xHF     % Hermite-f�ggv�nyek
        pHF     % Hermite-f�ggv�nyek impulzust�rhez
    end
    
    methods(Static) % a sztringeket visszaad� sztatikus f�ggv�nyek
        
        function c_variant = Classic()                                      % klasszikus megfelel� oszt�lyneve
            c_variant = 'CM_Oscillator'; end
        
        function popup_name = Popup()                                       % a felugr� men�ben megjelen� n�v
            popup_name = 'Harmonic oscillator'; end
        
        function pot_string = StringPotential()                             % a potenci�lf�ggv�ny sztringk�nt
            pot_string = 'V(x) = m * ohm^2 * x^2 / 2; ohm^2 = D / m'; end
    end
    
    methods(Static)
        function obj = QM_Oscillator(varargin)                                                              % konstruktor
            
            % A probl�m�nak h�rom param�tere van:
            %   D:          rug��lland�
            %   m:          t�meg
            %   omegha:     klasszikus k�rfrekvencia
            %
            % Ezek k�z�l pontosan kett�t kell �tadni a konstruktornak, a
            % harmadikat a konstruktor automatikusan kisz�molja.
            
            switch nargin
                case 0
                    oomegha = 2 * pi * 8.65E+13;
                    DD = 48;
                    mm = DD / oomegha^2;
                    energy_states = zeros(1,9);
                    energy_states(1) = 1;
                case 2
                    if length(varargin{1}) ~= 2 || length(varargin{2}) ~= 2
                        error('Wrong arguments.')
                    end
                    for i = 1:2
                        if ~ischar(varargin{1}{i}) || ~strcmp(class(varargin{2}{i}), 'double')
                            error('Wrong arguments.')
                        end
                        switch varargin{1}{i}
                            case 'D'
                                DD = varargin{2}{i};
                            case 'm'
                                mm = varargin{2}{i};
                            case 'ohm'
                                oomegha = varargin{2}{i};
                            otherwise
                                error('Wrong arguments.')
                        end
                    end
                    if strcmp(varargin{1}{1}, varargin{1}{2})
                        error('Wrong arguments.')
                    end
                    if ~strcmp(varargin{1}{1}, 'D') && ~strcmp(varargin{1}{2}, 'D')
                        DD = oomegha^2 * m;
                    elseif ~strcmp(varargin{1}{1}, 'm') && ~strcmp(varargin{1}{2}, 'm')
                        mm = DD / oomegha^2;
                    elseif ~strcmp(varargin{1}{1}, 'ohm') && ~strcmp(varargin{1}{2}, 'ohm')
                        oomegha = sqrt(DD / mm);
                    end
                    energy_states = zeros(1,9);
                    energy_states(1) = 1;
                case 3
                    if length(varargin{1}) ~= 2 || length(varargin{2}) ~= 2
                        error('Wrong arguments.')
                    end
                    for i = 1:2
                        if ~ischar(varargin{1}{i}) || ~strcmp(class(varargin{2}{i}), 'double')
                            error('Wrong arguments.')
                        end
                        switch varargin{1}{i}
                            case 'D'
                                DD = varargin{2}{i};
                            case 'm'
                                mm = varargin{2}{i};
                            case 'ohm'
                                oomegha = varargin{2}{i};
                            otherwise
                                error('Wrong arguments.')
                        end
                    end
                    if ~strcmp(varargin{1}{1}, 'D') && ~strcmp(varargin{1}{2}, 'D')
                        DD = oomegha^2 * m;
                    elseif ~strcmp(varargin{1}{1}, 'm') && ~strcmp(varargin{1}{2}, 'm')
                        mm = DD / oomegha^2;
                    elseif ~strcmp(varargin{1}{1}, 'ohm') && ~strcmp(varargin{1}{2}, 'ohm')
                        oomegha = sqrt(DD / mm);
                    end
                    energy_states = varargin{3};
                otherwise
                    error('Wrong arguments.')
            end % switch nargin
            
            % numerikus �rt�kek ellen�rz�se
            if isnan(mm) || isnan(DD) || isnan(oomegha) || ...
                    isinf(mm) || isinf(DD) || isinf(oomegha) || ...
                    mm <= 0 || DD <= 0 || oomegha <= 0 ||...
                    imag(mm) || imag(DD) || imag(oomegha)
                error('Wrong arguments.')
            end
            
            obj@QuantumProblem(mm);
            obj.D = DD; obj.omegha = oomegha;
            obj.ks = sqrt(obj.m * obj.omegha / obj.hl);
            
            % energia
            nes = length(energy_states);
            n = 0 : nes - 1;
            obj.EnergyValues = obj.hl * obj.omegha * (n + 1 / 2);
            obj.EnergyStates = energy_states;
            
            % id�be�ll�t�sok
            obj.Time = 0;
            obj.Period = 4 * pi / obj.omegha;
            obj.TimeStep = obj.Period / (2 * nes - 1) / 3; % TimeStep
            
            % hely �s impulzus vizsg�lt �rt�kei
            X = sqrt(2 * nes - 1) * 1.2 / obj.ks;
            %P = (2 * nes - 1) * 5 * obj.hl * obj.ks / 2;
            %dx = 2 / obj.ks / 100;
            %dp = obj.hl * obj.ks / 60;
            P = sqrt(2 * nes - 1) * 1.2 * obj.ks * obj.hl;
            dx = obj.hl / P;
            dp = obj.hl / X;
            obj.PlaceValues = -X : dx : X;
            obj.MomentumValues = -P : dp : P;
            
            % potenci�l
            obj.Potential = obj.D * obj.PlaceValues.^2 / 2;
            
            % A hull�mfv �sszerak�sa bonyolult.
            % El�sz�r csak az egyes energia�llapotokhoz tartoz�
            % Hermite-f�ggv�nyeket rakjuk �ssze:
            
            %Hermite-polinom egy�tthat�i
            obj.H=zeros(nes);
            for n=0:nes-1
                if n==0
                    obj.H(1,1)=1;
                elseif n==1
                    obj.H(2,2)=2;
                end
                if n>=1 && n~=nes-1
                    indn=n+1;
                    for p=0:n
                        indp=p+1;
                        obj.H(indn+1,indp+1)=2*obj.H(indn,indp);
                        if p~=n
                            obj.H(indn+1,indp)=obj.H(indn+1,indp)-2*n*obj.H(indn-1,indp);
                        end
                    end
                end
            end
            %Norm�l�si faktorok
            obj.xN = zeros(1, nes);
            obj.pN = zeros(1, nes);
            for n=0:nes-1
                indn=n+1;
                if n==0
                    obj.xN(indn) = sqrt(obj.ks / sqrt(pi));
                    obj.pN(indn) = sqrt(1 / (sqrt(pi) * obj.ks * obj.hl));
                else
                    obj.xN(indn)=obj.xN(indn-1) / sqrt(2*n);
                    obj.pN(indn)= -1i * obj.pN(indn-1) / sqrt(2*n);
                end
            end
            %Gauss-profilok
            xGS = exp(-obj.ks^2 * obj.PlaceValues.^2 ./ 2); % helyhez
            pGS = exp(-obj.MomentumValues.^2. / (2 * obj.hl^2 * obj.ks^2)); %impulzushoz
            %v�gre �ssze�llnak a Hermite-f�ggv�nyek
            %assert(length(obj.PlaceValues) == length(obj.MomentumValues))   % assert
            obj.xHF = zeros(nes, length(obj.PlaceValues)); % helyhez
            obj.pHF = zeros(nes, length(obj.MomentumValues)); % impulzushoz
            for n = 0 : nes - 1
                indn = n + 1;
                for p = 0 : n % Hermite-polinomokba helyettes�t�s
                    indp = p + 1;
                    obj.xHF(indn, :) = obj.xHF(indn, :) + obj.H(indn, indp) * (obj.ks * obj.PlaceValues).^n;
                    obj.pHF(indn, :) = obj.pHF(indn, :) + obj.H(indn, indp) * (obj.MomentumValues ./ (obj.hl * obj.ks)).^n;
                end % majd �sszeszorz�s �s norm�l�s
                obj.xHF(indn, :) = obj.xN(indn) * xGS .* obj.xHF(indn, :);
                obj.pHF(indn, :) = obj.pN(indn) * pGS .* obj.pHF(indn, :);
            end
            
            % Csak mindezek ut�n j�het a hull�mf�ggv�ny kikever�se a
            % Hermitf�ggv�nyb�l az energia-egy�tthat�k seg�ts�g�vel:
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
            
        end % function QM_Oscillator -                                                                                  - konstruktor
    end % methods(Static)
    
    methods
        function [const_names, const_vals, dependency] = GetSpecConstants(obj)                                          % specifikus konstansok kinyer�se
            const_names = {'D', 'm', 'ohm'};
            const_vals = {obj.D, obj.m, obj.omegha};
            dependency = [false, false, true];
        end
        
        function [const_names, const_vals] = GetAllConstants(obj)                                                       % �sszes konstans kinyer�se
            const_names{1} = 'h';
            const_vals{1} = obj.h;
            const_names{2} = 'hl';
            const_vals{2} = obj.hl;
            const_names{3} = 'D';
            const_vals{3} = obj.D;
            const_names{4} = 'm';
            const_vals{4} = obj.m;
            const_names{5} = 'ohm';
            const_vals{5} = obj.omegha;
        end
        
        function ResetTime(obj)                                                                                         % vissza�ll�t�s kezdeti �ll�potba
            obj.Time = 0;
            
            % Az Hermite-f�ggv�nyek a konstruktornak h�la mentve vannak,
            % csup�n �jra ki kell bel�l�k keverni az �llapotf�gggv�nyt:
            nes = length(obj.EnergyValues);
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
        end
        
        function SetTime(obj, time)                                                                                     % id�l�p�s be�ll�t�sa, vissza�ll�t kezdeti �llapotba
            obj.Time = time;
            
            % Az Hermite-f�ggv�nyek a konstruktornak h�la mentve vannak,
            % csup�n �jra ki kell bel�l�k keverni az �llapotf�gggv�nyt:
            nes = length(obj.EnergyValues);
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
        end
        
        function StepForward(obj, count)                                                                                % id�l�p�s el�re
            if nargin ==1
                count = 1;
            end
            obj.Time = obj.Time + count * obj.TimeStep;
            % Time > Period, Time < 0 kezel�se?
            
            % Az Hermite-f�ggv�nyek a konstruktornak h�la mentve vannak,
            % csup�n �jra ki kell bel�l�k keverni az �llapotf�gggv�nyt:
            nes = length(obj.EnergyValues);
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
        end
        
        function StepReverse(obj, count)                                                                                % id�l�p�s h�tra
            if nargin == 1
                count = 1;
            end
            obj.Time = obj.Time - count * obj.TimeStep;
            % Time > Period, Time < 0 kezel�se?
            
            % Az Hermite-f�ggv�nyek a konstruktornak h�la mentve vannak,
            % csup�n �jra ki kell bel�l�k keverni az �llapotf�gggv�nyt:
            nes = length(obj.EnergyValues);
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
        end
        
        function [place, potential, param_names, param_units, param_values, dependency] = GetPotential(obj)             % potenci�l be�ll�t�sok kiolvas�sa
            
            % A met�dus arra biztatja a GUI-t, hogy a k�rfrekvenci�t
            % tekintse a m�sik k�t param�ter f�ggv�ny�nek.
            
            place = obj.PlaceValues;
            potential = obj.Potential;
            param_names{1} = 'D';
            param_units{1} = 'N/m';
            param_values{1} = obj.D;
            dependency(1) = false;
            param_names{2} = 'm';
            param_units{2} = 'kg';
            param_values{2} = obj.m;
            dependency(2) = false;
            param_names{3} = 'ohm';
            param_units{3} = 'rad/s';
            param_values{3} = obj.omegha;
            dependency(3) = true;
        end
        
        function [place, potential, dep_names, dep_units, dep_values] = CalcPotential(obj, param_names, param_values)   % potenci�l sz�m�t�s obj m�dos�t�sa n�lk�l
            
            % A h�rom param�ter k�z�l csak kett�t kell megadni, a
            % harmadikat a met�dus automatikusan sz�m�tja.
            
            % el�sz�r ellen�rz�s
            if length(param_names) ~= length(param_values) || length(param_names) ~= 2 || strcmp(param_names{1}, param_names{2})
                error('Wrong arguments.')
            end
            for i = 1:2
                switch param_names{i}
                    case 'D'
                        DD = param_values{i};
                    case 'm'
                        mm = param_values{i};
                    case 'ohm'
                        oomegha = param_values{i};
                    otherwise
                        error('Wrong arguments.')
                end
            end
            % majd k�t param�terb�l a harmadik kisz�m�t�sa �s visszaad�sa
            if ~strcmp(param_names{1}, 'D') && ~strcmp(param_names{2}, 'D')
                dep_names{1} = 'D';
                dep_units{1} = 'N/m';
                DD = oomegha^2 * mm;
                dep_values{1} = DD;
            elseif ~strcmp(param_names{1}, 'm') && ~strcmp(param_names{2}, 'm')
                dep_names{1} = 'm';
                dep_units{1} = 'kg';
                mm = DD / oomegha^2;
                dep_values{1} = mm;
            elseif ~strcmp(param_names{1}, 'ohm') && ~strcmp(param_names{2}, 'ohm')
                dep_names{1} = 'ohm';
                dep_units{1} = 'rad/s';
                oomegha = sqrt(DD / mm);
                dep_values{1} = oomegha;
            end
            
            % numerikus �rt�kek ellen�rz�se
            if isnan(mm) || isnan(DD) || isnan(oomegha) || ...
                    isinf(mm) || isinf(DD) || isinf(oomegha) || ...
                    mm <= 0 || DD <= 0 || oomegha <= 0 ||...
                    imag(mm) || imag(DD) || imag(oomegha)
                error('Wrong arguments.')
            end
            
            % majd az �j hely�rt�kek �s potenci�l�rt�kek sz�m�t�sa,
            % visszaad�sa:
            kks = sqrt(mm * oomegha / obj.hl);
            nes = length(obj.EnergyStates);
            X = sqrt(2 * nes - 1) * 1.2 / kks;
            %P = (2 * nes - 1) * 5 * obj.hl * kks / 2;
            %dx = 2 / kks / 100;
            P = sqrt(2 * nes - 1) * 1.2 * kks * obj.hl;
            dx = obj.hl / P;
            place = -X : dx : X;
            potential = DD * place.^2 / 2;
        end % function CalcPotential -                                                                                  - potenci�l sz�m�t�sa obj m�dos�t�sa n�lk�l
        
        function [place, potential, dep_names, dep_units, dep_values] = SetPotential(obj, param_names, param_values)    % potenci�l be�ll�t�sa
            
            % Itt is csak k�t param�tert kell megadni a h�rom k�z�l.
            
            % el�sz�r a param�terek kezel�se
            if length(param_names) ~= length(param_values) || length(param_names) ~= 2 || strcmp(param_names{1}, param_names{2})
                error('Wrong parameters!')
            end
            for i = 1:2
                switch param_names{i}
                    case 'D'
                        DD = param_values{i};
                    case 'm'
                        mm = param_values{i};
                    case 'ohm'
                        oomegha = param_values{i};
                    otherwise
                        error('Wrong arguments!')
                end
            end
            if ~strcmp(param_names{1}, 'D') && ~strcmp(param_names{2}, 'D')
                dep_names{1} = 'D';
                dep_units{1} = 'N/m';
                DD = obj.omegha^2 * mm;
                dep_values{1} = DD;
            elseif ~strcmp(param_names{1}, 'm') && ~strcmp(param_names{2}, 'm')
                dep_names{1} = 'm';
                dep_units{1} = 'kg';
                mm = DD / oomegha^2;
                dep_values{1} = mm;
            elseif ~strcmp(param_names{1}, 'ohm') && ~strcmp(param_names{2}, 'ohm')
                dep_names{i} = 'ohm';
                dep_units{1} = 'rad/s';
                oomegha = sqrt(DD / mm);
                dep_values{i} = oomegha;
            end
            
            % numerikus �rt�kek ellen�rz�se
            if isnan(mm) || isnan(DD) || isnan(oomegha) || ...
                    isinf(mm) || isinf(DD) || isinf(oomegha) || ...
                    mm <= 0 || DD <= 0 || oomegha <= 0 ||...
                    imag(mm) || imag(DD) || imag(oomegha)
                error('Wrong arguments.')
            end
            
            % be�r�s az objektumba
            obj.D = DD; obj.m = mm; obj.omegha = oomegha;
            obj.ks = sqrt(obj.m * obj.omegha / obj.hl);
            
            % majd az objektumot a friss param�terekhez igaz�tjuk
            % el�sz�t az energi�t
            nes = length(obj.EnergyStates);
            n = 0 : nes - 1;
            obj.EnergyValues = obj.hl * obj.omegha * (n + 1 / 2);
            
            % majd az id�t
            obj.Time = 0;
            obj.Period = 4 * pi / obj.omegha;
            obj.TimeStep = obj.Period / (2 * nes - 1) / 3; % TimeStep
            
            % azt�n a hely �s impulzus tartom�nyt
            X = sqrt(2 * nes - 1) * 4 / (3 * obj.ks);
            %P = (2 * nes - 1) * 5 * obj.hl * obj.ks / 2;
            %dx = 2 / obj.ks / 100;
            %dp = obj.hl * obj.ks / 60;
            P = sqrt(2 * nes - 1) * 4 * obj.ks * obj.hl / 3;
            dx = obj.hl / P;
            dp = obj.hl / X;
            obj.PlaceValues = -X : dx : X;
            obj.MomentumValues = -P : dp : P;
            
            % azt�n a potenci�lt
            obj.Potential = obj.D * obj.PlaceValues.^2 / 2;
            
            % csak ezut�n gondolhatunk �jra hull�mf�ggv�nyre
            %Gauss-profilok
            xGS = exp(-obj.ks^2 * obj.PlaceValues.^2 ./ 2); % helyhez
            pGS = exp(-obj.MomentumValues.^2. / (2 * obj.hl^2 * obj.ks^2)); %impulzushoz
            %Hermite-f�ggv�nyek
            %assert(length(obj.PlaceValues) == length(obj.MomentumValues))   % assert
            obj.xHF = zeros(nes, length(obj.PlaceValues)); % helyhez
            obj.pHF = zeros(nes, length(obj.MomentumValues)); % impulzushoz
            for n = 0 : nes - 1
                indn = n + 1;
                for p = 0 : n % Hermite-polinomokba helyettes�t�s
                    indp = p + 1;
                    obj.xHF(indn, :) = obj.xHF(indn, :) + obj.H(indn, indp) * (obj.ks * obj.PlaceValues).^n;
                    obj.pHF(indn, :) = obj.pHF(indn, :) + obj.H(indn, indp) * (obj.MomentumValues ./ (obj.hl * obj.ks)).^n;
                end % majd �sszeszorz�s �s norm�l�s
                obj.xHF(indn, :) = obj.xN(indn) * xGS .* obj.xHF(indn, :);
                obj.pHF(indn, :) = obj.pN(indn) * pGS .* obj.pHF(indn, :);
            end
            
            % Csak mindezek ut�n j�het a hull�mf�ggv�ny kikever�se a
            % Hermitf�ggv�nyb�l az energia-egy�tthat�k seg�ts�g�vel:
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
            
            place = obj.PlaceValues;
            potential = obj.Potential;
        end % function Setpotential -                                                                                   - potenci�l be�ll�t�sa
        
        function [indexes, energy_values] = CalcEnergy(obj, energy_states)                                              % energia�rt�kek lek�rdez�se egy esetleges �j kezdeti energia�llapothoz
            nes = length(energy_states);
            indexes = 0 : nes - 1;
            energy_values = obj.hl * obj.omegha * (indexes + 1 / 2);
        end
        
        function [indexes, energy_values] = SetEnergy(obj, energy_states)                                               % kezdeti energia�llapot be�ll�t�sa
            nes = length(energy_states);
            indexes = 0 : nes - 1;
            if ~(isequal(isnan(energy_states), zeros(1, nes)) || isequal(isnan(energy_states), zeros(nes, 1)))
                error('One energy-coefficient is NaN.')
            end
            if ~(isequal(isinf(energy_states), zeros(1, nes)) || isequal(isinf(energy_states), zeros(nes, 1)))
                error('One energy-coefficient is Inf.')
            end
            if (isequal(energy_states, zeros(1, nes)) || isequal(energy_states, zeros(nes, 1)))
                error('All energy-coefficient is zero.')
            end
            obj.EnergyValues = obj.hl * obj.omegha * (indexes + 1 / 2);
            obj.EnergyStates = energy_states;
            
            % id�
            obj.Time = 0;
            obj.Period = 4 * pi / obj.omegha;
            obj.TimeStep = obj.Period / (2 * nes - 1) / 3;
            
            % hely- �s impulzustartom�ny
            X = sqrt(2 * nes - 1) * 1.2 / obj.ks;
            %P = (2 * nes - 1) * 5 * obj.hl * obj.ks / 2;
            %dx = 2 / obj.ks / 100;
            %dp = obj.hl * obj.ks / 60;
            P = sqrt(2 * nes - 1) * 1.2 * obj.ks * obj.hl;
            dx = obj.hl / P;
            dp = obj.hl / X;
            obj.PlaceValues = -X : dx : X;
            obj.MomentumValues = -P : dp : P;
            
            % potenci�l
            obj.Potential = obj.D * obj.PlaceValues.^2 / 2;
            
            assert(length(obj.xN) == length(obj.pN))
            if length(obj.xN) < nes % Hermite egy�tthat�kat �s norm�l�si faktorokat csak akkor gy�rtunk �jra, ha sz�ks�ges.
                %Hermite-polinom egy�tthat�i
                obj.H=zeros(nes);
                for n=0:nes-1
                    if n==0
                        obj.H(1,1)=1;
                    elseif n==1
                        obj.H(2,2)=2;
                    end
                    if n>=1 && n~=nes-1
                        indn=n+1;
                        for p=0:n
                            indp=p+1;
                            obj.H(indn+1,indp+1)=2*obj.H(indn,indp);
                            if p~=n
                                obj.H(indn+1,indp)=obj.H(indn+1,indp)-2*n*obj.H(indn-1,indp);
                            end
                        end
                    end
                end
                %Norm�l�si faktorok
                obj.xN = zeros(1, nes);
                obj.pN = zeros(1, nes);
                for n=0:nes-1
                    indn=n+1;
                    if n==0
                        obj.xN(indn) = sqrt(obj.ks / sqrt(pi));
                        obj.pN(indn) = sqrt(1 / (sqrt(pi) * obj.ks * obj.hl));
                    else
                        obj.xN(indn)=obj.xN(indn-1) / sqrt(2*n);
                        obj.pN(indn)=obj.pN(indn-1) / sqrt(2*n);
                    end
                end
            end % if length(obj.xN) < nes
            
            %Gauss-profilok
            xGS = exp(-obj.ks^2 * obj.PlaceValues.^2 ./ 2); % helyhez
            pGS = exp(-obj.MomentumValues.^2. / (2 * obj.hl^2 * obj.ks^2)); %impulzushoz
            %Hermite-f�ggv�nyek �ssze�ll�t�sa
            %assert(length(obj.PlaceValues) == length(obj.MomentumValues))   % assert
            obj.xHF = zeros(nes, length(obj.PlaceValues)); % helyhez
            obj.pHF = zeros(nes, length(obj.MomentumValues)); % impulzushoz
            for n = 0 : nes - 1
                indn = n + 1;
                for p = 0 : n % Hermite-polinomokba helyettes�t�s
                    indp = p + 1;
                    obj.xHF(indn, :) = obj.xHF(indn, :) + obj.H(indn, indp) * (obj.ks * obj.PlaceValues).^n;
                    obj.pHF(indn, :) = obj.pHF(indn, :) + obj.H(indn, indp) * (obj.MomentumValues ./ (obj.hl * obj.ks)).^n;
                end % majd �sszeszorz�s �s norm�l�s
                obj.xHF(indn, :) = obj.xN(indn) * xGS .* obj.xHF(indn, :);
                obj.pHF(indn, :) = obj.pN(indn) * pGS .* obj.pHF(indn, :);
            end
            
            % �s v�g�l a hull�mf�ggv�nyek
            %assert(size(obj.xHF) == size(obj.pHF));                             % assert
            obj.StateFunction = zeros(1, size(obj.xHF, 2));
            obj.MomentumFunction = zeros(1, size(obj.pHF, 2));
            for n = 0 : nes - 1
                indn = n + 1;
                obj.StateFunction = obj.StateFunction +... hely
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.xHF(indn, :);
                obj.MomentumFunction = obj.MomentumFunction +... impulzus
                    obj.EnergyStates(indn) * exp(-1i * obj.EnergyValues(indn) * obj.Time / obj.hl) * obj.pHF(indn, :);
            end
            
            energy_values = obj.EnergyValues;
        end % function SetEnergy -                                                                                      - kezdeti energia�llapot be�ll�t�sa
    end % methods
end % classdef