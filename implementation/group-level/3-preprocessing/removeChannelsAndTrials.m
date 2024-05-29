%% Trial/channel rejection.

%% View all trials and channels.
cfg = [];
cfg.ylim = [-20, 20];
ft_databrowser(cfg, subject6_trump)

%% Reject trials.
cfg = [];
cfg.method = 'channel';
cfg.ylim = [-100, 100];
subject6_trump = ft_rejectvisual(cfg, subject6_trump);

%% Reject channels.
cfg.method = 'trial';
subject6_trump = ft_rejectvisual(cfg, subject6_trump);

%% Increase high pass filter bound.
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.4;
cfg.hpfilttype = 'fir';

subject6_trump = ft_preprocessing(cfg, subject6_trump);

%% Decrease low pass filter bound.
cfg= [];
cfg.lpfilter = 'yes';
cfg.lpfreq = 25;
cfg.lpfilttype = 'fir';

subject6_trump = ft_preprocessing(cfg, subject6_trump);

%% Save cleaned data.
fileName = ['subject6_trump', '.mat'];

folderPath = '/rds/projects/2017/schofiaj-01/oscar/Fringe-P3-investigation/group-level/data/4-artifact-rejected/New/';
save(fullfile(folderPath, fileName), 'subject6_trump')

