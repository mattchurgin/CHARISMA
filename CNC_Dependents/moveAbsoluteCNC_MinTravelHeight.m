function [response] = moveAbsoluteCNC_MinTravelHeight(xpos, ypos, zpos, travelHeight)
% moves CNC to xyz position specified by inputs with a minimum travel
% heigth of travelHeight
%
% if travelHeight is lower than the current z position, the function
% will return 0 and not execute the move

global grblBoard

[currX, currY, currZ]=getCurrentPosition();

if travelHeight<(zpos+5)
    travelHeight=zpos+5;
end
if travelHeight>currZ
    % move to travel height
    fprintf(grblBoard,['X' num2str(currX) 'Y' num2str(currY) 'Z' num2str(travelHeight)])
    
    % move to new x and y location
    
    fprintf(grblBoard,['X' num2str(xpos) 'Y' num2str(ypos) 'Z' num2str(travelHeight)])
    
    % clear any outstanding response messages
    i=1;
    while grblBoard.BytesAvailable ~= 0
        response{i}=fscanf(grblBoard);
        i=i+1;
    end
    clear response
    
    % move to final position
    fprintf(grblBoard,['X' num2str(xpos) 'Y' num2str(ypos) 'Z' num2str(zpos)])
    
    response=fscanf(grblBoard);
else 
    
    travelHeight=currZ+5; % if travelHeight is less than or equal to current z, increase travel height by 5 mm
    
     % move to travel height
    fprintf(grblBoard,['X' num2str(currX) 'Y' num2str(currY) 'Z' num2str(travelHeight)])
    
    % move to new x and y location
    
    fprintf(grblBoard,['X' num2str(xpos) 'Y' num2str(ypos) 'Z' num2str(travelHeight)])
    
    % clear any outstanding response messages
    i=1;
    while grblBoard.BytesAvailable ~= 0
        response{i}=fscanf(grblBoard);
        i=i+1;
    end
    clear response
    
    % move to final position
    fprintf(grblBoard,['X' num2str(xpos) 'Y' num2str(ypos) 'Z' num2str(zpos)])
    
    response=fscanf(grblBoard);
end