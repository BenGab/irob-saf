clear all;
close all;
rosshutdown;
rosinit;

cfgfilename = 'registration_psm1.cfg';

posesub = rossubscriber('/dvrk/PSM1/position_cartesian_current', 'geometry_msgs/PoseStamped');

left_img_sub = rossubscriber('/saf/stereo/left/image_rect', 'sensor_msgs/Image');
right_img_sub = rossubscriber('/saf/stereo/right/image_rect', 'sensor_msgs/Image');
disparity_sub = rossubscriber('/saf/stereo/disparity', 'stereo_msgs/DisparityImage');

left_cam_info_sub = rossubscriber('/saf/stereo/left/calibrated/camera_info', 'sensor_msgs/CameraInfo');
right_cam_info_sub = rossubscriber('/saf/stereo/right/calibrated/camera_info', 'sensor_msgs/CameraInfo');

pause(2) % Wait to ensure publisher is registered

disp('Waiting for camera info...');

left_cam_info = receive(left_cam_info_sub);
right_cam_info = receive(right_cam_info_sub);

disp('Camera info received:');
left_p = reshape(left_cam_info.P, 4, 3)
right_p = reshape(right_cam_info.P, 4, 3)


marker_3d = double(zeros(0,3));
robot_3d = double(zeros(0,3));

i = 1;
n = 7;

while i < (n+1)
    
    w = waitforbuttonpress;
    left_img_msg = left_img_sub.LatestMessage;
    right_img_msg = right_img_sub.LatestMessage;
    disparity_msg = disparity_sub.LatestMessage;
    
    if (and(size(left_img_msg) > 0, size(right_img_msg) > 0))
        IL = readImage(left_img_msg);
        IR = readImage(right_img_msg);
        disparityMap = readImage(disparity_msg.Image);
        
        imshow([IL, IR])
        
        getGrabLocation(IL, IR, disparityMap, left_p, right_p)
      
        
    else
        disp('No images received');
    end
    
    
    
    
end

rosshutdown;
%
% R = orth(rand(3,3)); % random rotation matrix
%
% if det(R) < 0
%     V(:,3) = V(:,3)*(-1);
%     R = V*U';
% end
%
% t = rand(3,1); % random translation
%
% robot_3d = R*marker_3d' + repmat(t, 1, n);
% robot_3d = robot_3d';
%
% robot_3d(1,1) = robot_3d(1,1) + 0.01;

[R, t] = rigid_transform_3D(marker_3d, robot_3d)

marker_3d_2 = (R*marker_3d') + repmat(t, 1, n);
marker_3d_2 = marker_3d_2';

figure
subplot(2,1,1);
scatter3(marker_3d(:,1), marker_3d(:,2), marker_3d(:,3), 'MarkerEdgeColor','b',...
    'MarkerFaceColor','b')
hold on
scatter3(robot_3d(:,1), robot_3d(:,2), robot_3d(:,3), 'MarkerEdgeColor','r',...
    'MarkerFaceColor','r')
hold off

subplot(2,1,2);
scatter3(marker_3d_2(:,1), marker_3d_2(:,2), marker_3d_2(:,3), 'MarkerEdgeColor','b',...
    'MarkerFaceColor','b')
hold on
scatter3(robot_3d(:,1), robot_3d(:,2), robot_3d(:,3), 'MarkerEdgeColor','r',...
    'MarkerFaceColor','r')
hold off


fileID = fopen(cfgfilename,'w');

fprintf(fileID,'%f\t%f\t%f\n', t(1), t(2), t(3));
for i = 1:3
    fprintf(fileID,'%f\t%f\t%f\n', R(i,1), R(i,2), R(i,3));
end

fclose(fileID);
disp('Registration saved to file.');