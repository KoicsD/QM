classdef CM_PotBox < ClassicProblem
    methods(Static)
        function q_variant = Quantum()
            q_variant = 'QM_PotBox'; end
    end
    
    methods(Static)
        function obj = CM_PotBox()
            %CM_PotBox@ClassicProblem()
            %potbeállítás
            
            %obj.Energy = obj.EstimateEnergy(0, 0);
        end
    end
    
    methods
        function potential = SetPotential(obj, args, place_values)
            obj.SetInitCond(0, 0);
            
        end
        function [potential, params] = GetPotential(obj, place_values)
            
        end
        function StepForward(obj, count)
            obj.Time = obj.Time + count * obj.TimeStep;
            
        end
        function StepReverse(obj, count)
            obj.Time = obj.Time - count * obj.TimeStep;
            
        end
        function energy = EstimateEnergy(obj, place, momentum)
            
        end
    end
end