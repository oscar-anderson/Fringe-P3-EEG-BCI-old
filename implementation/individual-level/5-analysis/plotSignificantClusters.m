function plotSignificantClusters(results, fileSavePath)

% Set parameters for cluster plots.
cfg = []; % Clear configuration to set plot parameters.
cfg.alpha = 0.05; % Significance threshold for clusters to be highlighted.
cfg.highlightseries = {'labels', 'labels', 'off', 'off', 'off'}; % Highlight significant clusters by their labels.
cfg.subplotsize = [3, 5]; % Set grid dimensions for plots display.
cfg.layout = 'biosemi32.lay'; % Use Biosemi 32-channel scalp layout.
cfg.toi = linspace(0.2, 1, cfg.subplotsize(1) * cfg.subplotsize(2)); % Show significant clusters over specified time window.
cfg.colorbar = 'EastOutside'; % Include amplitude colourbar.
cfg.colorbartext = 'Amplitude';
cfg.zlim = [min(results.stat(:)), max(results.stat(:))]; % Set limits for amplitude colourbar.
cfg.marker = 'on';
cfg.saveaspng = fileSavePath;
cfg.visible = 'no';

% Set plot to fullscreen.
figurePosition = [0, -90];
figureWidth = 1500;
figureHeight = 600;
fig = figure;
set(fig, 'Position', [figurePosition, figureWidth, figureHeight]);

% Plot significant clusters.
ft_clusterplot(cfg, results);

end
