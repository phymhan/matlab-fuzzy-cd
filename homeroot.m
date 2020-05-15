function p = homeroot
if ispc
    p = fullfile('C:', 'Users', getenv('USERNAME'));
elseif ismac
    p = fullfile('/', 'Users', getenv('USER'));
else
    p = fullfile('/', 'home', getenv('USER'));
end
