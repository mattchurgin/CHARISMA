function [stimulated, spontaneous, t, AggLS, CDFsum, success] = processPdata24WellPlate(directory,filename,metricp,metrich,savename)
% processPdata24WellPlate process consolidated pdata that has been
% consolidated with consolidatePdata.m
% Averages pdata before and after light
% directory and filename specify the consolidated data to load
% savename is the name to save the file as (in the same directory)
% metricp is the cutoff for aggregate lifespan
% Returns the stimulated and spontaneous behavior for each well over each
% imaging period, the associated time vector, the aggregated
% lifespan-activity score, and the cumulative distribution function of
% activity for each well

success=0;
try
    cdat=load([directory '\' filename]);
    day=cdat.day;
    fnames=cdat.fnames;
    consolidatedP=cdat.consolidatedP;
    imagePeriod=cdat.imagePeriod;
    
    % Compute time from plate added to first image
    % important for calculating first time point of data
    infoFile=ls('*_plateInfo.mat');
    plateInfo=dir(infoFile);
    plateAddTime=plateInfo.datenum;
    imageFolders=dir(directory);
    i=1;
    for zz=3:length(imageFolders)
        if imageFolders(zz).isdir
            realImageFolders(i)=imageFolders(zz);
            imagenames=dir([directory '\' realImageFolders(i).name]);
            realImageFolderdate(i)=imagenames(3).datenum;
            i=i+1;
        end
    end
    [kk kki]=sort(realImageFolderdate);
    firstImageFolder=realImageFolders(kki).name;
    firstImageFolderImage=dir([directory '\' firstImageFolder]);
    firstImageTime=firstImageFolderImage(3).datenum;
    plateAgeAtFirstImage=firstImageTime-plateAddTime;
    
    % sort folders
    for i=1:length(fnames)
        dn(i)=fnames{i}.d(1).datenum;
    end
    [ix iy]=sort(dn);
    
    % first find first image of each day
    firstimage=cell(1,1);
    day=[];
    for i=1:length(iy)
        j=iy(i);
        firstimageTime{i}=fnames{j}.d(1).datenum;
        day(i)=firstimageTime{i};
    end
    
    day=round(2*(day-day(1)+plateAgeAtFirstImage))/2;
    
    t=zeros(1,length(imagePeriod));
    t(1)=day(1);
    daycounter=2;
    for i=2:length(imagePeriod)
        if imagePeriod(i)==2
            t(i)=t(i-1)+0.5;
        elseif imagePeriod(i)==1
            t(i)=day(daycounter);
            daycounter=daycounter+1;
        end
    end
    
    % Create pdata before and pdata after
    % spontaneous and stimulated are the mean activity before and after
    % blue light
    spontaneous=zeros(24,length(t));
    stimulated=zeros(24,length(t));
    
    % spontaneous95 and stimulated95 are 95th percentile of activity before
    % and after blue light
    spontaneous95=zeros(24,length(t));
    stimulated95=zeros(24,length(t));
    
    for i=1:length(t)
        currp=consolidatedP{i};
        bluelighttime=find(currp(:,1)==-2);
        
        % remove unfilled pdata (-1) values
        burntime=find(currp(:,1)==-1);
        currp(burntime,:)=NaN;
        
        % delete data in which all frames spike above a threshold
%         spiketemp=nanmean(currp,2);
%         spikeframes=find(spiketemp>5000);
%         currp(spikeframes,:)=NaN;
        
        % delete activity frame one minute after blue light
        % assumes subtraction interval is 60 seconds with 5 seconds between
        % images!!!! may need to adapt if using other parameters
        currp(bluelighttime+11,:)=NaN;
        
        spontaneous(:,i)=nanmean(currp(1:(bluelighttime(1)-2),:),1);
        stimulated(:,i)=nanmean(currp((bluelighttime(end)+2):end,:),1);
        
        for jj=1:24
            spontaneous95(jj,i)=prctile(currp(1:(bluelighttime(1)-2),jj),95);
            stimulated95(jj,i)=prctile(currp((bluelighttime(end)+2):end,jj),95);
        end
    end
    
    % Delete wells with low activity
    %     lowThreshold=10;
    %     earlyT=find(t<6); % find time points less than 6 days
    %     for i=1:24
    %         medA=prctile(stimulated(i,earlyT),50); % find median of activity over first 6 days
    %
    %         if medA<lowThreshold
    %             stimulated(i,:)=NaN;
    %             spontaneous(i,:)=NaN;
    %         end
    %     end
    
    % Create cumulative distribution function for each well
    CDFsum=zeros(24,length(t));
    CDFsum95=zeros(24,length(t));
    for i=1:24
        for j=1:length(t)
            CDFsum(i,j)=nansum(stimulated(i,1:j));
            CDFsum95(i,j)=nansum(stimulated95(i,1:j));
        end
        CDFsum(i,:)=CDFsum(i,:)/CDFsum(i,end);
        CDFsum95(i,:)=CDFsum95(i,:)/CDFsum95(i,end);
    end
    
    % Find aggregate lifespan score for each well
    AggLS=zeros(1,24);
    AggHS=zeros(1,24);
    AggLS95=zeros(1,24);
    AggHS95=zeros(1,24);
    for i=1:24
        [t1 t2]=find(CDFsum(i,:)>metricp/100);
        [t3 t4]=find(CDFsum(i,:)>metrich/100);
        try
            AggLS(i)=t(t2(1));
            AggHS(i)=t(t4(1));
        catch
            AggLS(i)=NaN;
            AggHS(i)=NaN;
        end
        
        [t1 t2]=find(CDFsum95(i,:)>metricp/100);
        [t3 t4]=find(CDFsum95(i,:)>metrich/100);
        try
            AggLS95(i)=t(t2(1));
            AggHS95(i)=t(t4(1));
        catch
            AggLS95(i)=NaN;
            AggHS95(i)=NaN;
        end
    end
    
    save([directory '\' savename],'stimulated','spontaneous','stimulated95','spontaneous95','t','AggLS','AggHS','CDFsum','AggLS95','AggHS95','CDFsum95')
    success=1;
catch
    stimulated=[];
    spontaneous=[];
    t=[];
    AggLS=[];
    AggHS=[];
    CDFsum=[];
    stimulated95=[];
    spontaneous95=[];
    AggLS95=[];
    AggHS95=[];
    CDFsum95=[];
end
