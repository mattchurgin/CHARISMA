function [response] = moveAbsoluteCNC(xpos, ypos, zpos)
% moves CNC to xyz position specified by inputs

global grblBoard

% clear any outstanding response messages
i=1;
while grblBoard.BytesAvailable ~= 0
    response{i}=fscanf(grblBoard);
    i=i+1;
end
clear response
fprintf(grblBoard,['X' num2str(xpos) 'Y' num2str(ypos) 'Z' num2str(zpos)])

response=fscanf(grblBoard);

end