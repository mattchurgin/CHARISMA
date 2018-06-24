function [] = deleteDay(myDate,myDirectory)
% deleteDay deletes image folders acquired on "myDate" for all plates
% contained within "myDirectory"
% WARNING: Be very careful with this function.  All images contained within the specified
% folder will be permanently deleted!  Only use after you are sure that all
% the images acquired on a given day are faulty (e.g. robot failed on a
% particular day).
% myDate should be specified with integers like this: [Y M D]

year=myDate(1);
month=myDate(2);
day=myDate(3);

folderToDelete=[num2str(year) '-' num2str(month) '-' num2str(day)];

currFolders=dir(myDirectory);

for i=3:length(currFolders)
    if exist([myDirectory '\' currFolders(i).name '\' folderToDelete])
        rmdir([myDirectory '\' currFolders(i).name '\' folderToDelete],'s')
        display([myDirectory '\' currFolders(i).name '\' folderToDelete ' deleted'])
    end
end