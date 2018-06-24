function [] = reprocessAllData(homeDirectory,parameterFile,startDate,endDate,robotOrCustom,reprocessOrConsolidate,inputtedLSMetric,inputtedHSMetric,platesAddedAfter)
% reprocessAllData reprocesses all data for plates currently in the robot
% system for images that have been added after startDate and before endDate in the format [year month day hour minute second]
% creates an ROI file for each day for each plate
% robotOrCustom is 0 or 1.  If zero, the code will process data for all
% plates currently in the parameterFile inputted by the user.  If
% robotOrCustom is 1, the user will be prompted to select manually select a
% folder.  All image folder contained therein will be processed.
% reprocessOrConsolidate is 0 or 1.  If 0, image folders will be processed
% in addition to consolidated and analyzed.  If 1, image folders will only be
% consolidated and analyzed.
% inputtedLSMetric is for calculating lifespan score.  98 should be default
% inputtedHSMetric is for calculating lifespan score.  80 should be default
% platesAddedAfter only processes plates who were added after the inputted
% time

addpath(homeDirectory)
firstDayToProcess=datenum(startDate(1),startDate(2),startDate(3),startDate(4),startDate(5),startDate(6));
lastDayToProcess=datenum(endDate(1),endDate(2),endDate(3),endDate(4),endDate(5),endDate(6));


if robotOrCustom==0
    allPlateInfo=load(parameterFile);
    platesToImage=find((allPlateInfo.savehandles.currPlates').*(allPlateInfo.savehandles.plateLocs')~=0);
    plateSaveDirs=allPlateInfo.savehandles.plateSaveDirectory';
    plateIDs=allPlateInfo.savehandles.plateIDs';
    processstarttime=clock;
    addDates=allPlateInfo.savehandles.plateAddDate';
    
    for currPlateToProcess_=1:length(platesToImage)
        
        currPlateToProcess=platesToImage(currPlateToProcess_);
        if datenum(addDates{currPlateToProcess})>datenum(platesAddedAfter)
            display(['Beginning to process plate #' num2str(currPlateToProcess)])
            
            currDirToProcess=[plateSaveDirs{currPlateToProcess} '\' plateIDs{currPlateToProcess}];
            currFolders=dir(currDirToProcess);
            
            imageFolders=cell(1,1);
            tempVar=2;
            for wantToProcess=3:length(currFolders)
                tempname=currFolders(wantToProcess).name;
                if tempname((end-2):end)~='mat'
                    imageFolders{tempVar}=currFolders(wantToProcess).name;
                    tempVar=tempVar+1;
                end
            end
            
            roifilename='ROI_Daily.mat';
            if length(imageFolders)>1 % check to see if any image folders exist
                if reprocessOrConsolidate==0
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
                        
                        if currFolderImageTime > firstDayToProcess && currFolderImageTime < lastDayToProcess
                            % Automatically find ROIs for 24 well plate
                            
                            if ~exist([currDirToProcess '\' imageFolders{currFolderToProcess} '\' roifilename])
                                [maskSorted center]= AutomaticallyFind_24WellPlateROIs([currDirToProcess '\' imageFolders{currFolderToProcess} '\' tempname]);
                                save([currDirToProcess '\' imageFolders{currFolderToProcess} '\' roifilename],'maskSorted');
                                
                                if maskSorted~=0
                                    display(['successfully made ROIs for plate ' currDirToProcess ' for folder ' imageFolders{currFolderToProcess}])
                                else
                                    display(['Failed to make ROIs for plate ' currDirToProcess ' for folder '  imageFolders{currFolderToProcess}])
                                end
                            end
                            
                            
                            % activity analysis
                            % reprocess data taken after the
                            % user-inputted start date
                            
                            % run the real-time analysis code
                            display(['Beginning to process plate #' num2str(currPlateToProcess) ', plate name ' currDirToProcess ', folder ' imageFolders{currFolderToProcess}])
                            realTimeImageProcessing_24WellPlate([currDirToProcess '\' imageFolders{currFolderToProcess}],'png',roifilename,[currDirToProcess '\' imageFolders{currFolderToProcess}],imageFolders{currFolderToProcess});
                        else
                            display(['Not processing plate #' num2str(currPlateToProcess) ', plate name ' currDirToProcess ', folder ' imageFolders{currFolderToProcess} ' because it was collected outside of user-inputted start and end date'])
                        end
                    end
                end
                % Consolidate all pdata into a single .mat
                % file accessible in the plate's home
                % directory
                [success] = consolidatePdata(currDirToProcess,[plateIDs{currPlateToProcess} '_Consolidated.mat']);
                
                % Analyze the consolidated data into a file
                % with time vector, spontaneous and
                % stimulated activity, and aggregated lifespan
                % score
                if success==1
                    [stimulated, spontaneous, t, AggLS, CDFsum, mySuccess] = processPdata24WellPlate(currDirToProcess,[plateIDs{currPlateToProcess} '_Consolidated.mat'],allPlateInfo.savehandles.LSMetric,allPlateInfo.savehandles.HSMetric,[plateIDs{currPlateToProcess} '_Analyzed.mat']);
                    
                    if mySuccess==1
                        display(['Successfully processed images, consolidated, and analyzed data for plate number '  num2str(currPlateToProcess) '!'])
                    end
                end
            else
                display(['No images yet for plate number '  num2str(currPlateToProcess) '.'])
            end
        end
    end
    display(['Finished processing all plates contained in robot parameter file!'])
elseif robotOrCustom==1
    dirtoprocess=uigetdir();
    currDfolders=dir(dirtoprocess);
    processstarttime=clock;
    
    for i=3:length(currDfolders)
        if currDfolders(i).isdir
            try
                display(['Beginning to process folder ' currDfolders(i).name])
                
                currDirToProcess=[dirtoprocess '\' currDfolders(i).name];
                currFolders=dir(currDirToProcess);
                
                imageFolders=cell(1,1);
                tempVar=2;
                for wantToProcess=3:length(currFolders)
                    tempname=currFolders(wantToProcess).name;
                    if tempname((end-2):end)~='mat'
                        imageFolders{tempVar}=currFolders(wantToProcess).name;
                        tempVar=tempVar+1;
                    end
                end
                
                roifilename='ROI_Daily.mat';
                if length(imageFolders)>1 % check to see if any image folders exist
                    if reprocessOrConsolidate==0
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
                            
                            if currFolderImageTime > firstDayToProcess && currFolderImageTime < lastDayToProcess
                                % Automatically find ROIs for 24 well plate
                                
                                if ~exist([currDirToProcess '\' imageFolders{currFolderToProcess} '\' roifilename])
                                    [maskSorted center]= AutomaticallyFind_24WellPlateROIs([currDirToProcess '\' imageFolders{currFolderToProcess} '\' tempname]);
                                    save([currDirToProcess '\' imageFolders{currFolderToProcess} '\' roifilename],'maskSorted');
                                    if maskSorted~=0
                                        display(['successfully made ROIs for plate ' currDirToProcess ' for folder ' imageFolders{currFolderToProcess}])
                                    else
                                        display(['Failed to make ROIs for plate ' currDirToProcess ' for folder '  imageFolders{currFolderToProcess}])
                                    end
                                end
                                
                                
                                % activity analysis
                                % reprocess data taken after the
                                % user-inputted start date
                                
                                % run the real-time analysis code
                                display(['Beginning to process directory ' currDirToProcess ', folder ' imageFolders{currFolderToProcess}])
                                realTimeImageProcessing_24WellPlate([currDirToProcess '\' imageFolders{currFolderToProcess}],'png',roifilename,[currDirToProcess '\' imageFolders{currFolderToProcess}],imageFolders{currFolderToProcess});
                            else
                                display(['Not processing directory ' currDirToProcess ', folder ' imageFolders{currFolderToProcess} ' because it was collected outside of user-inputted start and end date'])
                            end
                        end
                    end
                    % Consolidate all pdata into a single .mat
                    % file accessible in the plate's home
                    % directory
                    [success] = consolidatePdata(currDirToProcess,[currDfolders(i).name '_Consolidated.mat']);
                    
                    % Analyze the consolidated data into a file
                    % with time vector, spontaneous and
                    % stimulated activity, and aggregated lifespan
                    % score
                    if success==1
                        [stimulated, spontaneous, t, AggLS, CDFsum, mySuccess] = processPdata24WellPlate(currDirToProcess,[currDfolders(i).name '_Consolidated.mat'],inputtedLSMetric,inputtedHSMetric,[currDfolders(i).name '_Analyzed.mat']);
                        
                        if mySuccess==1
                            display(['Successfully processed images, consolidated, and analyzed data for folder '  currDfolders(i).name '!']);
                        end
                    end
                else
                    display(['No images yet in folder '  currDfolders(i).name '.'])
                end
            catch
                display([currDfolders(i).name ' is not a viable image folder'])
            end
        end
    end
    display(['Finished processing all plates contained in folder ' dirtoprocess '!'])
end
