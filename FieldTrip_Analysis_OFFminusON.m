%% Break up portions of data for ON
% load('ON_data_cleaned.mat')
% split the data into a pre-stimulus and post-stimulus window
% split into even epochs so each have same frequency bins, for easy
% comparison

cfg         = [];
cfg.latency = [-1.25 -0.25-1./512]; % subtract 1 sample at the end to get a
              % nice number of samples, and nice frequency spacing
bl          = ft_selectdata(cfg, data_cleaned); %baseline
cfg.latency = [0.4 1.4-1./512];
encode         = ft_selectdata(cfg, data_cleaned); %encode
cfg.latency = [1.8 2.8-1./512];
retain         = ft_selectdata(cfg, data_cleaned); %retain

% compute power spectrum of trials in the specified latency windows
cfg         = [];
cfg.foilim  = [1 45]; % frequencies of interest
cfg.channel = {'all'}; % all channels except '-E32'
cfg.method  = 'mtmfft'; % method for computing FFT
cfg.taper   = 'hanning'; % type of window
ON_freqencode  = ft_freqanalysis(cfg, encode);
ON_freqretain  = ft_freqanalysis(cfg, retain);
ON_freqbl   = ft_freqanalysis(cfg, bl);

%% Break up portions of data for OFF
load('OFF_data_cleaned.mat')
% split the data into a pre-stimulus and post-stimulus window
% split into even epochs so each have same frequency bins, for easy
% comparison
cfg         = [];
cfg.latency = [-1.25 -0.25-1./512]; % subtract 1 sample at the end to get a
              % nice number of samples, and nice frequency spacing
bl          = ft_selectdata(cfg, data_cleaned); %baseline
cfg.latency = [0.4 1.4-1./512];
encode         = ft_selectdata(cfg, data_cleaned); %encode
cfg.latency = [1.8 2.8-1./512];
retain         = ft_selectdata(cfg, data_cleaned); %retain

% compute power spectrum of trials in the specified latency windows
cfg         = [];
cfg.foilim  = [1 45]; % frequencies of interest
cfg.channel = {'all'}; % all channels except '-E32'
cfg.method  = 'mtmfft'; % method for computing FFT
cfg.taper   = 'hanning'; % type of window
OFF_freqencode  = ft_freqanalysis(cfg, encode);
OFF_freqretain  = ft_freqanalysis(cfg, retain);
OFF_freqbl   = ft_freqanalysis(cfg, bl);

%% Set up OFF-ON powerspectrums

freqencode = ON_freqencode; %initialize new variable
freqretain = ON_freqretain;
freqbl     = ON_freqbl;

freqencode.powspctrm = OFF_freqencode.powspctrm - ON_freqencode.powspctrm;
freqretain.powspctrm = OFF_freqretain.powspctrm - ON_freqretain.powspctrm;
freqbl.powspctrm     = OFF_freqbl.powspctrm - ON_freqbl.powspctrm;

%%
save('OFFminusON');

%% Plot OFF-ON powspectrms for certain electrodes
% plot single channel representation
cfg            = [];
%cfg.ylim       = [0 13e-3];
cfg.channel    = {'A10','A11','C14','A16','A15','C19','A21','A20','C25'}; % which channels to average over
%cfg.channel    = {'D9','D10','B13','D14','D15','B18','D19','D20','B24'}; % posterior
cfg.xlim       = [4 45];
%cfg.ylim       = [0 4];
cfg.linewidth  = 2;
cfg.graphcolor = 'rbk'; % need a color for thing plotted in ft_singpleplotER or it won't work properly

figure;
ft_singleplotER(cfg, freqencode, freqretain, freqbl);

% some MATLAB low-level manipulation to improve the figure's aesthetics
set(gca, 'Fontsize',12);
title ('Mean over Frontal electrodes');
set(gca,'box','on');
xlabel('frequency [Hz]');
ylabel('power (\muV^2/Hz)');
legend('encode','retain','baseline');
toc




%% Log Scale
% Do same thing but we are going to convert to dB

%% 

% split the data into a pre-stimulus and post-stimulus window
% split into even epochs so each have same frequency bins, for easy
% comparison
cfg         = [];
cfg.latency = [-1.25 -0.25-1./512]; % subtract 1 sample at the end to get a
              % nice number of samples, and nice frequency spacing
bl          = ft_selectdata(cfg, data_cleaned); %baseline
cfg.latency = [0.4 1.4-1./512];
encode         = ft_selectdata(cfg, data_cleaned); %encode
cfg.latency = [1.8 2.8-1./512];
retain         = ft_selectdata(cfg, data_cleaned); %retain

% compute power spectrum of trials in the specified latency windows
cfg         = [];
cfg.foilim  = [1 45]; % frequencies of interest
cfg.channel = {'all'}; % all channels except '-E32'
cfg.method  = 'mtmfft'; % method for computing FFT
cfg.taper   = 'hanning'; % type of window
ON_freqencode  = ft_freqanalysis(cfg, encode);
ON_freqretain  = ft_freqanalysis(cfg, retain);
ON_freqbl   = ft_freqanalysis(cfg, bl);

%%
ON_freqencode_log  = ON_freqencode;
ON_freqretain_log  = ON_freqretain;
ON_freqbl_log   = ON_freqbl;

%%
ON_freqencode_log.powspctrm  = pow2db(ON_freqencode.powspctrm);
ON_freqretain_log.powspctrm  = pow2db(ON_freqretain.powspctrm);
ON_freqbl_log.powspctrm   = pow2db(ON_freqbl.powspctrm);

%% 

% split the data into a pre-stimulus and post-stimulus window
% split into even epochs so each have same frequency bins, for easy
% comparison
cfg         = [];
cfg.latency = [-1.25 -0.25-1./512]; % subtract 1 sample at the end to get a
              % nice number of samples, and nice frequency spacing
bl          = ft_selectdata(cfg, data_cleaned); %baseline
cfg.latency = [0.4 1.4-1./512];
encode         = ft_selectdata(cfg, data_cleaned); %encode
cfg.latency = [1.8 2.8-1./512];
retain         = ft_selectdata(cfg, data_cleaned); %retain

% compute power spectrum of trials in the specified latency windows
cfg         = [];
cfg.foilim  = [1 45]; % frequencies of interest
cfg.channel = {'all'}; % all channels except '-E32'
cfg.method  = 'mtmfft'; % method for computing FFT
cfg.taper   = 'hanning'; % type of window
OFF_freqencode  = ft_freqanalysis(cfg, encode);
OFF_freqretain  = ft_freqanalysis(cfg, retain);
OFF_freqbl   = ft_freqanalysis(cfg, bl);

%%
OFF_freqencode_log  = OFF_freqencode;
OFF_freqretain_log  = OFF_freqretain;
OFF_freqbl_log   = OFF_freqbl;

%%
OFF_freqencode_log.powspctrm  = pow2db(OFF_freqencode.powspctrm);
OFF_freqretain_log.powspctrm  = pow2db(OFF_freqretain.powspctrm);
OFF_freqbl_log.powspctrm   = pow2db(OFF_freqbl.powspctrm);

%%
freqencode = ON_freqencode;
freqretain = ON_freqretain;
freqbl     = ON_freqbl;

freqencode.powspctrm = OFF_freqencode_log.powspctrm - ON_freqencode_log.powspctrm;
freqretain.powspctrm = OFF_freqretain_log.powspctrm - ON_freqretain_log.powspctrm;
freqbl.powspctrm     = OFF_freqbl_log.powspctrm - ON_freqbl_log.powspctrm;

%%

% plot single channel representation
cfg            = [];
%cfg.ylim       = [0 13e-3];
cfg.channel    = {'A10','A11','C14','A16','A15','C19','A21','A20','C25'}; % which channels to average over
%cfg.channel    = {'D9','D10','B13','D14','D15','B18','D19','D20','B24'}; % posterior
cfg.xlim       = [4 45];
cfg.ylim       = [-4 4];
cfg.linewidth  = 1;
cfg.graphcolor = 'rbk'; % need a color for everything plotted in ft_singpleplotER or it won't work properly

figure;
ft_singleplotER(cfg, freqencode, freqretain, freqbl);

% some MATLAB low-level manipulation to improve the figure's aesthetics
set(gca, 'Fontsize',12);
title ('Mean over Anterior electrodes');
set(gca,'box','on');
xlabel('frequency [Hz]');
ylabel('OFF-ON (dB)');
legend('encode','retain','baseline');



%%
save('OFFminusON_log');