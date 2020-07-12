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
        function [const_names, const_vals, dependency] = GetSpecConstants(obj) % a probl�ma param�tereinek kinyer�se
            const_names = {'NotReady.'};
            const_vals = {0};
            dependency = [false];
        end
        
        function [const_names, const_vals] = GetAllConstants(obj) % a probl�ma param�tereinek �s a fizikai �lland�k egy�ttes kinyer�se
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
        
        function [place, potential, param_names, param_values, dependency] = GetPotential(obj) % potenci�lf�ggv�ny lek�rdez�se
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
            param_names = {'NotReady.'};
            param_values = {0};
            dependency = [false];
        end
        
        function [place, potential, dep_names, dep_values] = CalcPotential(obj, param_names, param_values) % az �j potenci�lf�ggv�ny sz�m�t�sa (obj m�dos�t�sa n�lk�l)
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
            dep_names = {'NotReady.'};
            dep_values = {0};
        end
        
        function [place, potential] = SetPotential(obj, param_names, param_values) % a potenci�lf�ggv�ny m�dos�t�sa
            place = (0:100) * 1E-10;
            potential = zeros(size(place));
        end
        
        function [indexes, energy_values] = CalcEnergy(obj, energy_states) % energia�rt�kek lek�rdez�se egy esetleges �j kezdeti energia�llapothoz
            indexes = 1 : length(energy_states);
            energy_values = indexes * 1E-20;
        end
        
        function [indexes, energy_values] = SetEnergy(obj, energy_states) % energia�rt�kek be�ll�t�sa
            indexes = 1:10;
            energy_values = indexes * 1E-20;
        end
    end % methods
end % classdef