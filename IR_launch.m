tic 
YourPath = 'D:\User\paper\mosquito\UV\code\Code' %% Your path
addpath(YourPath)

%% get directory of interest (add directory to video files here)
selpath = uigetdir;
cd(selpath)
dirContents = dir('**/*.*') ;
strIdx = (strfind({dirContents.name},'.'));
strIdx = cellfun(@isempty,strIdx);
dirContents = dirContents(strIdx);

%% create parameters object 
Params.FirstDir = pwd; %first directory to return to 
fullPath = {}
for i = 1:length(dirContents)
    fullPath{i,1} = strcat(dirContents(i).folder,'\',dirContents(i).name)
end
    
Params.Folders = fullPath
% get videos in each folder
allFiles = {}
for kk = 1:size(Params.Folders,1)
    cd(Params.Folders{kk})
    fileList = dir('*.mp4')'
    fileList = {fileList.name}'
    allFiles{kk,1} = fileList
    cd(Params.FirstDir)
end
Params.vidNames = allFiles;

%get IR zones for each cage 
[Params, z1, z2] = getzones(Params)
%save parameters 
saveName = 'Params';
save(saveName,"Params")

%% Run tracking program in loop (this will loop over videos in directory of interest)
for foldNumber = 1:length(Params.Folders)
    cd(Params.Folders{foldNumber})
    for vidNumber = 1:length(Params.vidNames{foldNumber})
        vidName = Params.vidNames{foldNumber}{vidNumber}
        
        %run IR tracking program
        IR_trax

        %store output data
        masterData.allTracks = sTracks
        masterData.cleanTracks = cleanTracks
        masterData.vidName = vidName
        masterData.data = data

        dataTable = table();
        cleanTracks = masterData.cleanTracks;

        TimeZ2 = sum(vertcat(cleanTracks.TimeInZ2));
        TimeZ1 = sum(vertcat(cleanTracks.TimeInZ1));

        NumberZ2 = sum(vertcat(cleanTracks.TimeInZ2)>0);
        NumberZ1 = sum(vertcat(cleanTracks.TimeInZ1)>0);

        AveDwellTimeZ2 = TimeZ2/NumberZ2;
        AveDwellTimeZ1 = TimeZ1/NumberZ1;

        CumDistZ2 = sum(vertcat(cleanTracks.DistInZ2));
        CumDistZ1 = sum(vertcat(cleanTracks.DistInZ1));

        dataTable.PI = PI;
        dataTable.NumberInZ1 = NumberZ1;
        dataTable.NumberInZ2 = NumberZ2;
        dataTable.AveDwellTimeInZone1 = AveDwellTimeZ1;
        dataTable.AveDwellTimeInZone2 = AveDwellTimeZ2;
        dataTable.CumDistZ1 = CumDistZ1;
        dataTable.CumDistZ2 = CumDistZ2;
        masterData.dataTable = dataTable;

        % save data 
        if contains(vidName, '.mp4')
            vidName = erase(vidName, '.mp4');
        end
        saveName = strcat(vidName, '.mat');
        save(saveName,"masterData")
    
    end
    cd(Params.FirstDir)
end
toc 