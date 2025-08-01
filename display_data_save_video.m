saveVideo = true;  % or false

% display data 
maxT = max(vertcat(cleanTracks.trackedFrames));
% create empty data container
dispData = cell(1, max(vertcat(cleanTracks.id)));
for i = 1:length(dispData) 
    dispData{1,i} = nan(maxT, 11);
end

for i = 1:length(dispData)
    trackedFrames = cleanTracks(i).trackedFrames;
    dispData{1,i}(trackedFrames,:) = cleanTracks(i).data;
end

% Initialize video
vid.CurrentTime = 0;
videoPlayer = vision.VideoPlayer;

% Create a VideoWriter object to save the video if required
if saveVideo
    saveDir = 'Your save video path';  % Your save video path
    if contains(vidName, '.mp4')
        vidName = erase(vidName, '.mp4');
    end
    outputFileName = fullfile(saveDir, [vidName, '_analyzed.mp4']); 

    outputVideo = VideoWriter(outputFileName, 'MPEG-4');
    outputVideo.FrameRate = vid.FrameRate; 
    open(outputVideo);  
end

% display loop
for i = 1:maxT
    frame = readFrame(vid);
    
    % XYs extraction
    XYs = [];
    for ii = 1:length(dispData)
        XYs = [XYs; dispData{1,ii}(i,2:3)];
    end
    XYs(:,3) = (1:size(XYs,1))';
    
    % Remove NaN rows
    XYs = XYs(all(~isnan(XYs(:,1)),2),:);
    
    % Fixed radius value for circles
    fixedRadius = 10;
    XYsWithFixedRadius = [XYs(:,1:2), repmat(fixedRadius, size(XYs, 1), 1)];
    
    if isempty(XYs)
        sFrame = frame;
    else
        sFrame = insertShape(frame, 'FilledCircle', XYsWithFixedRadius, 'Color', 'm', 'Opacity', 0.2);
        sFrame = insertText(sFrame, XYs(:,1:2), cellstr(num2str(XYs(:,3))), 'FontSize', 20, 'BoxOpacity', 0);
    end

    % Display frame in video player
    videoPlayer(sFrame);
    
    % Write frame to output video if saving
    if saveVideo
        writeVideo(outputVideo, sFrame);
    end
    
    pause(1/30);  % Control playback speed
end

if saveVideo
    close(outputVideo);
end
