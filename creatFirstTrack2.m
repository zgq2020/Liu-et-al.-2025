%% Create tracks object :)
function [tracks] = creatFirstTrack2(data)

% Input data and output a structure array tracks, with the purpose of creating a trajectory object to store tracking information.
tracks = struct(...
    'id', {}, ...
    'data', {}, ...
    'totalVisibleCount', {}, ...% Used to record the number of frames each track is visible in the video
    'consecutiveInvisibleCount', {},...% Used to record the number of consecutive invisible frames for each track
    'predictedCentroid',{},...% Used to store the predicted centroid positions of each track
    'age',{});% Used to record the number of frames for each track
% If the number of blobs in the first frame of the video is 7, then create tracks for the first frame of the video, assigning each blob an ID, initializing totalVisibleCount to 1, and initializing consecutiveInvisibleCount and age to 0.
ids = 1:size(data{1,1})
% data{1,1} refers to the blob data of the first frame, with ids = 1 2 3 4 5 6 7 
% length(ids)=7 
% Assign the values 1 to 7 to track.id

for i = 1:length(ids)
    tracks(i,1).id = ids(1,i);
end

%data
for i = 1:length(ids)
    tracks(i,1).data = data{1,1}(i,:);
end

%visibility count
for i = 1:length(ids)
     tracks(i,1).totalVisibleCount = 1;
end
%invisible count 
for i = 1:length(ids)
    tracks(i,1).consecutiveInvisibleCount = 0;
end
%age count 
for i = 1:length(ids)
    tracks(i,1).age = 0;
end