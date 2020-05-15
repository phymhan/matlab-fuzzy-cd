function fcd(varargin)
%FCD fuzzy CD

if isempty(varargin)
    cd(homeroot);
    return
end
[dirpath, status] = fuzzydir(varargin{:});
if status
    cd(dirpath)
else
    error('Cannot CD to %s.\n', dirpath);
end
