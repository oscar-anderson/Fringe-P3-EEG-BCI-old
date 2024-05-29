function prepareEnvironment(project)

parentPath = '/rds/projects/2017/schofiaj-01/oscar';
cd(parentPath); % Change to parent user directory.

switch project
    case 'fringe-p3'
        projectPath = [parentPath, '/Fringe-P3-investigation'];
        cd(projectPath);
        addpath('fieldtrip-20230522');
end
