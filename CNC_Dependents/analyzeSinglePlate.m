%  Analyze a single 24-well plate data collected with CHARISMA imaging
%  robot
% Saved Output include currentplateLS and currentplateHS, lifespan and
% healthspan estimates for each of 24 wells
% Output saved as *_postprocessed.mat with original plate name prefix
% Matt Churgin, 2018, Fang-Yen Lab
clear all
close all

LSMetric=99; % lifespan cumulative activity cutoff
HSMetric=85; % healthspan cumulative activity cutoff

[fname pname]=uigetfile('*Analyzed.mat'); % get analyzed data file
sname=[fname(1:end-12) 'postprocessed'];

timecutoff=30; % cut data off after this day (make large if not applicable)
minamplitude=200; % min amplitude for early time points for automatically removing empty wells

currf=load([pname '/' fname]);

% delete all data after cutoff day (when thigns get noisier)
if max(currf.t)>timecutoff
    [yf yi]=find(currf.t>timecutoff);
    currf.stimulated(:,yi)=0;
    currf.spontaneous(:,yi)=0;
    for j=1:24
        for z=1:length(currf.t)
            currf.CDFsum(j,z)=nansum(currf.stimulated(j,1:z));
        end
        currf.CDFsum(j,:)=currf.CDFsum(j,:)/currf.CDFsum(j,end);
    end
end

% recalculate agg ls and agghs to remove late time points (if applicable)
for j=1:24
    [t1 t2]=find(currf.CDFsum(j,:)>LSMetric/100);
    [t3 t4]=find(currf.CDFsum(j,:)>HSMetric/100);
    
    try
        currf.AggLS(j)=currf.t(t2(1));
        currf.AggHS(j)=currf.t(t4(1));
    catch
        currf.AggLS(j)=NaN;
        currf.AggHS(j)=NaN;
    end
end


% remove low amplitude wells
for j=1:24
    if nanmean(currf.stimulated(j,1:10))<minamplitude
        currf.AggLS(j)=NaN;
        currf.AggHS(j)=NaN;
    end
end


% Save current plate data
currentplateHS=currf.AggHS;
currentplateLS=currf.AggLS;
CDFsum=currf.CDFsum;
stimulated=currf.stimulated;
spontaneous=currf.spontaneous;

% Save heat map for plate
figure
imagesc(currf.t,1:24,currf.stimulated)
hold on
colorbar
plot(currf.AggLS,1:24,'x','Color',[0.1 0.8 0.8],'MarkerSize',15,'LineWidth',2)
plot(currf.AggHS,1:24,'o','Color',[0.9 0.3 0.8],'MarkerSize',15,'LineWidth',2)
ylabel('Well #')
xlabel('Time (Days)')
set(gca,'FontSize',15)
saveas(gcf,[pname '/' sname '_heatmap'],'bmp')

figure
plot(1:24,currentplateLS,'ko','LineWidth',3)
xlabel('Well Number')
ylabel('T_{99} (Days)')
box off
set(gca,'FontSize',15)

figure
plot(1:24,currentplateHS,'ko','LineWidth',3)
xlabel('Well Number')
ylabel('T_{85} (Days)')
box off
set(gca,'FontSize',15)

% Save .mat file
save([pname '/' sname],'currentplateLS','currentplateHS','CDFsum','stimulated','spontaneous')

% Save .csv file for lifespan and healthspan
fid = fopen([pname '/' sname 'LSHS.csv'], 'w') ;
fprintf(fid, '%s,', 'T99 (Lifespan Estimate, Days)');
fprintf(fid, '%s\n', 'T85 (Healthspan Estimate, Days)');
for i=1:24
    fprintf(fid, '%s,', num2str(currentplateLS(i))) ;
    fprintf(fid, '%s\n', num2str(currentplateHS(i))) ;
end
fclose(fid) ;