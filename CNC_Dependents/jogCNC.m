function [response] = jogCNC(dimension,distance,feedrate)
% dimension: string 'X','Y', or 'Z'
% distance numeric (in millimeters)
% feedrate numeric


global grblBoard

% clear any outstanding response messages
i=1;
while grblBoard.BytesAvailable ~= 0
    response{i}=fscanf(grblBoard);
    i=i+1;
end
clear response

fprintf(grblBoard,['$J=G21G91' dimension num2str(distance) 'F' num2str(feedrate)]);


response=fscanf(grblBoard);

end