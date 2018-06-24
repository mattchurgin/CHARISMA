function ComputeActivityMatt_24WellPlate(d, imageTimeArray, activePeriodsArray, analysisInterval, srcImageFolder, destAnalysisRoot,ROI,savenamePrefix)
                               
    [upperPath, deepestFolder] = fileparts(srcImageFolder);                           
    srcImageChip = deepestFolder;
    
    % check if pdata folder is available
    pdataFolder = [destAnalysisRoot '\' srcImageChip '\' 'pdata (interval ' num2str(analysisInterval) ' sec)'];  
    if ~exist(pdataFolder, 'dir')
        mkdir(pdataFolder);
    end
    
    warning('off')
    % Define gau function
    x=-5:5;
    y=x;
    [xx, yy]=meshgrid(x,y);
    gs=1;
    gau=exp(-sqrt(xx.^2+yy.^2)/gs^2);
    
    activitythresh = 0.25;
    activitythreshAbsolute=25;
    curROInum = 0;

    % Analyze activity
    periodCount = size(activePeriodsArray, 1);


    for curPeriod=1:periodCount
%         if ~isReanalyzeAll
%             if exist([pdataFolder '\' 'pdata' num2str(activePeriodsArray(curPeriod, 1)) '.mat'], 'file')
%                 continue;
%             end
%         end
        
       %% Initialize
        numWells = size(ROI,3);
        numImages = activePeriodsArray(curPeriod, 2) - activePeriodsArray(curPeriod, 1) + 1;
        pdata=zeros(numImages,numWells);
        pdata(:,:) = -1;            % -1 means empty (no data available)
        stimulationBegin = activePeriodsArray(curPeriod, 4);
        stimulationEnd = activePeriodsArray(curPeriod, 5);
        
        for q=stimulationBegin:stimulationEnd
            pdata(q - activePeriodsArray(curPeriod, 1) + 1,:) = -2;
        end
        
        
        % Backward scanning
        namea = '';
        nameb = '';
%         if curROInum ~= activePeriodsArray(curPeriod, 7)
%             %load([ROIsFolder '\' 'ROI' num2str(activePeriodsArray(curPeriod, 7)) '.mat']);
%             ROI = round(ROI);
%             curROInum = activePeriodsArray(curPeriod, 7);
%         end        
        for numb = (stimulationBegin-1):-1:(activePeriodsArray(curPeriod, 1) - 1)
            %pause(0.01);

            % Find proper previous image
            numa = 0;
            for curImageID = (numb-1):-1:(activePeriodsArray(curPeriod, 1) - 1)
                timeDiffInSec = ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(numb,:), imageTimeArray(curImageID, :));
                if timeDiffInSec >= round(analysisInterval-4) && ...
                   timeDiffInSec <= round(analysisInterval+4)
                    numa = curImageID;
                    break;
                end
            end
            if numa == 0
                continue;
            end



            % Load fist image file
            namea = [srcImageFolder '\' d(numa).name];
            tempImg = imread(namea);
            if ndims(tempImg) ==3 
                tempImg = rgb2gray(tempImg);
            end
            imga = uint16(tempImg);


            % Load second image file
            nameb = [srcImageFolder '\' d(numb).name]; 
            if strcmp(namea, nameb)
                imgb = imga;
            else
                tempImg = imread(nameb);
                    if ndims(tempImg) ==3 
                        tempImg = rgb2gray(tempImg);
                    end
                imgb = uint16(tempImg);
            end


            % Compute activity
            imgaBlur = conv2(double(imga), gau, 'same');
            imgbBlur = conv2(double(imgb), gau, 'same');
            activityC2=abs(imgaBlur-imgbBlur)./(imgaBlur+imgbBlur);
            activityC=activityC2>activitythresh;    

           
            % Count the number of white pixels in the binary differential image
            for n = 1:numWells
                imagesc((activityC.*squeeze(ROI(:,:,n))));colormap(gray);drawnow
                pdata(numb- activePeriodsArray(curPeriod, 1)  + 1,n)=sum(sum(activityC.*squeeze(ROI(:,:,n))));
                %pdata(numb- activePeriodsArray(curPeriod, 1)  + 1,n)=sum(sum(activityC(squeeze(ROI(:,:,n)))));
                %display( pdata(numb,n));
            end 


            display(['Backward scanning at ' '\' deepestFolder '\'   d(numb).name...
                     '   Processed: ' num2str((stimulationBegin-1-numb)/numImages*100, '%.2f') ' %'])
        end

        
        
        %% before and after stimulation 
        namea = '';
        nameb = '';
        numb = 0;
%         if curROInum ~= activePeriodsArray(curPeriod, 8)
%             %load([ROIsFolder '\' 'ROI' num2str(activePeriodsArray(curPeriod, 8)) '.mat']);
%             ROI = round(ROI);
%             curROInum = activePeriodsArray(curPeriod, 8);
%         end           
        
            % Find proper next image
            numa = stimulationBegin-1;
            for curImageID =stimulationEnd+1:activePeriodsArray(curPeriod, 2)
                timeDiffInSec = ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(numa,:), imageTimeArray(curImageID, :));
                if timeDiffInSec >= round(analysisInterval-4) && ...
                   timeDiffInSec <= round(analysisInterval+4)
                    numb = curImageID;
                    break;
                end
            end
            if numb ~= 0
                % Load fist image file
                namea = [srcImageFolder '\' d(numa).name];
                if strcmp(namea, nameb)
                    imga = imgb;
                else
                    tempImg = imread(namea);
                    if ndims(tempImg) ==3 
                        tempImg = rgb2gray(tempImg);
                    end
                    imga = uint16(tempImg);
                end


                % Load second image file
                nameb = [srcImageFolder '\' d(numb).name]; 
                tempImg = imread(nameb);
                    if ndims(tempImg) ==3 
                        tempImg = rgb2gray(tempImg);
                    end
                imgb = uint16(tempImg);
                %display([fileNames{numa} ' & ' fileNames{numb}]);


                % Compute activity
                imgaBlur = conv2(double(imga), gau, 'same');
                imgbBlur = conv2(double(imgb), gau, 'same');
                activityC2=abs(imgaBlur-imgbBlur)./(imgaBlur+imgbBlur);
                activityC=activityC2>activitythresh;    



                % Count the number of white pixels in the binary differential image
                
                for n = 1:numWells
                     imagesc((activityC.*squeeze(ROI(:,:,n))));colormap(gray);drawnow
                     pdata(numb- activePeriodsArray(curPeriod, 1)  + 1,n)=sum(sum(activityC.*squeeze(ROI(:,:,n))));
                %pdata(numb- activePeriodsArray(curPeriod, 1) + 1,n)=sum(sum(activityC(squeeze(ROI(:,:,n)))));
                end 
            end
        
        
        

        %% Forward scanning
        namea = '';
        nameb = '';
%         if curROInum ~= activePeriodsArray(curPeriod, 8)
%             %load([ROIsFolder '\' 'ROI' num2str(activePeriodsArray(curPeriod, 8)) '.mat']);
%             ROI = round(ROI);
%             curROInum = activePeriodsArray(curPeriod, 8);
%         end           
        for numa = (stimulationEnd+1):(activePeriodsArray(curPeriod, 2)-1)
            %pause(0.01);
            % Find proper next image
            numb = 0;
            for curImageID = numa+1:activePeriodsArray(curPeriod, 2)
                timeDiffInSec = ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(numa,:), imageTimeArray(curImageID, :));
                if timeDiffInSec >= round(analysisInterval-4) && ...
                   timeDiffInSec <= round(analysisInterval+4)
                    numb = curImageID;
                    break;
                end
            end
            if numb == 0
                continue;
            end

            % Load fist image file
            namea = [srcImageFolder '\' d(numa).name];
            if strcmp(namea, nameb)
                imga = imgb;
            else
                tempImg = imread(namea);
                if ndims(tempImg) ==3 
                    tempImg = rgb2gray(tempImg);
                end
                imga = uint16(tempImg);
            end


            % Load second image file
            nameb = [srcImageFolder '\' d(numb).name]; 
            tempImg = imread(nameb);
                if ndims(tempImg) ==3 
                    tempImg = rgb2gray(tempImg);
                end
            imgb = uint16(tempImg);

            %display([fileNames{numa} ' & ' fileNames{numb}]);

            % Compute activity
            imgaBlur = conv2(double(imga), gau, 'same');
            imgbBlur = conv2(double(imgb), gau, 'same');
            activityC2=abs(imgaBlur-imgbBlur)./(imgaBlur+imgbBlur);
            activityC=activityC2>activitythresh;    



            % Count the number of white pixels in the binary differential image
            for n = 1:numWells
                 imagesc((activityC.*squeeze(ROI(:,:,n))));colormap(gray);drawnow
                 pdata(numb- activePeriodsArray(curPeriod, 1)  + 1,n)=sum(sum(activityC.*squeeze(ROI(:,:,n))));
                %pdata(numb- activePeriodsArray(curPeriod, 1) + 1,n)=sum(sum(activityC(squeeze(ROI(:,:,n)))));
            end 


            display(['Forward scanning at ' '\' deepestFolder '\'   d(numb).name...
                     '   Processed: ' num2str((numb- activePeriodsArray(curPeriod, 1) + 1)/numImages*100, '%.2f') ' %'])

        end

        
        
        save([pdataFolder '\' savenamePrefix '_pdata'  num2str(activePeriodsArray(curPeriod, 1)) '.mat'],'pdata');
        %display('### Activity analysis completed ###');
        
    end
 

end
