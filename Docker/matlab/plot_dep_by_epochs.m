function plot_dep_by_epochs(ins,cfg)
%
%function to produce behavioral plots for deev experiments
%
% input:
%   in: data struct from deevGetLogDep/deevBlkGetLogDep
%   cfg: config struct
%       ci = bool confidence interval? def=1
%       blk = array of which blocks to do plots on, or 'avg' implies an
%             average across blocks, def='avg'
%       mdl = cell array of which models to plot, default {'ind','dpn','dpng'}
%       blkplts = bool, do block plots of accuracy, dependency and ol vs cl
%       delta dep, def=0
%
%
%

%set defaults
if ~exist('cfg','var')      cfg = [];                                   end
if ~isfield(cfg,'ci')       cfg.ci = 1;                                 end
if ~isfield(cfg,'blk')      cfg.blk = 'avg';                            end
if ~isfield(cfg,'mdls')     cfg.mdls = {'data','indp','dpnd','dpndg'};  end
if ~isfield(cfg,'blkplts')  cfg.blkplts = 0;                            end

for iin = 1:length(ins)
    in = ins{iin};


    %is in from the blk version of the study?
    blkstr = '';
    if length(size(in.dep))==6 || length(in.subs)==1

        if strcmp(cfg.blk, 'avg')
            %create block averages for plotting
            avgdep = squeeze(mean(in.avgdep,ndims(in.avgdep)));
            avgdepdif = squeeze(mean(in.avgdepdif,ndims(in.avgdepdif)));
            oProb = squeeze(mean(in.oProb,ndims(in.oProb)));
            cProb = squeeze(mean(in.cProb,ndims(in.cProb)));
            probDO = in.probDO(1:end-1);
            blkstr = 'avg';
        else
            %sub sample specific block
            avgdep = in.avgdep(:,:,:,cfg.blk);
            avgdepdif = in.avgdepdif(:,:,:,cfg.blk);
            oProb = in.oProb(:,:,:,cfg.blk);
            cProb = in.cProb(:,:,:,cfg.blk);
            probDO = in.probDO(1:end-1);
            blkstr = num2str(cfg.blk);
        end

    else %not in blocks
        avgdep = in.avgdep;
        avgdepdif = in.avgdepdif;
        oProb = in.oProb;
        cProb = in.cProb;
        probDO = in.probDO;
    end

    nsubs = length(in.logdata.lognames);

    mdls = {'data','indp','dpnd','dpndg'};
    mdlinds = find(ismember(cfg.mdls,mdls));

    if cfg.ci
        crit = tinv(.975,nsubs-1);
    else
        crit = 1;
    end

    barstr = {'data','indp','dpnd','dpnd+g'};

    %plot dependency
    h = figure('color','white','name',blkstr);
    mycolors = get(gca,'defaultAxesColorOrder');
    tmp = avgdep(:, mdlinds, :);
    errorbar_groups(mean(tmp,3)',crit*ste(tmp,3)','bar_names',{'Open Loop','Closed Loop'},'bar_colors',mycolors,'FigID',h,...
        'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
    legend(barstr(mdlinds),'location','best');
    title('Dependency');
    ylim([min(min(mean(tmp,3)))-.1 1]);
    %ylim([.6 .9]);
    set(gca,'fontsize',20);
    

    %plot interaction
    h = figure('color','white','name',blkstr);
    mycolors = get(gca,'defaultAxesColorOrder');
    [bar,hb,he] = errorbar_groups(squeeze(mean(avgdepdif,1)),crit*squeeze(ste(avgdepdif,1)),'bar_names',{'OpenLoop','ClosedLoop'},'bar_colors',mycolors(2:end,:),'FigID',h,...
        'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
    legend({'dIndp','dDpnd','dDpnd+G'},'location','best');
    title('Delta Dependency');
    %ylim([min(depdif(:)) max(depdif(:))]);
    set(gca,'fontsize',20);
    %plot significance?
    if length(in.subs)>1
        mu = squeeze(mean(avgdepdif,1));
        for ibar = 1:length(bar)
            [sig,p,ci,stat] = ttest(avgdepdif(:,:,ibar));
            for isig = 1:length(sig)
                if sig(isig)
                    dif = [-1 0 1];
                    ptext = sprintf('*,t=%.02f',stat.tstat(isig));
                    if p(isig)<0.01     ptext = [ptext '*'];    end
                    if p(isig)<0.001    ptext = [ptext '*'];    end
                    text((bar(ibar)+dif(isig))*1.1, (mu(isig,ibar))*1.1, ptext,'fontsize',20);
                end
            end
        end
    end


    nEvts = size(in.ntCueTarg,1);
    ol = in.ntCueTarg(1:nEvts/2,:,:);
    cl = in.ntCueTarg(nEvts/2+1:end,:,:);
    olacc = squeeze(mean(ol,1))';
    clacc = squeeze(mean(cl,1))';
    tmp = cat(3,olacc,clacc); tmp = permute(tmp,[3,1,2]);
    mycolors = distinguishable_colors(2,{'w','k'});
    [xtick,hb,he] = errorbar_groups(mean(tmp,3), crit*ste(tmp,3),'bar_names',in.ntCueTargDO{3},...
        'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',5});
    legend({'Open Loop','Closed Loop'});
    hold on
    stops = [-.5 .5];
    for igrp = 1:length(xtick)
        plot(repmat(xtick(igrp)+stops(1),size(tmp,3),2),squeeze(tmp(1,igrp,:)),'k.','markersize',20)
        plot(repmat(xtick(igrp)+stops(2),size(tmp,3),2),squeeze(tmp(2,igrp,:)),'k.','markersize',20)
    end

    ntacc = mean(in.ntacc,2)';
    ntste = ste(in.ntacc,2);
    for icond = 1:2
        shadedErrorBar(xlim, repmat(ntacc(icond),2,1), repmat(crit.*ntste(icond),2,1),...
            {'--','linewidth',2,'color',mycolors(icond,:),'markerfacecolor',mycolors(1,:)},1);
    end

    set(gca,'fontsize',20);
    ylabel('non-target accuracy');

%     
%     
% 
%     %plot accuracy
%     figure('color','white','name',blkstr);
%     avgacc = mean(nanmean(oProb))
%     mymin = min([min(min(nanmean(oProb,3))), min(min(nanmean(cProb,3)))]);
%     mymax = max([max(max(nanmean(oProb,3))), max(max(nanmean(cProb,3)))]);
%     h=subplot(1,2,1);
%     imsc(nanmean(oProb,3), [mymin mymax], 'jet', [.5 .5 .5]);
%     set(gca, 'DataAspectRatioMode', 'auto');
%     set(h,'ytick',1:1:size(oProb,2));
%     set(h,'yticklabel',probDO{1});
%     set(h,'xtick', 1:size(oProb,1));
%     set(h,'xticklabel',probDO{2});
%     title('OpenLoop accuracy');
%     set(gca,'fontsize',16);
%     h=subplot(1,2,2);
%     imsc(nanmean(cProb,3), [mymin mymax], 'jet', [.5 .5 .5]); colorbar;
%     set(gca, 'DataAspectRatioMode', 'auto');
%     set(h,'ytick',1:1:size(cProb,2));
%     set(h,'yticklabel',probDO{1});
%     set(h,'xtick', 1:size(cProb,1));
%     set(h,'xticklabel',probDO{2});
%     title('ClosedLoop accuracy');
%     set(gca,'fontsize',16);
% 
%     
% 

    %plot by type
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



    
end
