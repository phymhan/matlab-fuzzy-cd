function varargout = dir2(varargin)
%DIR2 dir without . and ..
%
% Aug/01/2016
%

D = dir(varargin{:});
isDot = cellfun(@(s) any(strcmp(s, {'.', '..'})), {D.name});
D(isDot) = [];
if nargout > 0
    varargout{1} = D;
else
    disp(char({D.name}'));
end
