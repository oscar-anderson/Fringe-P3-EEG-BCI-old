function interpolatedData = interpolateMissing(data, method, varargin)

% THERE REMAINS AN ISSUE WHEREIN THE CHANNEL PO4 IN THE TEMPLATE IS
% LABELLED Po4 IN THE DATA.
%           - WHAT IS THE CAUSE OF THIS DISCREPANCY?
%           - HOW TO FIX?

cfg = [];
cfg.method = 'template';
cfg.template = 'biosemi32_neighb.mat';

neighbours = ft_prepare_neighbours(cfg);

% Identify missing channels.
validChannels = {neighbours(:).label};
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
    cfg.elec = varargin{1};
elseif strcmp(method, 'spline') || strcmp(method, 'splat')
    cfg.elec = varargin{1};
    cfg.lambda = 1e-5;
    cfg.order = 4;
elseif ~any(strcmp(method, {'weighted', 'average', 'spline', 'splat', 'nan'}))
    error('Invalid method input.')
end

interpolatedData = ft_channelrepair(cfg, data);

