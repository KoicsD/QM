classdef QM_PotBox < QuantumProblem
    methods(Static)
        function c_variant = Classic()
            c_variant = 'CM_PotBox'; end
        
        function popup_name = Popup()
            popup_name = 'Box with Infinite Walls'; end
    end
    
    methods(Static)
        function obj = QM_PotBox()
            obj@QuantumProblem(1.602E-31);
            
            obj.Time = 0;
            obj.TimeStep = 0;
            obj.Period = 0;
            
            obj.EnergyValues = (1:10) * 1E-20;
            obj.EnergyStates = ones(size(obj.EnergyValues));
            obj.PlaceValues = (0:100) * 1E-10;
            obj.MomentumValues = (0:100) * 1E-23;
            obj.Potential = zeros(size(obj.PlaceValues));
            obj.StateFunction = sin(obj.PlaceValues);
            obj.MomentumFunction = cos(obj.MomentumValues);
        end
    end
    
    methods
        function [const_names, const_vals, dependency] = GetSpecConstants(obj) % a probléma paramétereinek kinyerése
            const_names = {'NotReady.'};
            const_vals = {0};
            dependency = [false];
        end
        
        function [const_names, const_vals] = GetAllConstants(obj) % a probléma paramétereinek és a fizikai állandók együttes kinyerése
            const_names = {'NotReady.'};
            const_vals = {0};
        end
        
        function SetTimeStep(obj, time_step)
            
        end
        function StepForward(obj, count)
            
        end
        function StepReverse(obj, count)
            
        end
        function ResetTime(obj)
            
        end
        
        function [place, potential, param_names, param_values, dependency] = GetPotential(obj) % potenciálfüggvény lekérdezése
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
            param_names = {'NotReady.'};
            param_values = {0};
            dependency = [false];
        end
        
        function [place, potential, dep_names, dep_values] = CalcPotential(obj, param_names, param_values) % az új potenciálfüggvény számítása (obj módosítása nélkül)
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
            dep_names = {'NotReady.'};
            dep_values = {0};
        end
        
        function [place, potential] = SetPotential(obj, param_names, param_values) % a potenciálfüggvény módosítása
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
        end
        
        function [indexes, energy_values] = CalcEnergy(obj, energy_states) % energiaértékek lekérdezése egy esetleges új kezdeti energiaállapothoz
            indexes = 1 : length(energy_states);
            energy_values = indexes * 1E-20;
        end
        
        function [indexes, energy_values] = SetEnergy(obj, energy_states) % energiaértékek beállítása
            indexes = 1:10;
            energy_values = indexes * 1E-20;
        end
    end % methods
end % classdef