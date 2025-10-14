% The core of this code lies in reasonably matching detections with trajectories through distance and speed conditions to achieve efficient target tracking. 
% During the implementation process, the construction and filtering of the cost matrix are key, ensuring that only matches that meet the criteria are accepted.
%% Assign Detections to Tracks
function [assignments,unassignedTracks,unassignedDetections] = ...
    assignDetection2(tracks,DT)

% assign detections 
    nTracks = length(tracks); %calculate the number of track
    nDetections = size(DT,1); %calculate the number of blobs in each frame.

% Compute the cost of assigning each detection to each track.
%               *this cost function will probably need to be modified*

cost = zeros(nDetections,nTracks); %rows are detections; columns are tracks
%
for i = 1:nTracks
QueryPoints = tracks(i).predictedCentroid(1,2:3);
[~,dist] = knnsearch(QueryPoints,DT(:,2:3));
cost(:,i) = dist;
end

if sum(isnan(cost),'all')>0
    cols 
end
speedThresh = 200;%
keeper_idx = cost < speedThresh;
% keeper_idx = true(nDetections, nTracks);
% assign detections 
    %loop to find min value if >1 detection survives
    assIdx = find(any(keeper_idx,1));
    for i = 1:length(assIdx)
        keeper_idx(:,assIdx(i))  = cost(:,assIdx(i))==min(cost(:,assIdx(i)));
    end
    
    %loop to find min value if >1 detection matches to track
    assIdx = find(any(keeper_idx,2));
    for i = 1:length(assIdx)
        keeper_idx(assIdx(i),:)  = cost(assIdx(i),:)==min(cost(assIdx(i),:));
    end

[assignmentsX,assignmentsY] = find(keeper_idx>0);
assignments = [assignmentsX,assignmentsY];

%find unassigned tracks 
unassignedTracks = find(~any(keeper_idx,1));

%find unassigned detections 
unassignedDetections = find(~any(keeper_idx,2));
end

