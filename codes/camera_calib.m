clear
clc
% Specify the number of total images of checker board pattern captured by 
% the camera that are to be used to calibrate the camera
numImages = 10;
% Specify the path './3rd/calib/image1.jpg'
% as fullfile('3rd','calib', sprintf('image%d.jpg', i))
files = cell(1, numImages);
for i = 1:numImages
    files{i} = fullfile('3rd','calib', sprintf('image%d.jpg', i));
end

% Display one of the calibration images
magnification = 25;
I = imread(files{1});

% Detect the checkerboard corners in the images.
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
% Specify the square sizes in millimeters
squareSize = 25; 
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
imageSize = [size(I, 1), size(I, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints,'ImageSize', imageSize);

disp('Focal Length');
disp(cameraParams.FocalLength(1));

%Evaluate calibration accuracy.
figure; showReprojectionErrors(cameraParams);
title('Reprojection Errors');