function sTracks = storeTracks(tracks,sTracks,counter,del_ids)
if counter == 1
% Initialization: If counter equals 1, it indicates that this is the first frame being processed.
% Create an empty structure array sTracks to store trajectory information.
% trackedFrames stores the number of frames.
    % create an empty array of tracks
    sTracks = struct(...
        'id', {}, ...
        'data',{},...
        'trackedFrames', 1);

else
% Processing subsequent frames: If it is not the first frame, retrieve the IDs of all trajectories in the current frame and store them in ids
    ids = vertcat(tracks.id);
    for i = 1:length(ids)
        IDpos = ids(i);
        sTracks(IDpos).id = IDpos;% Store the current trajectory IDs in the sTracks structure.

        catFrames = [sTracks(IDpos).trackedFrames;counter];
        sTracks(IDpos).trackedFrames = catFrames;

% Update the tracked frame count: Add the current frame counter counter to the trackedFrames field of the trajectory, indicating that the trajectory is tracked in the current frame.
%
% Concatenate data
% Add the current trajectory's coordinate data (tracks(i).data(1,:)) to sTracks(IDpos).data, updating the historical coordinate data of the trajectory.
% catData is the merged data, containing the previous coordinates and the coordinates of the current frame.

        catData = [sTracks(IDpos).data;tracks(i).data(1,:)];
        sTracks(IDpos).data = catData;
    end
end
%delete bad tracks/matches
% if nargin <4
%     del_ids = [];
% end
% if ~isempty(del_ids)
%     del_idx = ismember(vertcat(sTracks.id),del_ids);
%     sTracks(del_idx) = [];
% end
