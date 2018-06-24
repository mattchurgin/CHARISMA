function maskSorted=ROIDefineManual()
% Define ROI with user Input
% This allows a user to manually define ROI in a rectangular grid

% A user can choose image file
[nameex,pathname] = uigetfile( ...
    {'*.bmp;*.jpg;*.JPG;*.PNG','Image Files(*.bmp,*.jpg,*.JPG,*.PNG)';'*.bmp','BMP files(*.bmp)';'*.jpg','JPG files(*.jpg, *.JPG)';...
    '*.*','All Files(*.*)'});
if length(nameex) == 13   %the case for 4 digits
    numex = str2num(nameex(6:9));
elseif length(nameex) == 14 %the case for 5 digits
    numex = str2num(nameex(6:10));
elseif length(nameex) == 15 %the case for 6 digits
    numex = str2num(nameex(6:11));
end



% ROI Selection
close all;
imga = imread([pathname nameex]);
imgex=imga;
[ysize xsize] = size(imgex);

nder = 1;
convnum = 10;
Percent = 85;
ROIshrink = 10;

if exist([pathname filesep 'inits.mat'], 'file')
    load([pathname filesep 'inits.mat']);
    existcrop = 1;
else
    existcrop = 0;
    typeplate = '1';
end 


fields={'Type of Plate? (1 = 24 (6x4); 2 = 48 (8x6); 3 = 240 (20x12), 4 = 6 (2x3), 5 = 50 (10x5), 6 = 1','Use Existing crops?','Selection Method (3=web)'};
answer = inputdlg(fields,'ROI Auto-Selection',1,{num2str(typeplate), num2str(existcrop),'3'});
existcrop = str2num(answer{2});
if existcrop == 0
    typeplate = str2num(answer{1});
    typeselection = str2num(answer{3});
end

switch typeplate
    case 1
        numrow = 4;
        numcol = 6;
    case 2
        numrow = 6;
        numcol = 8;
    case 3
        numrow=12;
        numcol=20;
    case 4
        numrow=2;
        numcol=3;
    case 5
        numrow=5;
        numcol=10;
    case 6
        numrow=1;
        numcol=1;        
end


figure(1);
imagesc(imgex);colormap gray
hold on;
set(gcf, 'Position',[100 100 1100 860]);

if existcrop == 0
    switch typeselection
        case 3
            n = 1;
            ROItext = text(xsize/2,30, 'Click at the Center of Upper-Left Well' , ...
                'Color', 'white','fontsize',16,'HorizontalAlignment','Center');
            [ULx(n), ULy(n)] = ginput(n);
            ULx(n) = floor(ULx(n));
            ULy(n) = floor(ULy(n));
            set(ROItext,'String','Click at the Center of Upper-Right Well')
            [URx(n), URy(n)] = ginput(n);
            URx(n) = floor(URx(n));
            URy(n) = floor(URy(n));
            set(ROItext,'String','Click at the Center of Lower-Left Well')
            [LLx(n), LLy(n)] = ginput(n);
            LLx(n) = floor(LLx(n));
            LLy(n) = floor(LLy(n));
            set(ROItext,'String','Click at the Center of Lower-Right Well')
            [LRx(n), LRy(n)] = ginput(n);
            LRx(n) = floor(LRx(n));
            LRy(n) = floor(LRy(n));

            ROInum = 0;
            ROIcenter = zeros(numrow*numcol,2);

            Lx = ULx + (LLx-ULx)/(numrow-1)*(0:(numrow-1));
            Ly = ULy + (LLy-ULy)/(numrow-1)*(0:(numrow-1));
            Rx = URx + (LRx-URx)/(numrow-1)*(0:(numrow-1));
            Ry = URy + (LRy-URy)/(numrow-1)*(0:(numrow-1));

            for r = 1:numrow
                for c = 1:numcol
                    ROInum = ROInum + 1;
                    ROIcenter(ROInum,:) = [Lx(r)+(Rx(r)-Lx(r))/(numcol-1)*(c-1) Ly(r)+(Ry(r)-Ly(r))/(numcol-1)*(c-1)];
                end
            end

            for n = 1:ROInum
                plot(ROIcenter(n,1),ROIcenter(n,2),'*r')
            end

            plot(ULx,ULy,'*m')
            plot(URx,URy,'*m')
            plot(LLx,LLy,'*m')
            plot(LRx,LRy,'*m')

            set(ROItext,'String','Click at the Upper-Left Corner of A Representative Well')
            [ROIx1, ROIy1] = ginput(1);

            set(ROItext,'String','Click at the Lower-Right of the Same Well')
            [ROIx2, ROIy2] = ginput(1);

            ROIxsize = ROIx2-ROIx1;
            ROIysize = ROIy2-ROIy1;
            ROIxdist = round(ROIxsize/2);
            ROIydist = round(ROIysize/2);
            ROI = zeros(ROInum,4);
            for n = 1:ROInum
                ROI(n,1:4) = [ROIcenter(n,1)-ROIxdist ROIcenter(n,1)+ROIxdist ...
                    ROIcenter(n,2)-ROIydist ROIcenter(n,2)+ROIydist];
            end
            for r = 1:length(ROI(:,1))
                ROILine(r) = plot([ROI(r,1) ROI(r,2) ROI(r,2) ROI(r,1) ROI(r,1)], ...
                    [ROI(r,3) ROI(r,3) ROI(r,4) ROI(r,4) ROI(r,3)],'Color','red','LineWidth',1);
                ROILabel(r) = text(ROI(r,1)+10,ROI(r,3)+20,num2str(r),'Color','white','FontSize',10);
            end

            IndexUR = numcol;
            IndexLL = (numrow-1)*numcol + 1;
            for n = [1 IndexUR IndexLL length(ROI(:,1))]
                fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
                fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
                fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
                fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
            end

            text(ROIcenter(1,1),ROIcenter(1,2),'X+','color','blue','fontsize',14,'HorizontalAlignment','center')
            text(ROIcenter(IndexUR,1),ROIcenter(IndexUR,2),'X-','color','blue','fontsize',14,'HorizontalAlignment','center')
            text(ROIcenter(IndexLL,1),ROIcenter(IndexLL,2),'Y+','color','blue','fontsize',14,'HorizontalAlignment','center')
            text(ROIcenter(end,1),ROIcenter(end,2),'Y-','color','blue','fontsize',14,'HorizontalAlignment','center')

            cont = 1;
            while cont == 1
                set(ROItext,'String','Click at Adjustment Options, or click elsewhere to end ROI adjustment')
                [adjx, adjy] = ginput(1);
                if adjx > ROI(1,1) && adjx < ROI(1,2) && adjy > ROI(1,3) && adjy < ROI(1,4)
                    ROIxdist = ROIxdist+1;
                elseif adjx > ROI(IndexUR,1) && adjx < ROI(IndexUR,2) && adjy > ROI(IndexUR,3) && adjy < ROI(IndexUR,4)
                    ROIxdist = ROIxdist-1;
                elseif adjx > ROI(IndexLL,1) && adjx < ROI(IndexLL,2) && adjy > ROI(IndexLL,3) && adjy < ROI(IndexLL,4)
                    ROIydist = ROIydist+1;
                elseif adjx > ROI(end,1) && adjx < ROI(end,2) && adjy > ROI(end,3) && adjy < ROI(end,4)
                    ROIydist = ROIydist-1;
                else
                    cont = 0;
                end
                % Adjust new lines
                for n = 1:ROInum
                    ROI(n,1:4) = [ROIcenter(n,1)-ROIxdist ROIcenter(n,1)+ROIxdist ...
                        ROIcenter(n,2)-ROIydist ROIcenter(n,2)+ROIydist];
                end
                for r = 1:length(ROI(:,1))
                    set(ROILine(r),'XData',[ROI(r,1) ROI(r,2) ROI(r,2) ROI(r,1) ROI(r,1)],'YData', ...
                        [ROI(r,3) ROI(r,3) ROI(r,4) ROI(r,4) ROI(r,3)]);
                    set(ROILabel(r),'Position',[ROI(r,1)+10,ROI(r,3)+20,0]);
                end
            end
    end
else
    ROItext = text(xsize/2,30, '' , ...
        'Color', 'white','fontsize',16,'HorizontalAlignment','Center');
    for r = 1:length(ROI(:,1))
        ROILine(r) = plot([ROI(r,1) ROI(r,2) ROI(r,2) ROI(r,1) ROI(r,1)], ...
            [ROI(r,3) ROI(r,3) ROI(r,4) ROI(r,4) ROI(r,3)],'Color','red','LineWidth',1);
        ROILabel(r) = text(ROI(r,1)+10,ROI(r,3)+20,num2str(r),'Color','white','FontSize',10);
    end

    if typeselection == 3

        for n = 1:ROInum
            plot(ROIcenter(n,1),ROIcenter(n,2),'*r')
        end

        IndexUR = numcol;
        IndexLL = (numrow-1)*numcol + 1;
        for n = [1 IndexUR IndexLL length(ROI(:,1))]
            fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
            fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
            fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
            fill([ROI(n,1),ROI(n,2),ROI(n,2),ROI(n,1)],[ROI(n,3) ROI(n,3) ROI(n,4) ROI(n,4)],[1 1 1])
        end

        text(ROIcenter(1,1),ROIcenter(1,2),'X+','color','blue','fontsize',14,'HorizontalAlignment','center')
        text(ROIcenter(IndexUR,1),ROIcenter(IndexUR,2),'X-','color','blue','fontsize',14,'HorizontalAlignment','center')
        text(ROIcenter(IndexLL,1),ROIcenter(IndexLL,2),'Y+','color','blue','fontsize',14,'HorizontalAlignment','center')
        text(ROIcenter(end,1),ROIcenter(end,2),'Y-','color','blue','fontsize',14,'HorizontalAlignment','center')

        cont = 1;
        while cont == 1
            set(ROItext,'String','Click at Adjustment Options, or click elsewhere to end ROI adjustment')
            [adjx, adjy] = ginput(1);
            if adjx > ROI(1,1) && adjx < ROI(1,2) && adjy > ROI(1,3) * adjy < ROI(1,4)
                ROIxdist = ROIxdist+1;
            elseif adjx > ROI(IndexUR,1) && adjx < ROI(IndexUR,2) && adjy > ROI(IndexUR,3) * adjy < ROI(IndexUR,4)
                ROIxdist = ROIxdist-1;
            elseif adjx > ROI(IndexLL,1) && adjx < ROI(IndexLL,2) && adjy > ROI(IndexLL,3) * adjy < ROI(IndexLL,4)
                ROIxdist = ROIydist+1;
            elseif adjx > ROI(end,1) && adjx < ROI(end,2) && adjy > ROI(end,3) * adjy < ROI(end,4)
                ROIxdist = ROIydist-11;
            else
                cont = 0;
            end
            % Adjust new lines
            for n = 1:ROInum
                ROI(n,1:4) = [ROIcenter(n,1)-ROIxdist ROIcenter(n,1)+ROIxdist ...
                    ROIcenter(n,2)-ROIydist ROIcenter(n,2)+ROIydist];
            end
            for r = 1:length(ROI(:,1))
                set(ROILine(r),'XData',[ROI(r,1) ROI(r,2) ROI(r,2) ROI(r,1) ROI(r,1)],'YData', ...
                    [ROI(r,3) ROI(r,3) ROI(r,4) ROI(r,4) ROI(r,3)]);
                set(ROILabel(r),'Position',[ROI(r,1)+10,ROI(r,3)+20,0]);
            end
        end
    end
end

% ensure ROI doesn't exceed image boundary
for j=1:size(ROI,1)
    if ROI(j,1)<1
        ROI(j,1)=1;
    end
    if ROI(j,3)<1
        ROI(j,3)=1;
    end
    if ROI(j,2)>size(imgex,2)
        ROI(j,2)=size(imgex,2);
    end
    if ROI(j,4)>size(imgex,1)
        ROI(j,4)=size(imgex,1);
    end
end

% make binary ROI mask
maskSorted=zeros(size(imgex,1),size(imgex,2),size(ROI,1));
for j=1:size(ROI,1)
   maskSorted(ROI(j,3):ROI(j,4),ROI(j,1):ROI(j,2),j)=1;
end

pause(1)
close all
