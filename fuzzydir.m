function [dirpath, status] = fuzzydir(varargin)
%FUZZYDIR Find fuzzy directory path
% Syntax:
%   [dirpath, status] = FUZZYDIR(filepart1, ..., filepartN, startIndex);

% Aug/01/2016
% Aug/02/2016, regexp, matching cost, ~
%
if isempty(varargin)
    error('Not enough input arguments.')
end
ix = cellfun(@isnumeric, varargin);
if nnz(ix) == 0
    startIdx = 1;
else
    startIdx = varargin{ix};
end
varargin = varargin(~ix);
if varargin{1}(1) == '~'
    varargin{1} = strcat(homeroot(), varargin{1}(2:end));
end
if ispc
    idx = regexp(varargin{1}, '[a-zA-Z]:', 'once');
    if isempty(idx) || idx ~= 1
        startIdx = startIdx+nnz(pwd==filesep)+1;
        varargin = cat(2, {pwd}, varargin);
    end
else
    if varargin{1}(1) ~= filesep
        startIdx = startIdx+nnz(pwd==filesep)+1;
        varargin = cat(2, {pwd}, varargin);
    end
end
if startIdx < 2
    startIdx = 2;
end
dirpath_ = fullfile(varargin{:});
dirpath_ = strrep(dirpath_, '\ ', ' ');

str = strsplit(dirpath_, {'/', '\'});
if isempty(str{end})
    % dir path ending with filesep
    str(end) = [];
end
if isempty(str{1})
    % Linux or macOS
    str{1} = filesep;
end
if str{1}(end) == ':'
    % Windows
    str{1} = [str{1} filesep];
end

len = length(str);
currIdx = startIdx;
% matchPath = repmat({''}, [1 len]);
matchPath = str;
stack = cell(0, 2);
func = @(x) iff(isempty(x), NaN, x);
th = 1;
A1 = 0.2;
A2 = 0.8;
while currIdx <= len
    currDir = dir(fullfile(matchPath{1:currIdx-1}));
    names = {currDir.name};
    [idx1, idx2] = regexp(names, ['(?i)' str{currIdx}], 'once');
    idx1 = cellfun(func, idx1);
    idx2 = cellfun(func, idx2);
    strlens = cellfun(@length, names);
    matchCost = (idx1-1)./strlens.*A1+(strlens-idx2)./strlens.*A2;
    ixMatch = (matchCost == 0);
    A0 = any(ixMatch);
    ix = [currDir.isdir];
    ix = ix & ((A0 & ixMatch) | ((~A0) & (matchCost <= th)));
    if ~any(ix)
        % trace back
        if isempty(stack)
            break
        end
        stackTop = stack(end,:);
        currIdx = stackTop{1}+1;
        matchPath{currIdx-1} = stackTop{2}(1).name;
        stackTop{2}(1) = [];
        if ~isempty(stackTop{2})
            stack(end,:) = stackTop;
        else
            stack(end,:) = [];
        end
    else
        % push stack
        costs = matchCost(ix);
        currDirFind = currDir(ix);
        [~, I] = sort(costs, 'ascend'); % sort
        currDirFind = currDirFind(I);
        matchPath{currIdx} = currDirFind(1).name;
        if nnz(ix) > 1
            stack(end+1,:) = {currIdx, currDirFind(2:end)};
        end
        currIdx = currIdx+1;
    end
end
dirpath = fullfile(matchPath{1:currIdx-1});
status = currIdx > len;
