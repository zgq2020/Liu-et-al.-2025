%% Update Unassigned Tracks
%The core of this code lies in reasonably matching detection with trajectories through distance and speed conditions to achieve efficient target tracking.
function [tracks,del_ids] = confusingtracks(tracks,unassignedTracks)

for i = 1:length(unassignedTracks)
    
    ind = unassignedTracks(i);
    tracks(ind).consecutiveInvisibleCount = ...
    tracks(ind).consecutiveInvisibleCount + 1;
    tracks(ind).data  = nan(1,11);

end
% consecutiveInvisibleCount is used to track the number of consecutive invisible frames for each mosquito. 
% It is initialized to 0 in creatFirstTracks2.m. 
% The variable ind is an index variable that refers to the index of the current trajectory that has not been assigned to a detection. 
% By using tracks(ind).consecutiveInvisibleCount, the code increments the consecutive invisible count for that trajectory. 
% This means that the trajectory was not detected in the current frame, thus increasing its invisible count.
% del_idx = vertcat(tracks.consecutiveInvisibleCount) > 10; % Here, 10 is the threshold, meaning that trajectories with more than 10 consecutive invisible frames are deleted.
% In the updateAssignment2 function, when a trajectory is successfully matched to a detection, consecutiveInvisibleCount is reset to 0

%delete invisible tracks 
del_idx = vertcat(tracks.consecutiveInvisibleCount)>10;

%delete short lived tracks 
inVisi = vertcat(tracks.consecutiveInvisibleCount);
visi = vertcat(tracks.totalVisibleCount);
% 
del_idx_1 = visi==1&inVisi==1;
% tracks(del_idx) = [];
% 
% del_idx = (inVisi./visi)>0.6;
% tracks(del_idx) = [];

del_idx = logical(del_idx_1 + del_idx);
if sum(del_idx)>0
    del_ids = tracks(del_idx).id;
else
    del_ids = [];
end
tracks(del_idx) = [];
end
