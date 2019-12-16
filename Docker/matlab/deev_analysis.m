addpath('deev')
clear
close all
cfg.doplots = 1;

% generated data
%cfg.dir = '../projs/logs_DeEv_recog_0.25ECdeep_0CA1deep_2trainepochs';
% publication data
cfg.dir = '../projs/pub_logs/logs_attn';

cfg.mdls = {'data','indp'};
cfg.ci = 1;
cfg.badsubs = [8:30];
out = deevGetEmerDep(cfg)

