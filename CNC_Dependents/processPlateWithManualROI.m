function [] = processPlateWithManualROI(homeDirectory,inputtedLSMetric,inputtedHSMetric)
% Manual ROI selection
% inputtedLSMetric is for calculating lifespan score.  99 should be default
% inputtedHSMetric is for calculating lifespan score.  85 should be default
addpath(homeDirectory)

% select directory to process
currDirToProcess=uigetdir();
currFolders=dir(currDirToProcess);
processstarttime=clock;

display(['Beginning to process folder ' currDirToProcess])

roifilename='ROI.mat';

%if exist([currDirToProcess '\' roifilename])==0
    maskSorted=ROIDefineManual();
    close all
    save([currDirToProcess '\' roifilename],'maskSorted')
%end

imageFolders=cell(1,1);
tempVar=2;
for wantToProcess=3:length(currFolders)
    tempname=currFolders(wantToProcess).name;
    if tempname((end-2):end)~='mat'
        imageFolders{tempVar}=currFolders(wantToProcess).name;
        tempVar=tempVar+1;
    end
end


for currFolderToProcess=2:length(imageFolders)
    % for each folder in the plate's directory,
    % run real time analysis if an analysis
    % folder cannot already be found within the
    % folder
    files=dir([currDirToProcess '\' imageFolders{currFolderToProcess}]);
    for imageYN = 3:length(files)
        tempname=files(imageYN).name;
        if tempname((end-3):end)=='.png'
            break
        end
        
    end
    currFolderImageInfo=dir([currDirToProcess '\' imageFolders{currFolderToProcess} '\' tempname]);
    currFolderImageTime=currFolderImageInfo.datenum;
    
    % run the real-time analysis code
    %if exist([currDirToProcess '\' imageFolders{currFolderToProcess}  '\Analysis60'])==0
        display(['Beginning to process directory ' currDirToProcess ', folder ' imageFolders{currFolderToProcess}])
        realTimeImageProcessing_24WellPlate([currDirToProcess '\' imageFolders{currFolderToProcess}],'png',roifilename,[currDirToProcess],imageFolders{currFolderToProcess});
    %end
end
% Consolidate all pdata into a single .mat
% file accessible in the plate's home
% directory

[success] = consolidatePdata(currDirToProcess,['Consolidated.mat']);

% Analyze the consolidated data into a file
% with time vector, spontaneous and
% stimulated activity, and aggregated lifespan
% score
if success==1
    [stimulated, spontaneous, t, AggLS, CDFsum, mySuccess] = processPdata24WellPlate(currDirToProcess,['Consolidated.mat'],inputtedLSMetric,inputtedHSMetric,['Analyzed.mat']);
    
    if mySuccess==1
        display(['Successfully processed images, consolidated, and analyzed data for folder ' currDirToProcess '!']);
    end
end