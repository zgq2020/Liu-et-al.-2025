vid = VideoReader(vidName)
addpath(YourPath)

%% Generate mode background model
ModeBackgroundModel2

%% Modified parameters
erode = 2; % The parameters of the white-and-black model are used for erosion operations in image processing to reduce the size of detected objects.
sens = 0.48;% A sensitivity parameter of the white-and-black model is used for image segmentation to control the threshold of binarization.

%Controls the start and end times for video playback.
start_time_min = 0; % min, start time of the video
end_time_min = 2; % min, end time of the video
start_time = start_time_min * 60; % s
end_time = end_time_min * 60; % s

vid.CurrentTime = start_time;
FR = vid.FrameRate;
period = end_time - start_time; 
%% vision.BlobAnalysis 
hblob = vision.BlobAnalysis(...
    'CentroidOutputPort', true, ...
    'AreaOutputPort', true, ...%Return blob area, specified as true or false.
    'BoundingBoxOutputPort', true, ...
    'MinimumBlobAreaSource', 'Property',...
    'MajorAxisLengthOutputPort',true,...
    'MinorAxisLengthOutputPort',true,...
    'BoundingBoxOutputPort',true,...
    'EccentricityOutputPort',true,...
    'OrientationOutputPort',true,...
    'MinimumBlobArea', 40, ...% Minimum Blob Area     
    'MaximumBlobArea', 1000, ...% Maximum Blob Area
    'MaximumCount', 10000);%blob detector


    counter = 1;
    data = {};

% calculate the brightness value of the first video frame
initialFrame = readFrame(vid);
initialFrame = im2gray(initialFrame);
mask1 = poly2mask(z1(:,1), z1(:,2), size(initialFrame, 1), size(initialFrame, 2));
mask2 = poly2mask(z2(:,1), z2(:,2), size(initialFrame, 1), size(initialFrame, 2));
mask = mask1 | mask2;
initialFrame(~mask) = 0;
initialMeanIntensity = mean(initialFrame(:));

videoPlayer = vision.VideoPlayer;

% Save the visual foreground extraction video
% outputVideo = VideoWriter('foreground_extraction.mp4', 'MPEG-4'); 
% open(outputVideo);

while vid.CurrentTime <= end_time && hasFrame(vid)
    frame = (readFrame(vid));
    frame = im2gray(frame);
    mask1 = poly2mask(z1(:,1), z1(:,2), size(frame, 1), size(frame, 2));
    mask2 = poly2mask(z2(:,1), z2(:,2), size(frame, 1), size(frame, 2));
    mask = mask1 | mask2;
    frame(~mask) = 0;

%% Background model
       cframe = extractForeground2(frame,uint8(mode_model),initialMeanIntensity,mask); 

%% white-and-black model
       [BW] = segmentImage5v1(frame,erode,sens);
       se = strel('rectangle',[2 2]);
%        se = strel('disk',2);
       BW = imerode(BW, se);
       BW_inv = ~BW;

%% Combine the results of the two models
    dframe = cframe | BW_inv;
    [Areas,CTs,BB,MALs,MiALs,Orients,Ecens] = hblob(dframe);
    
%% Visualize the extracted blobs
%     for i = 1:size(Areas,1)
%         moi = dframe(BB(i,2):BB(i,2)+BB(i,4)-1,BB(i,1):BB(i,1)+BB(i,3)-1);
%         maskedImage = imcomplement(frame(BB(i,2):BB(i,2)+BB(i,4)-1,BB(i,1):BB(i,1)+BB(i,3)-1));
%         maskedImage(~moi) = 0;
%     end
%     dframe = im2uint8(dframe);
%     showIm = imshowpair(frame,dframe);
%     text(size(frame, 2) - 100, size(frame, 1) - 10, sprintf('Frame: %d', counter), ...
%     'Color', 'white', 'FontSize', 10, 'HorizontalAlignment', 'right'); % Display video frame
%     drawnow()
% %     writeVideo(outputVideo, dframe);%%
%     delete(showIm);

%% Save data
    data{counter,1} = [double(Areas),double(CTs),double(BB),double(MALs),double(MiALs),double(Orients),double(Ecens)];
        DT = data{counter,1};
    counter = counter + 1
% data is a cell array of size counter(frame number)x1, where each element contains information about a blob.
% Areas are the areas of the blobs.
% CT represents the central coordinates of the blobs (x and y).
% BB is the bounding box of a blob, usually a rectangle, containing x, y, width, and height.
% MALs and MiALs are the maximum and minimum axis lengths of the blobs, respectively.
% Orients is the orientation of the blobs, that is, the angle of the long axis relative to the horizontal line.
% Ecens represents the eccentricity of each blob, indicating how elliptical the shape is.

end
% close(outputVideo);

%% Calculate the preference index（PI）
totalInZ1 = 0;
totalInZ2 = 0;
PISum = 0;
frameCount = 0;

for i = 1:size(data, 1)
    currentData = data{i, 1};

    inZ1 = inpolygon(currentData(:, 2), currentData(:, 3), z1(:, 1), z1(:, 2));
    inZ2 = inpolygon(currentData(:, 2), currentData(:, 3), z2(:, 1), z2(:, 2));
    
    totalInZ1 = totalInZ1 + sum(inZ1);
    totalInZ2 = totalInZ2 + sum(inZ2);
    
    if (sum(inZ1) + sum(inZ2)) > 0
        PIPerFrame = (sum(inZ2) - sum(inZ1)) / (sum(inZ1) + sum(inZ2));
        PISum = PISum + PIPerFrame;
        frameCount = frameCount + 1;
    else
        fprintf('Frame %d: No blobs in Z1 or Z2\n', i);
    end
end

if frameCount > 0
    PI = PISum / frameCount;
    fprintf('PI = %.2f\n', PI);
else
    fprintf('No valid frames with blobs in Z1 or Z2\n');
end

%% Detect moving objects, and track them across video frames
counter = 1; 
[tracks] = creatFirstTrack2(data) 
[sTracks] = storeTracks(tracks,nan,counter) 
nextId = size(tracks,1)+1
GO = 1

while GO == 1 && counter< size(data,1)

    DT = data{counter,1};
    
    [tracks] = predictLocation2(tracks,sTracks); 
    
    [assignments,unassignedTracks,unassignedDetections] = ...
    assignDetection2(tracks,DT);

    %update assigned tracks 
    [tracks] = updateAssignment2(tracks,assignments,DT);
    
    %update unassigned tracks
    [tracks,del_ids] = confusingtracks(tracks,unassignedTracks);

    %create new tracks
    [tracks,nextId] = newTracks2(tracks,unassignedDetections,DT,nextId);   
    [sTracks] = storeTracks(tracks,sTracks,counter,del_ids);

    counter = counter + 1
    
end

%clean up sTracks data 
minVisibleFrames = 10
[cleanTracks] = cleanSTracks2(sTracks,minVisibleFrames);

%% Calculate the time and distance
z1 = Params.Zones{foldNumber}(:,1:2)
z2 = Params.Zones{foldNumber}(:,3:4)

TimeInZ1 = [];
TimeInZ2 = [];
DistInZ1 = [];
DistInZ2 = [];

for i = 1:max(vertcat(cleanTracks.id))
    
    currTrack = cleanTracks(i).data;

    [in_Z1] = inpolygon(currTrack(:,2),currTrack(:,3),z1(:,1),z1(:,2));
    [in_Z2] = inpolygon(currTrack(:,2),currTrack(:,3),z2(:,1),z2(:,2));

    %Time in Zones 
    TimeInZ1(i,1) = sum(in_Z1)/vid.FrameRate;
    TimeInZ2(i,1) = sum(in_Z2)/vid.FrameRate;

    % Distance in Zones1
    distX_Z1 = diff(currTrack(in_Z1, 2)); % Calculate the x-coordinate difference
    distY_Z1 = diff(currTrack(in_Z1, 3)); % Calculate the y-coordinate difference

    totalDistZ1 = 0; 

    % Traverse the coordinate differences between adjacent frames
    for j = 1:length(distX_Z1)
        if abs(distX_Z1(j)) < 2 && abs(distY_Z1(j)) < 2
            % Assign 0 if the coordinate difference is less than 2
            totalDistZ1 = totalDistZ1 + 0; 
        else
            % Otherwise, calculate the Euclidean distance
            totalDistZ1 = totalDistZ1 + sqrt(distX_Z1(j)^2 + distY_Z1(j)^2);
        end
    end

    DistInZ1(i,1) = totalDistZ1; 

    % Distance in Zones1
    distX_Z2 = diff(currTrack(in_Z2, 2)); 
    distY_Z2 = diff(currTrack(in_Z2, 3)); 
   
    totalDistZ2 = 0; 

    for j = 1:length(distX_Z2)
        if abs(distX_Z2(j)) < 2 && abs(distY_Z2(j)) < 2
            totalDistZ2 = totalDistZ2 + 0; 
        else
            totalDistZ2 = totalDistZ2 + sqrt(distX_Z2(j)^2 + distY_Z2(j)^2);
        end
    end

    DistInZ2(i,1) = totalDistZ2; 
end

%store output 
for i = 1:size(TimeInZ1,1)
    cleanTracks(i).TimeInZ1 = TimeInZ1(i);
    cleanTracks(i).TimeInZ2 = TimeInZ2(i);
    cleanTracks(i).DistInZ1 = DistInZ1(i);
    cleanTracks(i).DistInZ2 = DistInZ2(i);
end