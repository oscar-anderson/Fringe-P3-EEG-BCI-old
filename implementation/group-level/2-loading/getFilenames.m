%% Load raw .BDF data.
function filenames = getFilenames(rawDataPath, fileExtension)

% Description:
    % getFilenames() finds all files in an input folder whose name includes
    % an input extension, then returns these as individual strings in a 
    % cell array.

% Input:
    % folderPath = string containing path of folder containing files.
    % fileExtension = string containing extension common to all sought files.

% Output:
    % allFiles = cell array of strings containing names of files with that
    % extension.

filesStruct = dir(fullfile(rawDataPath, ['*', fileExtension]));

if isempty(filesStruct)
    error('No files with that extension found in the specified folder.')
end

filenames = {filesStruct.name};

end
