% [startImageIndex, endImageIndex, durationSec, empty, empty, empty, empty, empty]
function retActiveImagingPeriodsArray = SearchActiveImagingPeriodsMatt(imageTimeArray, maxTimeIntervalSec, minDurationMin)
  imageCount = size(imageTimeArray, 1);
  imgPeriodsArray = zeros(1000, 8);
  imgPeriodsCount = 0;
  
  
  startImg = -1;
  for q=1:imageCount-1
      if (startImg == -1) && q ~= 1 && (ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(q+1,:), ...
                imageTimeArray(q,:)) <= maxTimeIntervalSec)
          startImg = q;
          continue;
      end
     
      if (startImg ~= -1) && ...
              ((ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(q+1,:), ...
                imageTimeArray(q,:)) > maxTimeIntervalSec) || ...
                ((ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(q+1,:), ...
                imageTimeArray(q,:)) <= maxTimeIntervalSec) && q==imageCount-1))
          endImg = q;
          
          imgPeriodsCount = imgPeriodsCount + 1;
          imgPeriodsArray(imgPeriodsCount, 1) = startImg;
          imgPeriodsArray(imgPeriodsCount, 2) = endImg;
          imgPeriodsArray(imgPeriodsCount, 3) = ComputeTimeDiffBtwTwoDateVectorsMatt(imageTimeArray(endImg,:),...
                              imageTimeArray(startImg,:));
          
          startImg = -1;
      end
      
      
  end
  
  
  imgPeriodsArray = imgPeriodsArray(1:imgPeriodsCount,:);
  
  
  %delete period if total period length is less than minDurationSec
  imgPeriodsArray(imgPeriodsArray(:,3) < minDurationMin*60, : ) = [];
 
  retActiveImagingPeriodsArray = imgPeriodsArray;
end
