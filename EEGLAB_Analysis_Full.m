%% Some basic structure information

% EEG: the current EEG dataset
% ALLEEG: array of all loaded EEG datasets
% CURRENTSET: the index of the current dataset
% LASTCOM: the last command issued from the EEGLAB menu
% ALLCOM: all the commands issued from the EEGLAB menu

% type EEG into command line to access the current dataset
% access contents by typing EEG.fieldname; 
% example: EEG.nbchans to get number of channels

% EEG.history will show you all the previous commands used

% can repeat history on new dataset through menu"
% File > Sabe history > Dataset history

% pop_ functions take the EEG structure as input

% Three layers of EEGLAB functions:main eeglab function and its menu han
% 1. The main eeglab function and its menu handlers: EEGLAB users typically 
% call these functions by selecting menu items from the main EEGLAB window menu
% 2. Pop_functions: Matlab functions with their own graphic interfaces. 
% Called with no (or few) arguments (as from the EEGLAB user interface), 
% these functions pop up a query window to gather additional parameter 
% choices from users. They then generally call one or more of the EEGLAB 
% toolbox signal processing functions. The pop_functions can also be called
% from the Matlab command line or from Matlab scripts.
% 3. Signal processing functions: The experienced Matlab user can call the 
% ICA toolbox functions directly from the Matlab command line or from their 
% own analysis scripts. Some EEGLAB helper functions are also in this layer.

% pop_ functions can be called from command line or EEGLAB menu GUI; if you
% give no options then it will open dialog option box (ex: EEG=pop_loadset;
% eeg_ functions can only be called from command line\

% pop_ functions do not necessarily return variables! they alter the EEG data structure



% if you want to switch back from command line to working with EEGLAB
% graphic interface, you should perform one of the following:
% 1. if no eeglab window is up: 
% eeglab redraw;
% 2. if there is an open EEGLAB session:
% [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
% eeglab redraw;

% session history: eegh or EEG.history

%% Addpath for EEGLAB
addpath /Users/kevinwilkins/Documents/MATLAB/eeglab14_1_2b

%% Open EEGLAB

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start EEGLAB

%% Load in datasets

EEG = pop_loadbv('/Users/kevinwilkins/Documents/Fabian/Subj01_110818/', '01E1m1F.vhdr');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','01E1m1F'); %,'gui','off'); 
EEG = pop_loadbv('/Users/kevinwilkins/Documents/Fabian/Subj01_110818/', '01E1m2F.vhdr'); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','01E1m2F'); %,'gui','off'); 
%% Merge datasets

EEG = pop_mergeset(ALLEEG,[1 2],0); % append datasets 1 and 2
EEG.setname='Merged_O1E1mF'; % name the new dataset

EEG = pop_saveset(EEG,'filename','O1E1mF_merged')


%% Filter the data

EEG = pop_eegfiltnew(EEG,1,50); % band pass filter between 1 and 50 Hz
EEG = pop_saveset(EEG,'filename','O1E1mF_merged_filt_badremoved')
%% Plot data

pop_eegplot(EEG,1,1,1);

%% Removed bad channels
% remove any bad channels from dataset
EEG = pop_select(EEG,'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14' 'C15' 'C16' 'C17' 'C18' 'C19' 'C20' 'C21' 'C22' 'C23' 'C24' 'C25' 'C26' 'C27' 'C28' 'C29' 'C30' 'C31' 'C32' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'D10' 'D11' 'D12' 'D13' 'D14' 'D15' 'D16' 'D17' 'D18' 'D19' 'D20' 'D21' 'D22' 'D23' 'D24' 'D25' 'D26' 'D27' 'D28' 'D29' 'D30' 'D31' 'D32' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13' 'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22'  'E24' 'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32'});
EEG.setname='Merged_O1E1mF_badremoved'; % name the new dataset

EEG = pop_saveset(EEG,'filename','O1E1mF_merged_filt_badremoved')
%% Epoch data into trials and baseline correct

EEG = pop_epoch(EEG,{'S135'},[-2 4.4],'newname','Merged_O1E1mF_filt_badremoved_epochs','epochinfo','yes'); % epoch around TTL S135 2 seconds before and 4.4 seconds after
EEG = eeg_checkset(EEG);

EEG = pop_rmbase(EEG,[-1800 -500]); % baseline correction
EEG.setname='Merged_O1E1mF_filt_badremoved_epochs_BC';

EEG = pop_saveset(EEG,'filename','O1E1mF_merged_filt_badremoved_BC')
%% Take common average reference

EEG = pop_reref(EEG,[]); % re-reference to average of all channels
EEG.setname='Merged_O1E1mF_filt_badremoved_epochs_BC_reref';

EEG = pop_saveset(EEG,'filename','O1E1mF_merged_filt_badremoved_BC_reref')

%% Open/Update in GUI

[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw;

%% Replot data
pop_eegplot(EEG,1,1,1);

%% Reject incorrect or bad trials

% EEG = pop_rejepoch(EEG,[2 3],0) % rejects trials 2 and 3
EEG = pop_rejepoch(EEG,[2 3],0)

EEG = pop_saveset(EEG,'filename','O1E1mF_merged_filt_badremoved_BC_reref_correct')


%% Plot ERSP

figure; 
chan_number = 14;
pop_newtimef(EEG,1,chan_number,[-1000 4398],[3 10],'topovec',chan_number,'elocs', ...
    EEG.chanlocs,'chaninfo',EEG.chaninfo,'caption','A14','baseline',...
    [-500 0],'freqs',[2 48],'plotphase','off','padratio',1);

%% Calculate and store ERSP
% note: fore newtimef you give whole dataset not just -1000 to 4398
figure
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(3).data(14,:,:),...
    EEG.pnts,[EEG.xmin EEG.xmax]*1000,EEG.srate,[3 10],'baseline',[-500 0],...
    'plotitc','on','freqs',[2 48],'freqscale','linear','verbose','on');

%% calculate difference between 2 conditions
figure
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef({ALLEEG(1).data(9,:,:) ALLEEG(2).data(9,:,:)},...
    EEG.pnts,[EEG.xmin EEG.xmax]*1000,EEG.srate,[3 10],'baseline',[-500 0],...
    'plotitc','on','freqs',[2 48],'freqscale','linear','verbose','on',...
    'commonbase','on'); 
% note that if using pop_newtime(f) you would do [-1000 4398)

%%

% calculate difference between 2 conditions, but not taking out baseline
figure
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef({ALLEEG(1).data(19,:,:) ALLEEG(2).data(19,:,:)},...
    EEG.pnts,[EEG.xmin EEG.xmax]*1000,EEG.srate,[3 10],'baseline',NaN,...
    'plotitc','on','freqs',[2 48],'freqscale','linear','verbose','on'); 
% note that if using pop_newtime(f) you would do [-1000 4398)


%%
figure
[ersp,itc,powbase,times,freqs,erspboot,itcboot] = newtimef(ALLEEG(3).data(14,:,:),...
    EEG.pnts,[EEG.xmin EEG.xmax]*1000,EEG.srate,[3 10],'baseline',[-500 0],...
    'plotitc','on','freqs',[2 48],'freqscale','linear','verbose','on');


%% replot ERSP

figure
imagesc(times,freqs,ersp)
colormap(jet)
caxis([-4 4])
h=colorbar
h.Label.String = 'ERSP (dB)'
xlabel('Time (ms)')
ylabel('Frequency (Hz)')
set(gca,'YDir','normal')


%% replot ERSP
% Can use this to plot the average for multiple channels
figure
ersp_image = imagesc(times,freqs,ersp)
colormap(jet)
caxis([-4 4])
h=colorbar
h.Label.String = 'ERSP (dB)'
xlabel('Time (ms)')
ylabel('Frequency (Hz)')
set(gca,'YDir','normal')
