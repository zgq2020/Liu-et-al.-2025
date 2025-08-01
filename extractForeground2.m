% Adjust the threshold based on the average brightness, rather than using a fixed threshold.
function cframe = extractForeground2(frame,arenaModel,initialMeanIntensity,mask)
% a = 0.2;
a = 0.13;
if initialMeanIntensity >= 75
    coeff = a;
elseif initialMeanIntensity >= 70
    coeff = a+0.01;
elseif initialMeanIntensity >= 65
    coeff = a+0.02;
elseif initialMeanIntensity >= 60
    coeff = a+0.03;
elseif initialMeanIntensity >= 55
    coeff = a+0.04;
elseif initialMeanIntensity >= 50
    coeff = a+0.05;
else
    coeff = a+0.06;
end

gFrame = im2gray(frame);
arenaModel(~mask) = 0;

meanIntensity = mean(gFrame(:));
Thresh = meanIntensity * coeff; % thresholds for video frames and background models

cframe = imabsdiff(arenaModel, gFrame);
cframe(cframe > Thresh) = 255;
cframe(cframe <= Thresh) = 0;

% cframe = imerode(cframe, strel('disk', 3));
cframe = imerode(cframe, strel('rectangle', [2 2]));

cframe = imfill(cframe,'holes');
% % cframe = logical(cframe);
cframe = bwareaopen(cframe, 30);
% cframe = imopen(cframe, strel('disk', 1));
cframe = logical(cframe);
end