%% Select video frames
% frame_id = randi([1, 2000], 1, 100);% 100 frames of video are selected from a specified range
frame_id = round(rand(1,100)*vid.NumFrames); 
frame_id = frame_id(frame_id>0); % 100 frames of video are randomly selected from the entire video
vid.CurrentTime = 0;

for i = 1:length(frame_id)
    get_im = rgb2gray(read(vid,frame_id(i)));
    im_rep(:,:,i) = (get_im);
    i
end

%% Generative background model
disp('Calculating Mode Background Model...')

mode_model = double(mode(im_rep,3));
std_mode = std(double(im_rep),[],3);
Thresh_img = std_mode.*3 + mode_model;
Thresh_img = uint8(Thresh_img);

disp('Background Model Complete')
    figure;
    imshow(mode_model, []);
    title('Mode model');

%% Modify background model
modify_background = input('Do you want to modify the background model? (y/n): ', 's');
% If the generated background model meets your requirements, enter 'n' to skip the step of modifying the background model. 
% Conversely, if 'y' is entered, the background model will be modified.
% Background model modification steps:
% 1. Hold down the left mouse button and drag to select the area to be modified.
% 2. When the mouse cursor is in the selected area of the box, it will become a cross. Double-click the left mouse button.
% 3. In the MATLAB command line window, enter the time point (in seconds) to replace the video, and press Enter.
% 4. MATLAB will display the modified background image. If you need to continue modifying, input 'y' and repeat steps 1-3; otherwise, input 'n' to exit the background modification.

if strcmpi(modify_background, 'y')
    disp('Entering background model modification mode...');

    while true
        disp('Please select the region to remove (drag a rectangle) and press Enter to confirm:');
        h = imrect;
        position = wait(h);

        % Gets the selected region
        x1 = round(position(1));
        y1 = round(position(2));
        x2 = round(position(1) + position(3));
        y2 = round(position(2) + position(4));

        % Select the frame you want to fill and read it directly from the video
        disp('Please enter the frame time to use for filling (s):');
        frame_to_use = input('');
        frame_to_use = frame_to_use * vid.FrameRate;
        if frame_to_use < 1 || frame_to_use > vid.NumFrames
            error('Frame number out of range.');
        end

        specific_frame = rgb2gray(read(vid, frame_to_use));

        % Get the oixel value from the selected area
        specific_region = specific_frame(y1:y2, x1:x2);

        % Smooth the selected area 
        border_padding = 1;
        smoothed_region = imgaussfilt(specific_region, 1);

        % Fill in the background model with smoothed areas
        mode_model(y1:y2, x1:x2) = smoothed_region;

        figure;
        imshow(mode_model, []);
        title('Background Model After Filling With Smoothed Region');

        continue_fill = input('Do you want to fill another region? (y/n): ', 's');
        if strcmpi(continue_fill, 'n')
            break;
        end
    end
end

disp('All filling operations completed.');

