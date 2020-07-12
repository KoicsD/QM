function argtest(varargin)
disp(['Number of input arguments:', num2str(nargin)])

for i=1:nargin
    disp([num2str(i) ' th argument:'])
    varargin{i}
end
%par1
%par2
%par3
