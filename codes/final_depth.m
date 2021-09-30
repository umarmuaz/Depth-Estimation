clc
clear

% Specify the focal length in pixels
% the focal length can be found out using the script camera calib.m
focal_length=10;
% Specify the baseline distance between the cameras in milimeters (mm)
baseline=15;

% Initial value of disparity Range
dr=16;

    
%Specify the path of images
    img1=sprintf('.\\disp\\Aloe\\view1.png');
    imgr=sprintf('.\\disp\\Aloe\\view5.png');
% Read images and Covert them from RGB to gray
    I1=rgb2gray(imread(img1));
    I2=rgb2gray(imread(imgr));
    
% Detect Surf features, extract those features and match the features in
% both stero images
% After matching the features find out the maximum value of disparity in
% the detected features
% Specify the disparity Range according to the maximum disparity value
    points1 = detectSURFFeatures(I1);
    points2 = detectSURFFeatures(I2);

    [f1,vpts1] = extractFeatures(I1,points1);
    [f2,vpts2] = extractFeatures(I2,points2);

    indexPairs = matchFeatures(f1,f2,'Unique',true,'MaxRatio',0.31) ;


    dr=vpts1(indexPairs(:,1)).Location - vpts2(indexPairs(:,2)).Location;
    dr=ceil(max(dr(:,1)));
% Disparity range = [min_disparity max_disparity]
% The difference between the min and max disparity is multiple of 16
    if mod(dr,16)~=0
        dr=dr+16-mod(dr,16);
    end
    
        disparityRange = [0 dr];
%Semi Global matching for disparity calculation
     dm = disparity(I1,I2,'BlockSize',5,'DisparityRange',disparityRange);
% For block matching it is needed to specify the method as BlockMatching
% dm = disparity(I1,I2,'Method','BlockMatching','BlockSize',5,'DisparityRange',disparityRange);

%Remove all infinite values
    dm(dm<0) = 0;
    
 % Apply median Filter  
    dm=medfilt2(dm,[5 5]);
% Append some value to avoid infinite depth values
    dm=dm+0.1;
  
 % Find out the depth value by the formula
    depth1=(focal_length * baseline)./dm;
% Background value is the mode value
% So specify the maximum depths as background value to reduce the error in
% the depth values because with increase in distance from camera error also
% increases
    y = mode(depth1(depth1<mode(depth1,'all')),'all');
    depth1(depth1==max(max(depth1)))=y;
% Display the depth Map with the range of Distances as smallest and largest
% distance
    imtool(depth1,[min(min(depth1)),mode(depth1,'all')+1]);
    