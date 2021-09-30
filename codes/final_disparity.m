clc
clear
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
% Disparity range = [min_disparity max_disparity]
% The difference between the min and max disparity is multiple of 16
    dr=ceil(max(dr(:,1)));
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
    
% Display the disparity Map
   imshow(dm,[min(min(dm)),max(max(dm))]);
    