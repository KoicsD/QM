classdef CM_Oscillator < ClassicProblem
    methods(Static)
        
        function q_variant = Quantum()                                      % klasszikus megfelelõ osztályneve
            q_variant = 'QM_Oscillator'; end
        
        function popup_name = Popup()                                       % a felugró menüben megjelenõ név
            popup_name = 'Harmonic oscillator'; end
        
        function pot_string = StringPotential()                             % a potenciálfüggvény sztringként
            pot_string = 'V(x) = m * ohm^2 * x^2 / 2; ohm^2 = D / m'; end
    end
    
    methods(Static)
        function obj = CM_Oscillator() % konstruktor
            
            % A problémának három paramétere van:
            %   D:          rugóállandó
            %   m:          tömeg
            %   omegha:     klasszikus körfrekvencia
            %
            % Ezek közül pontosan kettõt kell átadni a konstruktornak, a
            % harmadikat a konstruktor automatikusan kiszámolja.
            
            switch nargin
                case 0
                    oomegha = 2 * pi * 8.65E+13;
                    DD = 48;
                    mm = DD / oomegha^2;
                    energy_states = zeros(1,9);%
                    energy_states(1) = 1;%
                case 2%
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
                    energy_states = zeros(1,9);%
                    energy_states(1) = 1;%
                case 3%
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
                    energy_states = varargin{3};%
                otherwise
                    error('Wrong arguments.')
            end % switch nargin
            
            % numerikus értékek ellenõrzése
            if isnan(mm) || isnan(DD) || isnan(oomegha) || ...
                    isinf(mm) || isinf(DD) || isinf(oomegha) || ...
                    mm <= 0 || DD <= 0 || oomegha <= 0 ||...
                    imag(mm) || imag(DD) || imag(oomegha)
                error('Wrong arguments.')
            end
            
            obj@ClassicProblem(mm);
            obj.D = DD; obj.omegha = oomegha;
            
        end % function CM_Oscillator -- konstruktor
    end % methods(Static)
    
    methods
        [const_names, const_vals, dependency] = GetConstants(obj)%
        StepForward(obj, count)%
        StepReverse(obj, count)%
        ResetTime(obj)%
        [place, potential, param_names, param_units, param_values, dependency] = GetPotential(obj)%
        [place, potential, dep_names, dep_units, dep_values] = CalcPotential(obj, param_names, param_values)%
        [place, potential] = SetPotential(obj, param_names, param_values)%
        energy = CalcEnergy(obj, init_pos, init_mom)%
        energy = SetInitCond(obj, init_pos, init_mom)%
    end % methods
end % classdef