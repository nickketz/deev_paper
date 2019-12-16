addpath('deev')

clear cfg
cfg.doplots = 0;
cfg.mdls = {'data','indp'};

%generated logs
% dirs = {
%     '../projs/logs_DeEv_recog_0.25ECdeep_0CA1deep_2trainepochs',
%     '../projs/logs_DeEv_recog_0ECdeep_0CA1deep_2trainepochs'
%     };

%publication logs
dirs = {
    '../projs/pub_logs/logs_attn',
    '../projs/pub_logs/logs_null',
    };

outs = {};
for idir = 1:length(dirs)
    cfg.dir = dirs{idir};
    cfg.ci = 1;
    outs{idir} = deevGetEmerDep(cfg);
end
%plot_dep_by_epochs(outs,cfg)

avgdepdif = outs{1}.avgdepdif - outs{2}.avgdepdif;

nsubs = length(outs{1}.logdata.lognames);
mdls = {'data','indp','dpnd','dpndg'};
mdlinds = find(ismember(cfg.mdls,mdls));
if cfg.ci
    crit = tinv(.975,nsubs-1);
else
    crit = 1;
end
blkstr = 'avg';
barstr = {'data','indp','dpnd','dpnd+g'};



%plot dependency
h = figure('color','white','name',blkstr);
mycolors = get(gca,'defaultAxesColorOrder');
tmp = outs{1}.avgdep(:, mdlinds, :) - outs{2}.avgdep(:, mdlinds, :) ;
errorbar_groups(mean(tmp,3)',crit*ste(tmp,3)','bar_names',{'Open Loop','Closed Loop'},'bar_colors',mycolors,'FigID',h,...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
legend(barstr(mdlinds),'location','best');
title('Dependency');
ylim([min(min(mean(tmp,3)))-.1, max(max(mean(tmp,3)))+.1 ]);
%ylim([.6 .9]);
set(gca,'fontsize',20);





h = figure('color','white','name',blkstr);
mycolors = get(gca,'defaultAxesColorOrder');
avgdepdif = avgdepdif(:,1,:);
[bar,hb,he] = errorbar_groups(squeeze(mean(avgdepdif,1))',crit*squeeze(ste(avgdepdif,1))','bar_names',{'OpenLoop','ClosedLoop'},'bar_colors',mycolors(2:end,:),'FigID',h,...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
legend({'dIndp'},'location','best');
title('Delta Dependency');
set(gca,'fontsize',20);
%plot significance?
if nsubs>1
    mu = squeeze(mean(avgdepdif,1));
    for ibar = 1:length(bar)
        [sig,p,ci,stat] = ttest(avgdepdif(:,:,ibar));
        for isig = 1:length(sig)
            if sig(isig)
                dif = [-1 0 1];
                ptext = sprintf('*,t=%.02f',stat.tstat(isig));
                if p(isig)<0.01     ptext = [ptext '*'];    end
                if p(isig)<0.001    ptext = [ptext '*'];    end
%                 text((bar(ibar)+dif(isig))*1.1, (mu(isig,ibar))*1.1, ptext,'fontsize',20);
                text((bar(ibar)+dif(isig))*1.1, (mu(ibar,isig))*1.1, ptext,'fontsize',20);
            end
        end
    end
end


%plot non-target acc
tmps = {};
oProbs = {};
cProbs = {};
for i = 1:length(outs)
    in = outs{i};
    nEvts = size(in.ntCueTarg,1);
    ol = in.ntCueTarg(1:nEvts/2,:,:);
    cl = in.ntCueTarg(nEvts/2+1:end,:,:);
    olacc = squeeze(mean(ol,1))';
    clacc = squeeze(mean(cl,1))';
    tmp = cat(3,olacc,clacc); 
    tmp = permute(tmp,[3,1,2]);
    tmps{i} = tmp;
    oProbs{i} = in.oProb;
    cProbs{i} = in.cProb;
end
mutmp = mean(tmps{1},3) - mean(tmps{2},3);
stetmp = sqrt(std(tmps{1},0,3).^2/size(tmps{1},3) + std(tmps{2},0,3).^2/size(tmps{2},3));
dntacc = outs{1}.ntacc-outs{2}.ntacc;
oProb = oProbs{1} - oProbs{2};
cProb = cProbs{1} - cProbs{2};
probDO = in.probDO;
mycolors = distinguishable_colors(2,{'w','k'});
[xtick,hb,he] = errorbar_groups(mutmp, crit*stetmp,'bar_names',in.ntCueTargDO{3},...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
legend({'Open Loop','Closed Loop'});
hold on


ntacc = mean(dntacc,2)';
ntste = ste(dntacc,2);
for icond = 1:2
    shadedErrorBar(xlim, repmat(ntacc(icond),2,1), repmat(crit.*ntste(icond),2,1),...
        {'--','linewidth',2,'color',mycolors(icond,:),'markerfacecolor',mycolors(1,:)},1);
end

set(gca,'fontsize',20);
ylabel('delta non-target accuracy');





%plot cued recog acc
h = figure('color','white','name',blkstr);
mycolors = distinguishable_colors(8,{'w','k'});
hold on
mymin = 1;
a = [];
stops = [-1.5 -.5 .5 1.5];
for iaxis = 1:2
    a(iaxis) = subplot(1,2,iaxis);
    if iaxis == 1, idim = 2; else idim = 1; end %hack to fix mean dimenison mismatch
    omu = squeeze(nanmean(oProb,idim)); if size(omu,1)~= 4, omu = omu'; end
    cmu = squeeze(nanmean(cProb,idim)); if size(cmu,1)~=4, cmu = cmu'; end
    mu = cat(3,omu,cmu);
    mu = permute(mu, [3 1 2]);
    
    [xtick,hb,he]=errorbar_groups(mean(mu,3)', crit*ste(mu,3)','bar_names',{'Open Loop','Closed Loop'},'FigID', h, 'AxID', a(iaxis),...
        'bar_colors',mycolors(1+((iaxis-1)*size(mycolors,1)/2):(iaxis*size(mycolors,1)/2),:),...
        'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
    
    legend(probDO{iaxis}');
    hold on
    vals = mean(mu,3);
    for ib = 1:length(hb)
        plot(repmat(xtick(1)+stops(ib),size(mu,3),2),squeeze(mu(1,ib,:)),'k.','markersize',20)
        plot(repmat(xtick(2)+stops(ib),size(mu,3),2),squeeze(mu(2,ib,:)),'k.','markersize',20)
    end
    
    
    if iaxis == 1,          ylabel('Accuracy');        end
    set(a(iaxis),'fontsize',20);
    if size(mu,3)>1
        mymin = min([mymin min(mean(mu,3)-(crit*ste(mu,3)))]);
    else
        mymin = min([mymin min(mu(:)-.1)]);
    end
end
for iaxis = 1:2
    ylim(a(iaxis),[mymin 1]);
end

