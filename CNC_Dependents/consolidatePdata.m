function [success] = consolidatePdata(directory,savename)
% consolidatePdata finds pdata within a directory and saves the
% consolidated pdatas in the directory
% returns success=1 if pdata was found and consolidated
% returns success=0 if no pdata was found
% returns success=2 if something went wrong
% consolidatePdata saves the consolidated pdata in 'directory' under
% filename 'savename' along with an associated day vector and image period
% vector to identify the timing between each pdata file

try
    cd(directory)
    currFiles=dir(directory);
    currFiles=currFiles(3:end);
    
    currFolders=cell(1,1);
    j=1;
    for i=1:length(currFiles)
        if strcmp(currFiles(i).name((end-2):end),'mat')==0
            day(j)=str2num(currFiles(i).date(1:2));
            currFolders{j}=currFiles(i).name;
            j=j+1;
        end
    end
    
    % sort folders
    for i=1:length(currFolders)
        a=dir(currFolders{i});
       dn(i)=a(3).datenum;
    end
    [ix iy]=sort(dn);
    currFolders=currFolders(iy);
    
    currentPdata=1;
    consolidatedP=cell(1,1);
    fnames=cell(1,1);
    day=[];
    daycounter=0;
    imagePeriod=[];
    success=0;
    for possibleFolder=1:length(currFolders)
        tname=currFolders{possibleFolder};
        if exist([directory '\' tname '\Analysis60'])~=0
            imageperiodcounter=1;
            daycounter=daycounter+1;
            currFiles2=dir([directory '\' tname '\Analysis60']);
            fnames{daycounter}=load([directory '\' tname '\Analysis60\fileNames.mat']);
            for possiblePdata = 3:length(currFiles2)
                tempname=currFiles2(possiblePdata).name;
                if strcmp(tempname((end-10):(end-6)),'pdata')
                    if imageperiodcounter<3 % there should only be 2 pdata per day.  any additional imaging periods are not counted.
                        tempP=load([directory '\' tname '\Analysis60\' tempname]);
                        success=1;
                        %if exist('tempP.successfullyprocesseddata')
                            consolidatedP{currentPdata}=tempP.pdata;
%                         else
%                             consolidatedP{currentPdata}=[];
%                         end
                        day(currentPdata)=daycounter;
                        imagePeriod(currentPdata)=imageperiodcounter;
                        imageperiodcounter=imageperiodcounter+1;
                        currentPdata=currentPdata+1;
                    end
                end
            end
            
        end
    end
    save([directory '\' savename],'consolidatedP','fnames','day','imagePeriod');
catch
    success=2;
end