function ComputeActivityMatt_24WellPlate_REVISED(d, imageTimeArray, activePeriodsArray, analysisInterval, srcImageFolder, destAnalysisRoot,ROI,savenamePrefix)

[upperPath, deepestFolder] = fileparts(srcImageFolder);
srcImageChip = deepestFolder;

% check if pdata folder is available
pdataFolder = [destAnalysisRoot];
if ~exist(pdataFolder, 'dir')
    mkdir(pdataFolder);
end

warning('off')

% Define gaussian smoothing function
x=-5:5;
y=x;
[xx, yy]=meshgrid(x,y);
gs=1;
gau=exp(-sqrt(xx.^2+yy.^2)/gs^2);
blurFilter = [1,1,1;1,1,1;1,1,1];
activitythresh = 0.2;
pixelLimit=150;
%activitythresh=50;
curROInum = 0;

% Analyze activity
periodCount = size(activePeriodsArray, 1);


for curPeriod=1:periodCount
    % Initialize
    numWells = size(ROI,3);
    numImages = activePeriodsArray(curPeriod, 2) - activePeriodsArray(curPeriod, 1) + 1;
    pdata=zeros(numImages,numWells);
    pdata(:,:) = -1;            % -1 means empty (no data available)
    stimulationBegin = activePeriodsArray(curPeriod, 4);
    stimulationEnd = activePeriodsArray(curPeriod, 5);
    
    % Backward scanning
    namea = '';
    nameb = '';
    for numb = activePeriodsArray(curPeriod, 1):(activePeriodsArray(curPeriod, 2))
        % Find proper previous image
        numa = 0;
        for curImageID = (numb-1):-1:(activePeriodsArray(curPeriod, 1))
            timeDiffInSec = ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(numb,:), imageTimeArray(curImageID, :));
            if timeDiffInSec >= round(analysisInterval-4) && ...
                    timeDiffInSec <= round(analysisInterval+4)
                numa = curImageID;
                %display([' found image ' num2str(numa) ' for image ' num2str(numb)])
                break;
            end
        end
        
        % Load first image file
        if numa~=0
            namea = [srcImageFolder '\' d(numa).name];
            tempImg = imread(namea);
            if ndims(tempImg) ==3
                tempImg = rgb2gray(tempImg);
            end
            imga = double(tempImg);
            
            
            % Load second image file
            nameb = [srcImageFolder '\' d(numb).name];
            if strcmp(namea, nameb)
                imgb = imga;
            else
                tempImg = imread(nameb);
                if ndims(tempImg) ==3
                    tempImg = rgb2gray(tempImg);
                end
                imgb = double(tempImg);
            end
            
            
            % Compute activity
            % percentage change threshold
            imga(imga>pixelLimit)=NaN;
            imgb(imgb>pixelLimit)=NaN;
            activityC2=conv2(abs(imga-imgb)./(imga+imgb),gau,'same');
            %activityC2=conv2(abs(imga-imgb),gau,'same');
            activityC=(activityC2>activitythresh);
            
            %             imagesc(activityC.*sum(ROI,3))
            %             colormap(gray)
            %             drawnow
            
            
            % Count the number of white pixels in the binary differential image
            for n = 1:numWells
                pdata(numb- activePeriodsArray(curPeriod, 1)  + 1,n)=nansum(nansum(activityC.*squeeze(ROI(:,:,n))));
            end
            display(['Processing image: ' '\' deepestFolder '\'   d(numb).name])
        end
        
    end
    
    for q=stimulationBegin:stimulationEnd
        pdata(q - activePeriodsArray(curPeriod, 1) + 1,:) = -2;
    end
    
    successfullyprocesseddata=1;
    save([pdataFolder '\' savenamePrefix '_pdata'  num2str(curPeriod,'%02d') '.mat'],'pdata','successfullyprocesseddata');
    display('### Activity analysis completed ###');
    
end
