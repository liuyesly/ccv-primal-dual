currentPath = pwd;
allItems = dir(currentPath);
allItems = allItems(~ismember({allItems.name}, {'.', '..'}));
allPaths = cell(length(allItems), 1);
for i = 1:length(allItems)
    allPaths{i} = fullfile(currentPath, allItems(i).name);
end
addpath(fullfile(currentPath, 'utils'));
addpath(fullfile(currentPath, 'algorithms'));
load('data/ClutterDataset.mat'); % Clutter data
load('data/SV_Dict.mat'); % Steering matrix

[totalNumSamp, MN] = size(cluttersig_all);
SV_CUT = SV_Dict(:, :, tgtCellIdx);

disp('Data loaded. ')
