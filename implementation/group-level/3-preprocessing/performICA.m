%% Initialise data.
% Specify subject to process.
dataNum = 5; % Change for each data struct.

% Get data for chosen subject.
data = preprocessedDataset{dataNum};

% Compute components.
cfg = [];
cfg.method = 'fastica'; % Use fast ICA algorithm.
comp = ft_componentanalysis(cfg, data);

%% Inspect component topographies.
cfg = [];
cfg.component = 1:39;
cfg.layout = 'biosemi32.lay';
cfg.channel = 'all';
cfg.viewmode = 'component';
cfg.fontsize = 8;
ft_topoplotIC(cfg, comp)

%% Inspect component time series.
cfg.ylim = [-100, 100];
ft_databrowser(cfg, comp)

%% Remove components.
% Specify components to remove.
componentsToRemove = [1, 3, 7, 10, 12, 13, 16]; % Change for each ICA run.

% Remove components.
cfg = [];
cfg.component = componentsToRemove;
subject14 = ft_rejectcomponent(cfg, comp);

%% Save post-ICA data.
folderPath = '/rds/projects/2017/schofiaj-01/oscar/Fringe-P3-investigation/group-level/data/3-postICA/New/';
fileName = sprintf('%ssubject14.mat', folderPath);
save(fileName, 'subject14')
