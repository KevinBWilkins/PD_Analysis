% This script will load in dataset, do some preprocessing, and then
% calculate power over all channels for baseline, encode, and retain

%% SOME PRELIMINARIES
clear 
close all
clc

% initialize fieldtrip
path_ft   = '';
path_data = '';

% this adds fieldtrip to the matlab path + the relevant subdirectories
addpath(path_ft);
ft_defaults;

% the variable subjects contains the list of subject-specific directories
subjects = {'Subj01_110818'};
nsubj = numel(subjects);


%% See what events are in data

cfg = [];
cfg.dataset            = '01E1m1F.vhdr';
cfg.trialdef.eventtype = '?';
ft_definetrial(cfg);

% S131; S135' S227
% S135 = target appears
% S227 = encoding period over, retention begins

%% DATA EPOCHING AND GENERAL PREPROCESSING
tic 

% in this step the epochs-of-interest are defined
cfg           = [];
cfg.dataset   = '01e1m1F.eeg';
cfg.trialfun  = 'ft_trialfun_general'; 
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S135'};
cfg.trialdef.prestim    = 2; % epoch time pre-stimulus
cfg.trialdef.poststim   = 4.4; % epoch time post-stimulus
cfg           = ft_definetrial(cfg);
trl           = cfg.trl; % this field contains the definition of the epochs of interest 

% in this step the data is read from file, and basic preprocessing is
% applied

cfg.dataset    = '01e1m1F.eeg';
% cfg.channel    = egi256customlay.label;
cfg.layout='biosemi256.lay'; % biosemi layout
cfg.channel     = [2:161]; %skip EOG channel
cfg.reref      = 'yes'; %rereference 
cfg.refchannel = 'all'; % rereference to average reference
cfg.bpfilter   = 'yes'; % bandpass filter
cfg.bpfreq     = [1 48]; % bandpass filter between 1 and 48 hz
cfg.bpfilttype = 'firws';
data1           = ft_preprocessing(cfg);

toc % Elapsed time is 

%% Check a few channels to make sure data looks OK
figure
plot(data1.time{1}, data1.trial{1}(2:4,:)); % plots 3 different channels
legend(data1.label(2:4));


%% DATA EPOCHING AND GENERAL PREPROCESSING
tic 

% in this step the epochs-of-interest are defined
cfg           = [];
cfg.dataset   = '01e1m2F.eeg';
cfg.trialfun  = 'ft_trialfun_general'; 
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S135'};
cfg.trialdef.prestim    = 2; % epoch time pre-stimulus
cfg.trialdef.poststim   = 4.4; % epoch time post-stimulus
cfg           = ft_definetrial(cfg);
trl           = cfg.trl; % this field contains the definition of the epochs of interest 

% in this step the data is read from file, and basic preprocessing is
% applied

cfg.dataset    = '01e1m2F.eeg';
% cfg.channel    = egi256customlay.label;
cfg.layout='biosemi256.lay'; % biosemi layout
cfg.channel     = [2:161]; %skip EOG channel
cfg.reref      = 'yes'; %rereference 
cfg.refchannel = 'all'; % rereference to average reference
cfg.bpfilter   = 'yes'; % bandpass filter
cfg.bpfreq     = [1 48]; % bandpass filter between 1 and 48 hz
cfg.bpfilttype = 'firws';
data2           = ft_preprocessing(cfg);

toc % Elapsed time is 

%% Append datasets

data = ft_appenddata(cfg, data1, data2)


%% Visual Reject of channels
% reject EXG channels and Status
cfg          = [];
cfg.method   = 'channel'; % can do 'channel' or 'trial
cfg.channel = 'all';
cfg.keepchannel = 'no'; 
cfg.trials = 'all';
% cfg.eegscale = 5e-5;
% cfg.alim     = 5e-5; % 50 micro volt scale

data_cleaned       = ft_rejectvisual(cfg,data);

%% Visual Reject of trials

cfg          = [];
cfg.method   = 'trial'; % can do 'channel' or 'trial
cfg.channel = 'all';
cfg.keepchannel = 'no'; 
cfg.trials = 'all';
% cfg.eegscale = 5e-5;
% cfg.alim     = 5e-5; % 50 micro volt scale

data_cleaned        = ft_rejectvisual(cfg,data_cleaned);

%%
save('ON_data_cleaned');

%% COMPUTATION OF EVENT-RELATED POTENTIALS (SKIP)


% average across trials
cfg         = [];
cfg.channel = {'all'};
erp         = ft_timelockanalysis(cfg,data_cleaned);
%save('erp');



%% FREQUENCY DOMAIN ANALYSIS over individual trials
tic

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
cfg.keeptrials = 'yes';
freqencode  = ft_freqanalysis(cfg, encode);
freqretain  = ft_freqanalysis(cfg, retain);
freqbl   = ft_freqanalysis(cfg, bl);


% compute grandaverage spectra
% gafreqencode = ft_freqgrandaverage([], freqencode{:});
% gafreqretain = ft_freqgrandaverage([], freqretain{:});
% gafreqbl  = ft_freqgrandaverage([], freqbl{:});


%%
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

%%
% plot single channel representation
cfg            = [];
%cfg.ylim       = [0 13e-3];
%cfg.channel    = {'A10','A11','C14','A16','A15','C19','A21','A20','C25'}; % which channels to average over
cfg.channel    = {'D9','D10','B13','D14','D15','B18','D19','D20','B24'}; % posterior
cfg.xlim       = [4 45];
cfg.ylim       = [0 4];
cfg.linewidth  = 2;
cfg.graphcolor = 'rbk'; % need a color for thing plotted in ft_singpleplotER or it won't work properly

figure;
ft_singleplotER(cfg, freqencode, freqretain, freqbl);

% some MATLAB low-level manipulation to improve the figure's aesthetics
set(gca, 'Fontsize',12);
title ('Mean over Posterior electrodes');
set(gca,'box','on');
xlabel('frequency [Hz]');
ylabel('power (\muV^2/Hz)');
legend('encode','retain','baseline');
toc
%%

% plot freq output on topographic plot
cfg           = [];
cfg.layout='biosemi256.lay'; % biosemi layout
cfg.parameter = 'powspctrm';
% cfg.highlight = 'on';
% cfg.highlightchannel = statfreq.label(statfreq.mask==1);
cfg.colormap  = parula;
cfg.marker    = 'off';
cfg.style     = 'fill';
cfg.comment   = 'off';
cfg.colorbar  = 'yes';
cfg.ylim      = [2 7]; % which frequencies to plot
% cfg.zlim      = [0 13e-3];

figure;
ft_topoplotER(cfg,freqencode{1,1});c = colorbar;
c.LineWidth = 1;
c.FontSize = 18;
title(c,'power');
toc

%% Time-Frequency Analysis

cfg = [];
cfg.channel    = 'A15';	                
cfg.method     = 'wavelet';                
cfg.width      = 7; 
cfg.output     = 'pow';	
cfg.foi        = 1:2:30;	                
cfg.toi        = -0.5:0.05:1.5;		              
TFRwave = ft_freqanalysis(cfg, data_cleaned);

cfg              = [];
cfg.baseline     = [-0.5 -0.1]; 
cfg.baselinetype = 'absolute'; 
% cfg.maskstyle    = 'saturation';	
% cfg.zlim         = [-3e-27 3e-27];	
cfg.channel      = 'A15';
cfg.interactive  = 'no';
figure
ft_singleplotTFR(cfg, TFRwave);
