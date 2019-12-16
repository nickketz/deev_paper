% addpath('~/Documents/DocumentsBoulder/MATLAB/deev/')
% addpath('~/Documents/DocumentsBoulder/MATLAB/sc/')
% addpath('/Users/naketz/Documents/MATLAB/export_fig/')

cfg.doplots = 0;
cfg.mdls = {'data','indp'}%,'dpnd','dpndg'};
% dirs = {'logs_DeEv_recog_0.25ECdeep_0.25CA1deep_1trainepochs',
%         'logs_plots', 
%         'logs_DeEv_recog_0.25ECdeep_0.25CA1deep_3trainepochs',
%         'logs_DeEv_recog_0.25ECdeep_0.25CA1deep_5trainepochs'};
dirs = {'logs_DeEv_recog_0.25ECdeep_0CA1deep_1trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_2trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_3trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_4trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_5trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_6trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_7trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_8trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_9trainepochs',
        'logs_DeEv_recog_0.25ECdeep_0CA1deep_10trainepochs',
        };
outs = {};
avgdd = [];
avgacc = [];
oprob = []; cprob = []; ntacc = [];
for idir = 1:length(dirs)
    cfg.dir = dirs{idir};
    cfg.ci = 1;
    cfg.badsubs = [8:12];
    outs{idir} = deevGetEmerDep(cfg);
    avgdd = cat(4,avgdd,outs{idir}.avgdepdif);
    oprob = cat(3,oprob,reshape(outs{idir}.oProb,[],8));
    cprob = cat(3,cprob,reshape(outs{idir}.cProb,[],8)); %cat(3,nanmean(reshape(nanmean(outs{idir}.cProb,3),[],1));
    ntacc = cat(3,ntacc,outs{idir}.ntacc);
end
davgdd = diff(avgdd,1,4);

y = squeeze(mean(davgdd(:,1,:,:),1));
err = squeeze(ste(davgdd(:,1,:,:),1))*tinv(.95,size(avgdd,1));

lsty = {'-k','-r'};
figure('color','white');hold on
h = [];
for i = 1:2
    if isempty(h)
        h = shadedErrorBar([],y(i,:),err(i,:),lsty{i},1);
    else
        h(i) = shadedErrorBar([],y(i,:),err(i,:),lsty{i},1);
    end
        
end
legend([h.mainLine],'openDepDiff','closedDepDiff')
ylabel('data-indp')
xlabel('training epochs');


lsty = {'-k','-r'};
figure('color','white');hold on
h = [];
dprob = {oprob,cprob};
for i = 1:2
    tmp = squeeze(nanmean(dprob{i}));
    y = squeeze(mean(tmp));
    err = squeeze(ste(tmp))*tinv(.95,size(tmp,1));

    if isempty(h)
        h = shadedErrorBar([],y,err,lsty{i},1);
    else
        h(i) = shadedErrorBar([],y,err,lsty{i},1);
    end
        
end
legend([h.mainLine],'openDepDiff','closedDepDiff')
ylabel('cued recog acc')
xlabel('training epochs');



%plot_dep_by_epochs(outs,cfg)
% export_fig figs/null/deevNull-Acc -pdf -png
% export_fig figs/null/deevNull-Dep -pdf -png
% export_fig figs/null/deevNull-DepSubs -pdf -png -transparent
% export_fig figs/null/deevNull-NonTarg -pdf -png -transparent
% export_fig figs/null/deevNull-dDep -pdf -png
