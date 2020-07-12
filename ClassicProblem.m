classdef ClassicProblem < handle
    properties
        Time
        TimeStep
        Period
        
        m
        
        InitCond
        Energy
        PotParams
        Place
        Momentum
    end
    
    methods(Static)
        function obj = ClassicProblem(mm)%
            obj.m = mm;
        end
    end
    
    methods
        function time = GetTime(obj)%
            time = obj.Time; end
        
        function time_step = GetTimeStep(obj)%
            time_step = obj.TimeStep; end
        
        function period = GetPeriod(obj)%
            period = obj.Period; end
        
        function SetTimeStep(obj, time_step)%
            obj.TimeStep = time_step;
        end
    end
    
    methods
    
        function [time, place, momentum, energy] = GetState(obj)%
            time = obj.Time;
            place = obj.Place;
            momentum = obj.Momentum;
            energy = obj.Energy;
        end
        
        function [init_pos, init_mom, energy] = GetInitCond(obj)%
            init_pos = obj.InitCond(1); init_mom = obj.InitCond(2); energy = obj.Energy;
        end
    
    end
    
    methods(Abstract)
        [const_names, const_vals, dependency] = GetConstants(obj)%
        StepForward(obj, count)%
        StepReverse(obj, count)%
        ResetTime(obj)%
        [place, potential, param_names, param_units, param_values, dependency] = GetPotential(obj)%
        [place, potential, dep_names, dep_units, dep_values] = CalcPotential(obj, param_names, param_values)%
        [place, potential] = SetPotential(obj, param_names, param_values)%
        energy = CalcEnergy(obj, init_pos, init_mom)%
        energy = SetInitCond(obj, init_pos, init_mom)%
    end
    
    methods(Abstract, Static)
        q_variant = Quantum()%
        popup_name = Popup()%
        pot_string = StringPotential()%
    end
end
