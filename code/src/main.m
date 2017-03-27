clc
clear
close all

%% read calibration parameters P1 and P2 
calibname = '../data/calib.txt';
T = readtable(calibname, 'Delimiter', 'space', 'ReadRowNames', true, 'ReadVariableNames', false);
A = table2array(T);
 
P1 = vertcat(A(1,1:4), A(1,5:8), A(1,9:12));
P2 = vertcat(A(2,1:4), A(2,5:8), A(2,9:12));

%A1=[7.215377e+02 0.000000e+00 6.095593e+02 0.000000e+00 0.000000e+00 7.215377e+02 1.728540e+02 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];
%A2=[7.215377e+02 0.000000e+00 6.095593e+02 -3.875744e+02 0.000000e+00 7.215377e+02 1.728540e+02 0.000000e+00 0.000000e+00 0.000000e+00 1.000000e+00 0.000000e+00];
%P1=vertcat(A(1,1:4), A(1,5:8), A(1,9:12));
%P2=vertcat(A(2,1:4), A(2,5:8), A(2,9:12));

%% Initialize variables
pos=[0;0;0];
Rpos=eye(3);

path1='../data/DataSet1/image_00/data/0000000';
path2='../data/DataSet1/image_01/data/0000000';

%% read images
 
i=0;
dig1=imval2str(i);
dig2=imval2str(i+1);

I1_l = imread(strcat(path1,dig1,'.png'));
I1_r = imread(strcat(path2,dig1,'.png'));
I2_l = imread(strcat(path1,dig2,'.png'));
I2_r = imread(strcat(path2,dig2,'.png'));


%% feature points extraction- preprocessing stage
% In the original paper filter masks followed by Non- Maximal Suppresion is
% used to detect the features. However, since the FAST algorithm works well
% for feature detection we have used its MATLAB implementation directly.

pts1_l=detectFASTFeatures(I1_l);
pts1_r=detectFASTFeatures(I1_r);
pts2_l=detectFASTFeatures(I2_l);
pts2_r=detectFASTFeatures(I2_r);

[features1_l,valid_points1_l] = extractFeatures(I1_l,pts1_l);
[features1_r,valid_points1_r] = extractFeatures(I1_r,pts1_r);
[features2_l,valid_points2_l] = extractFeatures(I2_l,pts2_l);
[features2_r,valid_points2_r] = extractFeatures(I2_r,pts2_r);

%% Circular matching
% compare left frame at t+1 with left frame at t
inPair = matchFeatures(features2_l,features1_l,'Metric','SAD');
matchedPoints = valid_points1_l(inPair(:,2),:);

[features2_l,valid_points2_l] = extractFeatures(I2_l,valid_points2_l(inPair(:,1),:));
[features1_l,valid_points1_l] = extractFeatures(I1_l,matchedPoints);

% compare left frame at t with right frame at t
inPair = matchFeatures(features1_l,features1_r,'Metric','SAD');
matchedPoints = valid_points1_r(inPair(:,2),:);

[features1_r,valid_points1_r] = extractFeatures(I1_r,matchedPoints);

% compare right frame at t with right frame at t+1
inPair = matchFeatures(features1_r,features2_r,'Metric','SAD');
matchedPoints = valid_points2_r(inPair(:,2),:);

[features2_r,valid_points2_r] = extractFeatures(I2_r,matchedPoints);

% compare right frame at t+1 with left frame at t+1
inPair = matchFeatures(features2_r,features2_l,'Metric','SAD');
matchedPoints = valid_points2_l(inPair(:,2),:);

[features2_l,valid_points2_l] = extractFeatures(I2_l,matchedPoints);

%% Plot the odometry transformed data
%pos = pos + Rpos*t;
%Rpos = R*Rpos;
%plot(pos(1),pos(2),'ob');
%hold on;
%pause(0.005);
