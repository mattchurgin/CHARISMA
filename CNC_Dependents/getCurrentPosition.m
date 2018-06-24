function [x, y, z] = getCurrentPosition()
% Returns current x y z coordinates from grbl

global grblBoard

i=1;
while grblBoard.BytesAvailable ~= 0
    response{i}=fscanf(grblBoard);
    i=i+1;
end

fprintf(grblBoard,'?')
r=fscanf(grblBoard);

colonLoc=find(r==':');
commaLoc=find(r==',');
vertLoc=find(r=='|');
x=str2double(r((colonLoc(1)+1):(commaLoc(1)-1)));
y=str2double(r((commaLoc(1)+1):(commaLoc(2)-1)));
z=str2double(r((commaLoc(2)+1):(vertLoc(2)-1)));

end