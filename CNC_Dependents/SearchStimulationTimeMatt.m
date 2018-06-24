function retActivePeriodsArray = SearchStimulationTimeMatt(srcImageFolder, d, imageTimeArray, activePeriodsArray)
periodCount = size(activePeriodsArray, 1);

for curPeriod=1:periodCount

    searchStimulationBeginTimeMin = activePeriodsArray(curPeriod, 3)/60/2 - 1;
    searchStimulationEndTimeMin = activePeriodsArray(curPeriod, 3)/60/2 + 1;


    % find startImg and endImg
    startImg = -1;
    endImg = -1;
    for q=activePeriodsArray(curPeriod, 1):activePeriodsArray(curPeriod, 2)
        if ComputeTimeDiffBtwTwoDateVectorsMatt( ...
                imageTimeArray(q,:), imageTimeArray(activePeriodsArray(curPeriod, 1),:)) ...
                >= round(searchStimulationBeginTimeMin*60)
            startImg = q;
            break;
        end
    end
    if startImg == -1
        activePeriodsArray(curPeriod, 4) = 0;
        activePeriodsArray(curPeriod, 5) = 0;
        continue;
    end

    for q=startImg+1:activePeriodsArray(curPeriod, 2)
        if ComputeTimeDiffBtwTwoDateVectorsMatt( ...
                imageTimeArray(q,:), imageTimeArray(activePeriodsArray(curPeriod, 1),:)) ...
                > round(searchStimulationEndTimeMin*60)
            endImg = q;
            break;
        end
    end
    if endImg == -1
        activePeriodsArray(curPeriod, 4) = 0;
        activePeriodsArray(curPeriod, 5) = 0;
        continue;
    end



    % Detect stimulation on
    stimulationBegin = -1;
    stimulationEnd = -1;
    vibrationROI = [850, 650, 750, 550];
    for q=startImg:endImg
        %display(['Searching Stimulation-On-Time at ' d(q).name]);
        %pause(0.05);

        %display([d(q).name])
        srcImg = imread([srcImageFolder filesep d(q).name]);
        if ndims(srcImg) ==3
            srcImg = rgb2gray(srcImg);
        end
        imga = uint16(srcImg);
        avgGray=mean(mean(imga));
        if avgGray>150
            isStimulationFound = true;
        else
            isStimulationFound = false;
        end



        if isStimulationFound
            if stimulationBegin == -1
                stimulationBegin = q-1;
            end
        else
            if stimulationBegin ~= -1
                stimulationEnd = q-1+1;
                break;
            end
        end
    end




    % if no illumination found. this is for control w/o light illumination
    if stimulationBegin == -1;
        stimulationBegin = activePeriodsArray(curPeriod, 1) + ...
            round((activePeriodsArray(curPeriod, 2) - activePeriodsArray(curPeriod, 1))/2);
        stimulationEnd = stimulationBegin + 1;
        activePeriodsArray(curPeriod, 6) = 0;
    else
        activePeriodsArray(curPeriod, 6) = 1;
    end


    activePeriodsArray(curPeriod, 4) = stimulationBegin;
    activePeriodsArray(curPeriod, 5) = stimulationEnd;

    %display('One imaging period completed');
end


retActivePeriodsArray = activePeriodsArray;
end
