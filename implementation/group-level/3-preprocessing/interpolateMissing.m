function interpolatedData = interpolateMissing(data, method)

% Define neighbours.
validChannels = {'Fp1'; 'AF3'; 'F7'; 'F3'; 'FC1'; 'FC5'; 'T7'; 'C3'; ...
    'CP1'; 'CP5'; 'P7'; 'P3'; 'Pz'; 'PO3'; 'O1'; 'Oz'; 'O2'; 'Po4'; ...
    'P4'; 'P8'; 'CP6'; 'CP2'; 'C4'; 'T8'; 'FC6'; 'FC2'; 'F4'; 'F8'; ...
    'AF4'; 'Fp2'; 'Fz'; 'Cz'; 'A1'; 'A2'; 'LEOG'; 'REOG'; 'UEOG'; ...
    'DEOG'; 'EXG7'; 'EXG8'};

cfg = [];
cfg.channel = validChannels;
cfg.method = 'template';
cfg.template = 'biosemi32_neighb.mat';
cfg.feedback = 'no';

neighbours = ft_prepare_neighbours(cfg, data);

% Identify missing channels.
missingChannelsIdx = ~ismember(validChannels, data.label)';
missingChannels = validChannels(missingChannelsIdx)';

% Interpolate.
cfg = [];
cfg.method = method;
cfg.missingchannel = missingChannels;
cfg.neighbours = neighbours;
cfg.trials = 'all';
cfg.senstype = 'eeg';

if strcmp(method, 'weighted')
    cfg.elec = []; % FIX ----------------------------------------------- !
elseif strcmp(method, 'spline') || strcmp(method, 'splat')
    cfg.elec = []; % FIX ----------------------------------------------- !
    cfg.lambda = 1e-5;
    cfg.order = 4;
elseif ~any(strcmp(method, {'weighted', 'average', 'spline', 'splat', 'nan'}))
    error('Invalid method input.')
end

interpolatedData = ft_channelrepair(cfg, data);

end
