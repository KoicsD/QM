classdef QuantumProblem < handle
    properties(Constant)
        h = 6.628E-34           % Planck-állandó
        hl = 6.628E-34/(2*pi)   % redukált Planck-állandó [J * s]
    end
    properties
        Time                    % rendszeridõ
        TimeStep                % idõlépés
        Period                  % a rendszer periódusideje
        
        m                       % a részecske tömege
        
        EnergyValues            % energiaértékek
        EnergyStates            % energiaértékek kezdeti komplex együtthatói
        PlaceValues             % helyértékek
        MomentumValues          % impulzusértékek
        Potential               % potenciálfüggvény értékei
        StateFunction           % hullámfüggvény
        MomentumFunction        % hullámfüggvény impulzustérben
    end
    
    methods(Static)
        function obj = QuantumProblem(mm) % konstruktor
            obj.m = mm;
        end
        % Ettõl függetlenül az alosztályoknak szükségük van saját
        % konstruktorra. Annak szintaktikája legyen:
        %
        %   ProblemName()
        %       Paraméterek nélkül, alapértelmezett értékeket állít be a
        %       probléma paramétereiként.
        %
        %   ProblemName(param_names, param_values)
        %       param_names:    cella vektor, mely a probléma paramétereinek
        %                       neveit tartalmazza
        %       param_values:   cella vektor, mely a paraméterek értékeit
        %                       tartalmazza
        %
        %   ProblemName(param_names, param_values, energy_coeffs)
        %       energy_coeffs:  numerikus vektor, mely a kezdõ
        %                       energiaállapotok komplex együtthatóit
        %                       tartalmazza
    end
    
    methods % egyszerû, helyben definiált lekérdezõ függvények (az alosztályokban nem kell velük bajlódni)
        
        function [const_names, const_values] = GetPhysConstants(obj)        % a fizikai állandók kinyerése
            const_names = {'h', 'hl'}; const_values = {obj.h, obj.hl}; end
        
        function time = GetTime(obj)                                        % a pillanatnyi idõ lekérdezése
            time = obj.Time; end
        
        function time_step = GetTimeStep(obj)                               % az idõlépés lekérdezése
            time_step = obj.TimeStep; end
        
        function SetTimeStep(obj, time_step)                                % kakukktojásként egy beállító függvény: az idõlépés beállítása
            obj.TimeStep = time_step; end
        
        function period = GetPeriod(obj)                                    % a rendszer periódusidejének lekérdezése
            period = obj.Period; end
        
        function [place_values, state_function] = GetState(obj)             % hullámfüggvény kinyerése
            place_values = obj.PlaceValues; state_function = obj.StateFunction; end
        
        function [momentum_values, momentum_function] = GetMomentum(obj)    % impulzustérbeli hullámfüggvény kinyerése
            momentum_values = obj.MomentumValues; momentum_function = obj.MomentumFunction; end
    end
    
    methods % 2 sorba ki nem férõ lekérdezõ függvények
        
        function [indexes, energy_values, energy_states] = GetEnergy(obj)   % a kezdeti energiaállapot lekérdezése
            % indexes:          az enegriaértékek indexei
            % energy_values:    az energiaértékeket tartalmazó vektor
            % energy_states:    az energiaértékekhez tartozó komplex
            %                   együtthatókat tartalmazó vektor
            indexes = 0 : length(obj.EnergyValues) - 1;
            energy_values = obj.EnergyValues;
            energy_states = obj.EnergyStates;
        end
        
        function [time, place, momentum, energy] = GetAverage(obj)          % az átlagértékek lekérdezése
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
    
    methods(Abstract) % ezeket a függvényeket minden alosztályban definiálni kell, enélkül az alosztály nem példányosítható
        
        [const_names, const_vals, dependency] = GetSpecConstants(obj)                                           % a probléma paramétereinek kinyerése
            % const_names:  cella vektor -- a paraméterek betûjelei sztringként
            % const_vals:   cella vektor -- a paraméterek értékei SI egységben
            % dependency:   logikai vektor -- annak jelzése, mely paraméter
            %                                 tekintendõ a többi függvényének
            
        [const_names, const_vals] = GetAllConstants(obj)                                                        % a probléma paramétereinek és a fizikai állandók együttes kinyerése
            % const_names:  cella vektor -- a paraméterek betûjelei sztringként
            % const_vals:   cella vektor -- a paraméterek értékei SI egységben
            
            
        SetTime(obj, time)                                                                                      % az idõ közvetlen állítása
        StepForward(obj, count)                                                                                 % léptetés elõre count idõlépést
        StepReverse(obj, count)                                                                                 % léptetés hátra count idõlépést
        ResetTime(obj)                                                                                          % a rendszer kezdeti állapotába állítása
            
        
        [place, potential, param_names, param_units, param_values, dependency] = GetPotential(obj)              % potenciálfüggvény lekérdezése
            % place:        a helykoordinátákat tartalmazó vektor
            % potenctial:   a potenciálfüggvény értékeit tartalmazó vektor
            % param_names:  cella vektor -- a rendszer paramétereinek nevei
            % param_values: cella vektor -- a paraméterek értékei
            % dependency:   logikai vektor -- a paraméter a többi függvénye-e
            
        [place, potential, dep_names, dep_units, dep_values] = CalcPotential(obj, param_names, param_values)    % az új potenciálfüggvény számítása (obj módosítása nélkül)
            % param_names:  cella vektor -- a rendszer független paramétereinek nevei
            % param_values: cella vektor -- a független paraméterek értékei
            % place:        a helykoordinátákat tartalmazó vektor
            % potential:    a számított potenciálfüggvényt tartalmazó vektor
            % dep_names:    a számított paraméterek nevei cella vektorként
            % dep_values:   a számított paraméterek értékei
        
        [place, potential, dep_names, dep_units, dep_values] = SetPotential(obj, param_names, param_values)     % a potenciálfüggvény módosítása
            % param_names:  a rendszer független paraméterei cella vektorként
            % param_values: a független paraméterek értékei cella vektorként
            % place:        a helykoordinátákat tartalmazó vektor
            % potential:    az új potenciálfüggvény értékeit tartalmazó vektor
            % dep_names:    a számított paraméterek nevei cella vektorként
            % dep_values:   a számított paraméterek értékei
        
        [indexes, energy_values] = CalcEnergy(obj, energy_states)                                               % energiaértékek lekérdezése egy esetleges új kezdeti energiaállapothoz
        [indexes, energy_values] = SetEnergy(obj, energy_states)                                                % kezdeti energiaállapot módosítása
            % energy_values: az energiaértékeket tartalmazó vektor
            % energy_states: az energiaértékekhez tartozó komplex együtthatókat tartalmazó vektor
    end % methods(Abstract)
    
    methods(Abstract, Static) % ez is absztrakt!
        c_variant = Classic()                                                                                   % a probléma klasszikus megfelelõjének osztálynevét adja vissza sztringként
        popup_name = Popup()                                                                                    % a probléma felugró menüben megjelenõ nevét adja vissza sztringként
        pot_string = StringPotential()                                                                          % a potenciál formuláját adja vissza sztringként
    end
end % classdef