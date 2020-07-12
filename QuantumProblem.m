classdef QuantumProblem < handle
    properties(Constant)
        h = 6.628E-34           % Planck-�lland�
        hl = 6.628E-34/(2*pi)   % reduk�lt Planck-�lland� [J * s]
    end
    properties
        Time                    % rendszerid�
        TimeStep                % id�l�p�s
        Period                  % a rendszer peri�dusideje
        
        m                       % a r�szecske t�mege
        
        EnergyValues            % energia�rt�kek
        EnergyStates            % energia�rt�kek kezdeti komplex egy�tthat�i
        PlaceValues             % hely�rt�kek
        MomentumValues          % impulzus�rt�kek
        Potential               % potenci�lf�ggv�ny �rt�kei
        StateFunction           % hull�mf�ggv�ny
        MomentumFunction        % hull�mf�ggv�ny impulzust�rben
    end
    
    methods(Static)
        function obj = QuantumProblem(mm) % konstruktor
            obj.m = mm;
        end
        % Ett�l f�ggetlen�l az aloszt�lyoknak sz�ks�g�k van saj�t
        % konstruktorra. Annak szintaktik�ja legyen:
        %
        %   ProblemName()
        %       Param�terek n�lk�l, alap�rtelmezett �rt�keket �ll�t be a
        %       probl�ma param�tereik�nt.
        %
        %   ProblemName(param_names, param_values)
        %       param_names:    cella vektor, mely a probl�ma param�tereinek
        %                       neveit tartalmazza
        %       param_values:   cella vektor, mely a param�terek �rt�keit
        %                       tartalmazza
        %
        %   ProblemName(param_names, param_values, energy_coeffs)
        %       energy_coeffs:  numerikus vektor, mely a kezd�
        %                       energia�llapotok komplex egy�tthat�it
        %                       tartalmazza
    end
    
    methods % egyszer�, helyben defini�lt lek�rdez� f�ggv�nyek (az aloszt�lyokban nem kell vel�k bajl�dni)
        
        function [const_names, const_values] = GetPhysConstants(obj)        % a fizikai �lland�k kinyer�se
            const_names = {'h', 'hl'}; const_values = {obj.h, obj.hl}; end
        
        function time = GetTime(obj)                                        % a pillanatnyi id� lek�rdez�se
            time = obj.Time; end
        
        function time_step = GetTimeStep(obj)                               % az id�l�p�s lek�rdez�se
            time_step = obj.TimeStep; end
        
        function SetTimeStep(obj, time_step)                                % kakukktoj�sk�nt egy be�ll�t� f�ggv�ny: az id�l�p�s be�ll�t�sa
            obj.TimeStep = time_step; end
        
        function period = GetPeriod(obj)                                    % a rendszer peri�dusidej�nek lek�rdez�se
            period = obj.Period; end
        
        function [place_values, state_function] = GetState(obj)             % hull�mf�ggv�ny kinyer�se
            place_values = obj.PlaceValues; state_function = obj.StateFunction; end
        
        function [momentum_values, momentum_function] = GetMomentum(obj)    % impulzust�rbeli hull�mf�ggv�ny kinyer�se
            momentum_values = obj.MomentumValues; momentum_function = obj.MomentumFunction; end
    end
    
    methods % 2 sorba ki nem f�r� lek�rdez� f�ggv�nyek
        
        function [indexes, energy_values, energy_states] = GetEnergy(obj)   % a kezdeti energia�llapot lek�rdez�se
            % indexes:          az enegria�rt�kek indexei
            % energy_values:    az energia�rt�keket tartalmaz� vektor
            % energy_states:    az energia�rt�kekhez tartoz� komplex
            %                   egy�tthat�kat tartalmaz� vektor
            indexes = 0 : length(obj.EnergyValues) - 1;
            energy_values = obj.EnergyValues;
            energy_states = obj.EnergyStates;
        end
        
        function [time, place, momentum, energy] = GetAverage(obj)          % az �tlag�rt�kek lek�rdez�se
            time = obj.Time;
            %place = ((obj.StateFunction .* obj.PlaceValues) * obj.StateFunction') / ...                  < Ksi | X | Ksi > /
            %    (obj.StateFunction * obj.StateFunction'); %                                                 <Ksi | Ksi>
            %momentum = ((obj.MomentumFunction .* obj.MomentumValues) * obj.MomentumFunction') / ...
            %    (obj.MomentumFunction * obj.MomentumFunction');
            %energy = ((obj.EnergyStates .* obj.EnergyValues) * obj.EnergyStates') / ...
            %    (obj.EnergyStates * obj.EnergyStates');
            place = sum(abs(obj.StateFunction).^2 .* obj.PlaceValues) / sum(abs(obj.StateFunction).^2);
            momentum = sum(abs(obj.MomentumFunction).^2 .* obj.MomentumValues) / sum(abs(obj.MomentumFunction).^2);
            energy = sum(abs(obj.EnergyStates).^2 .* obj.EnergyValues) / sum(abs(obj.EnergyStates).^2);
        end
    end
    
    methods(Abstract) % ezeket a f�ggv�nyeket minden aloszt�lyban defini�lni kell, en�lk�l az aloszt�ly nem p�ld�nyos�that�
        
        [const_names, const_vals, dependency] = GetSpecConstants(obj)                                           % a probl�ma param�tereinek kinyer�se
            % const_names:  cella vektor -- a param�terek bet�jelei sztringk�nt
            % const_vals:   cella vektor -- a param�terek �rt�kei SI egys�gben
            % dependency:   logikai vektor -- annak jelz�se, mely param�ter
            %                                 tekintend� a t�bbi f�ggv�ny�nek
            
        [const_names, const_vals] = GetAllConstants(obj)                                                        % a probl�ma param�tereinek �s a fizikai �lland�k egy�ttes kinyer�se
            % const_names:  cella vektor -- a param�terek bet�jelei sztringk�nt
            % const_vals:   cella vektor -- a param�terek �rt�kei SI egys�gben
            
            
        SetTime(obj, time)                                                                                      % az id� k�zvetlen �ll�t�sa
        StepForward(obj, count)                                                                                 % l�ptet�s el�re count id�l�p�st
        StepReverse(obj, count)                                                                                 % l�ptet�s h�tra count id�l�p�st
        ResetTime(obj)                                                                                          % a rendszer kezdeti �llapot�ba �ll�t�sa
            
        
        [place, potential, param_names, param_units, param_values, dependency] = GetPotential(obj)              % potenci�lf�ggv�ny lek�rdez�se
            % place:        a helykoordin�t�kat tartalmaz� vektor
            % potenctial:   a potenci�lf�ggv�ny �rt�keit tartalmaz� vektor
            % param_names:  cella vektor -- a rendszer param�tereinek nevei
            % param_values: cella vektor -- a param�terek �rt�kei
            % dependency:   logikai vektor -- a param�ter a t�bbi f�ggv�nye-e
            
        [place, potential, dep_names, dep_units, dep_values] = CalcPotential(obj, param_names, param_values)    % az �j potenci�lf�ggv�ny sz�m�t�sa (obj m�dos�t�sa n�lk�l)
            % param_names:  cella vektor -- a rendszer f�ggetlen param�tereinek nevei
            % param_values: cella vektor -- a f�ggetlen param�terek �rt�kei
            % place:        a helykoordin�t�kat tartalmaz� vektor
            % potential:    a sz�m�tott potenci�lf�ggv�nyt tartalmaz� vektor
            % dep_names:    a sz�m�tott param�terek nevei cella vektork�nt
            % dep_values:   a sz�m�tott param�terek �rt�kei
        
        [place, potential, dep_names, dep_units, dep_values] = SetPotential(obj, param_names, param_values)     % a potenci�lf�ggv�ny m�dos�t�sa
            % param_names:  a rendszer f�ggetlen param�terei cella vektork�nt
            % param_values: a f�ggetlen param�terek �rt�kei cella vektork�nt
            % place:        a helykoordin�t�kat tartalmaz� vektor
            % potential:    az �j potenci�lf�ggv�ny �rt�keit tartalmaz� vektor
            % dep_names:    a sz�m�tott param�terek nevei cella vektork�nt
            % dep_values:   a sz�m�tott param�terek �rt�kei
        
        [indexes, energy_values] = CalcEnergy(obj, energy_states)                                               % energia�rt�kek lek�rdez�se egy esetleges �j kezdeti energia�llapothoz
        [indexes, energy_values] = SetEnergy(obj, energy_states)                                                % kezdeti energia�llapot m�dos�t�sa
            % energy_values: az energia�rt�keket tartalmaz� vektor
            % energy_states: az energia�rt�kekhez tartoz� komplex egy�tthat�kat tartalmaz� vektor
    end % methods(Abstract)
    
    methods(Abstract, Static) % ez is absztrakt!
        c_variant = Classic()                                                                                   % a probl�ma klasszikus megfelel�j�nek oszt�lynev�t adja vissza sztringk�nt
        popup_name = Popup()                                                                                    % a probl�ma felugr� men�ben megjelen� nev�t adja vissza sztringk�nt
        pot_string = StringPotential()                                                                          % a potenci�l formul�j�t adja vissza sztringk�nt
    end
end % classdef