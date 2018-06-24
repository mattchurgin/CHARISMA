function [maskSorted centers] = AutomaticallyFind_24WellPlateROIs(imageName)
%  Find circular regions of interest for 24-well plate
% Automatically find 24 circular ROIs for 24-well plate experiment
% Returns a mask image for each ROI, sorted from 1:24
% If 24 ROIs cannot be found in a reasonable time, the function returns
% zero, indicating the code failed.
% imageName is the path of the image to load to create ROI mask from
% Written by Matt Churgin, last edited 3/12/18

im=double(imread(imageName));
sizey=size(im,1);
sizex=size(im,2);

expectedRadius=[200 300];
sensit=0.97;
[centers radii]=imfindcircles(im,expectedRadius,'Sensitivity',sensit,'ObjectPolarity','dark');
display(['# centers = ' num2str(length(centers))])
tic
if length(radii)>24
    startedTooHigh=1;
elseif length(radii)<24
    startedTooHigh=0;
end
while length(radii)~=24
    if length(radii)>24
        if startedTooHigh==1
            sensit=sensit-0.0025;
        else
            sensit=sensit-0.0005;
        end
    elseif length(radii)<24
        if startedTooHigh==0
            sensit=sensit+0.0025;
        else
            sensit=sensit+0.0005;
        end
    end
    
    [centers radii]=imfindcircles(im,expectedRadius,'Sensitivity',sensit,'ObjectPolarity','dark');
    
    % loop time out if time exceeds time-out threshold
    currT=toc;
    if currT > 25
        clear centers radii
        centers=0;
        radii=0;
        break
    end
    display(['# centers = ' num2str(length(centers))])
end

try
    if radii~=0
        % create mask
        [xx yy]=meshgrid(1:sizex,1:sizey);
        
        mask=zeros(sizey,sizex,24);
        for j=1:24
            mask(:,:,j)= ((xx-centers(j,1)).^2 + (yy-centers(j,2)).^2) < (0.7*radii(j))^2; % use percentage of radius to cut off outer ring of well which can be highly scattering
        end
        
        centersN(:,1)=centers(:,1)/min(centers(:,1));
        centersN(:,2)=centers(:,2)/min(centers(:,2));
        
        [in in2]=sort(centersN(:,1));
        [in3 in4]=sort(centersN(:,2));
        in=round(6*in/max(in));
        in3=round(4*in3/max(in3));
        
        reorder=zeros(1,24);
        for row=1:4
            currwells=in4(find(in3==row));
            for col=1:6
                colno(col)=find(in2==currwells(col));
            end
            reorder((row-1)*6+[1:6])=in2(sort(colno));
        end
        
        maskSorted=logical(mask(:,:,reorder));
        centers=centers(reorder,:);
    else
        clear maskSorted
        maskSorted=0;
        centers=0;
    end
catch
    clear maskSorted
    maskSorted=0;
    centers=0;
end
end