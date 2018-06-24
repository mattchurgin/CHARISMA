%continuous_activity.m
function []=continuous_activityanalysis(d,srcDir,NoiseThres,destAnalysisFolder,analysisInterval1,analysisInterval2,spi,AutoSaveFrames)


% Main Activity Analysis

cd(srcDir)
load inits

analysisInterval1=analysisInterval1/spi;
analysisInterval2=analysisInterval2/spi;
NumStart=1;
NumEnd=length(d);
NumROI=length(ROI);

okay=1;
while okay==1
    NameA = d(NumStart).name;
    NameB = d(NumStart+analysisInterval1).name;
    ImgA=single(imread(NameA));
    ImgB=single(imread(NameB));
    ImgDif = abs(double(ImgA-ImgB))./double(ImgA+ImgB);

    figure
    imagesc(ImgDif>NoiseThres)
    colormap(gray)

    okay=input('If NoiseThres okay, enter 0, otherwise enter 1')

    if okay==1
        NoiseThres=input('Enter new NoiseThres');
    end
    close all
end



ActVal = zeros(NumROI,length(d));
ActValS = zeros(NumROI,length(d));

Error = 0;
AnalysisTPF = 'N/A';
% Create Gaussian Filter
x=-5:5;
y=x;
[xx yy]=meshgrid(x,y);
gau=exp(-sqrt(xx.^2+yy.^2));

tic;
NumA = NumStart;
ROI=round(ROI);
close all
while NumA <= NumEnd

    NameA = d(NumA).name;

    if NumA > NumStart
        if mod(NumA-NumStart-analysisInterval1,analysisInterval1)==0
            ImgB = ImgA;
        end
        if mod(NumA-NumStart-analysisInterval2,analysisInterval2)==0
            ImgC = ImgA;
        end
    end
    try
    ImgA = single(imread(NameA));
    catch
    end
    % Activity Analysis --------------------------------------
    if NumA >NumStart
        NameA
        if mod(NumA-NumStart-analysisInterval1,analysisInterval1)==0
            try
                ImgDif = abs(double(ImgA-ImgB))./double(ImgA+ImgB);

            catch
                ImgA=mean(ImgA,3);
                ImgB=mean(ImgB,3);

                ImgDif = abs(double(ImgA-ImgB))./double(ImgA+ImgB);

            end
            if mean(mean(ImgA))>220
                ActVal(:,NumA-NumStart)=10000;
            else
                for n = 1:NumROI
                    ROIDif = ImgDif(ROI(n,3):ROI(n,4),ROI(n,1):ROI(n,2));
                    ROIDifT = conv2(ROIDif,gau,'same');
                    ROIDifT = ROIDifT>NoiseThres;
                    ActVal(n,NumA-NumStart) = sum(sum(ROIDifT));
                end
            end

        end

        if mod(NumA-NumStart-analysisInterval2,analysisInterval2)==0
            try
                ImgDifSkip = abs(double(ImgA-ImgC))./double(ImgA+ImgC);

            catch
                ImgA=mean(ImgA,3);
                ImgC=mean(ImgC,3);

                ImgDifSkip = abs(double(ImgA-ImgC))./double(ImgA+ImgC);

            end

            for n = 1:NumROI
                ROIDifSkip = ImgDifSkip(ROI(n,3):ROI(n,4),ROI(n,1):ROI(n,2));
                ROIDifTSkip = conv2(ROIDifSkip,gau,'same');
                ROIDifTSkip = ROIDifTSkip>NoiseThres;
                ActValS(n,NumA-NumStart) = sum(sum(ROIDifTSkip));
            end
        end

        display(['Analysis in progress: ' num2str(NumA-NumStart) '/' num2str(NumEnd-NumStart+1) '. Images processed at ' AnalysisTPF ' sec/frame.'])

    end
    if mod(NumA,10) == 0
        AnalysisTPF = num2str(toc/10,'%0.3f');
        tic;
    end
    if mod(NumA,AutoSaveFrames) == 0
        save([destAnalysisFolder '/activity2'],'NoiseThres','ActVal','ActValS','analysisInterval1','analysisInterval2');
    end
    NumA = NumA + 1;
end
