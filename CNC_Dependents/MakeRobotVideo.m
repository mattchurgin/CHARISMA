% make video
clear all
close all

savefoldername='movie';
if exist(savefoldername)~=7
   mkdir(savefoldername) 
end
currd=pwd;
currf=dir(currd);
roix=(925:1325)-20;
roiy=(1350:1750)+10;
z=1;
for i=3:(length(currf)-1)
    
    
   a=(imread(currf(i).name)); 
   acrop=a(roix,roiy);
   
   imagesc(acrop,[50 140])
   %imagesc(a,[60 150])
   axis square
   colormap(gray)
   set(gca,'XTick',[])
   set(gca,'YTick',[])
   text(0,-10,['Time: ' num2str((z-32)*5,'%02d') ' seconds'],'Fontsize',15)
  
   saveas(gcf,[savefoldername '\Cropped_' num2str(z,'%04d') '.jpg'])
   %imwrite(acrop,[ savefoldername '\Cropped_' num2str(z,'%04d') '.png'],'png')
   z=z+1;
end