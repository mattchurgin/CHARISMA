function [] = realTimeImageProcessing_24WellPlate(foldername,imageFileExtension,ROIFileName,ROI_Directory,savenamePrefix)
% 24-Well plate w/ light stimulation real-time image processing function
% By Matt Churgin.  Last updated 11 Feb. 2018
% foldername is the directory with the images
% imageFileExtension
% ROIFile name is the file name of the ROI file
% ROI_directory is the directory where the ROI file exists
% savenamePrefix is a prefix added to each pdata file saved to help with
% uniquely identifying the saved data

ROILoaded=load([ROI_Directory '\' ROIFileName]);
ROI=logical(ROILoaded.maskSorted);

% only run the code if the ROI file is correct.  Should be 1944x2592x24
if size(ROI,3)==24
    srcDir=foldername;
    destAnalysisFolder = [srcDir '\Analysis60'];
    
    if ~exist(destAnalysisFolder, 'dir')
        mkdir(destAnalysisFolder);
    end
    
    d=dir([srcDir '\*.' imageFileExtension]);
    
    imageTimeArray = GetImageTimeArrayMatt(d);
    
    %disp('Searching active imaging periods');
    maxTimeIntervalSec = 30;
    minDurationMin = 1;
    activePeriodsArray = SearchActiveImagingPeriodsMatt(imageTimeArray, maxTimeIntervalSec, minDurationMin);
    %disp('Done');
    
    activePeriodsArray = SearchStimulationTimeMatt(srcDir, d, imageTimeArray, activePeriodsArray);
    
    save([destAnalysisFolder '\fileNames.mat'], 'd');
    save([destAnalysisFolder '\imageTimeArray.mat'], 'imageTimeArray');
    save([destAnalysisFolder '\activePeriods.mat'],'activePeriodsArray');
    
    %display(['Beginning image processing for folder ' foldername '.'])
    analysisInterval = 60; % Analysis interval in seconds
    try
        ComputeActivityMatt_24WellPlate_REVISED(d, imageTimeArray, activePeriodsArray, analysisInterval, srcDir, destAnalysisFolder,ROI,savenamePrefix);
    catch
        display(['activity analysis failed for folder name: ' foldername])
    end
end

