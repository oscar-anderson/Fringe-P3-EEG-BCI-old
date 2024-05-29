function results = runIndividualAnalysis(probeData, irrelevantData, varargin)

% Initialise neighbours.
cfg = [];
cfg.method = 'template';
cfg.template = 'biosemi32_neighb.mat';

neighbours = ft_prepare_neighbours(cfg);

% Initialise design matrix.
numProbeTrials = length(probeData.trial);
numIrrelevantTrials = length(irrelevantData.trial);
design = [ones(1, numProbeTrials), 2*ones(1, numIrrelevantTrials); 1:numProbeTrials, 1:numIrrelevantTrials];

%% Run cluster-based independent samples permutation test.

% Set parameters for statistical test.
cfg = []; % Clear configuration to set test parameters.
cfg.neighbours = neighbours; % Specify defined neighbours of each channel.
cfg.parameter = 'trial'; % Specify that trial field of subject data structs is to be used.
cfg.method = 'montecarlo'; % Use Monte Carlo resampling for permutation.
cfg.statistic = 'indepsamplesT'; % Run paired samples t-test.
cfg.correctm = 'cluster'; % Use cluster-level t as test statistic for MCP correction.
cfg.clusterstatistic = 'maxsum'; % Use max cluster-level t-stat as test statistic.
cfg.clusteralpha = 0.025; % Significance threshold for samples to be included in clusters.
cfg.minnbchan = 0; % Minimum number of significant neighbours required for sample to be included in cluster.
cfg.tail = 1; % One-tailed t-tests (positive).
cfg.clustertail = 1; % One-tailed cluster permutation (positive).
cfg.alpha = 0.05; % Threshold for determining significance of final cluter-level statistic.
cfg.numrandomization = 500; % Start with this number of permutations. Increase if near significance.
cfg.design = design; % Test of difference between specified design conditions (crit/control).
cfg.ivar = 1; % First row of design matrix represents independent variable.

%% Initialise ROI (if input).
if nargin > 2
    ROI = varargin{1};
    cfg.channel = ROI.channels;
    cfg.latency = [ROI.startTime, ROI.endTime];
else
    cfg.channel = {'all', '-T7', '-T8', '-A1', '-A2', '-LEOG', '-REOG', '-UEOG', '-DEOG', '-EXG7', '-EXG8'};
    cfg.latency = [0.25, 1];
end

%% Run statistical test.

results = ft_timelockstatistics(cfg, probeData, irrelevantData);

end
