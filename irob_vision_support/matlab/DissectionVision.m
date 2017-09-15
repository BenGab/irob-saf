classdef DissectionVision < handle
    
    
    properties
        
        state = DissectionStates.init;
        
        dissection_group_n = 0;
        local_dissection_n = 0;
        
        
        do_dissection = false;
        do_retraction = true;
        
        groupN = 30;
        
        tgt_ori = [ 0.0042   -0.0268   -0.1073    0.9939];
        dp_dist = 0.04;
        dp_rot = 345.0;
        
        dist_pos = [0.12,0.03, 0.26];
        dist_ori = [   0.8316    0.0197   -0.1899    0.5215];
        retractor_ori = [  0.1266   -0.0723    0.0230    0.9890];
        
        retractor_pos;
        retractor_dp_dist = 0.03;
        retractor_dp_rot = 355.0;
        
        stepPix = 6;
        memN = 3;
        lastIdxs = [];
        groupMinIdx = 1;
        userInputX = [0, 0];
        userInputY = [0, 0];
        n;
        stereoParams;
        tgt_idx = 1;
        tgt_pos;
        dissection_profile;
        im_coord_L;
        fine_retr_count = 0;
        
        dissection_targetsrv;
        dissection_dotasksrv;
        dissection_errpub;
        
        retraction_targetsrv;
        retraction_dotasksrv;
        retraction_errpub;
        
        statussub;
        
        cam_l;
        cam_r;
        
    end
    
    methods
        
        function obj = DissectionVision
            obj.state = DissectionStates.init;
            obj.stereoParams=load('stereoParams.mat');
            obj.n = (obj.groupN / obj.stepPix)+1;
            
            rosshutdown;
            rosinit;
            
            imaqreset;
            webcamlist()
            obj.cam_r = videoinput('linuxvideo', 1, 'BGR24_640x480');
            obj.cam_l = videoinput('linuxvideo', 2, 'BGR24_640x480');
            
           % preview([obj.cam_l, obj.cam_r]);
            triggerconfig(obj.cam_r, 'manual');
            triggerconfig(obj.cam_l, 'manual');
            start(obj.cam_r);
            start(obj.cam_l);
            set_focus;
            obj.dissection_targetsrv = rossvcserver('/dvrk_vision/movement_target_dissector','irob_dvrk_automation/TargetPose', @obj.getTargetCallback);
            obj.dissection_dotasksrv = rossvcserver('/dvrk_vision/do_task_dissector', 'irob_dvrk_automation/BoolQuery', @obj.toDoDissectionCallback);
            obj.dissection_errpub = rospublisher('/dvrk_vision/error_dissector', 'std_msgs/String');
            
            obj.retraction_targetsrv = rossvcserver('/dvrk_vision/movement_target_retractor','irob_dvrk_automation/TargetPose', @obj.getTargetCallback);
            obj.retraction_dotasksrv = rossvcserver('/dvrk_vision/do_task_retractor', 'irob_dvrk_automation/BoolQuery', @obj.toDoRetractionCallback);
            obj.retraction_errpub = rospublisher('/dvrk_vision/error_retractor', 'std_msgs/String');
            
            obj.statussub = rossubscriber('/dvrk_vision/subtask_status_dissector', 'std_msgs/String');
            pause(2) % Wait to ensure publisher is registered
            %disp('capture');
            %tic
            [ I_l, I_r ] = stereo_capture(obj.cam_l, obj.cam_r);
            %toc
            
            [obj.retractor_pos, obj.im_coord_L ] = getGrabLocation( I_l, I_r, obj.stereoParams);
            %!!!!!!!!!!!!
            %[ obj.dissection_profile, obj.tgt_ori, obj.im_coord_L ] = getDissectionProfileAndOri(  I_l, I_r, obj.stereoParams, obj.im_coord_L );
            
            obj.retractor_pos = obj.retractor_pos + [0.00, -0.005, -0.01];
            
            disp(obj.retractor_pos);
            disp('Init done');
           
        end
        
        
        % Callback for pos query
        function response = getTargetCallback(obj,server,reqmsg,defaultrespmsg)
            response = defaultrespmsg;
            % Build the response message here
            done = false;
            
            
            switch obj.state
                case DissectionStates.init
                    disp(obj.retractor_pos);
                    [dp_pos, dp_ori] = getDP(obj.retractor_dp_dist, obj.retractor_dp_rot, obj.retractor_pos, obj.retractor_ori );
                    disp(dp_pos);
                    response = DissectionVision.wrapPose(response, dp_pos, dp_ori);
                    response.PositionType = response.DP;
                    
                case DissectionStates.at_grab_dp
                    
                    response = DissectionVision.wrapPose(response, obj.retractor_pos,obj.retractor_ori);
                    response.PositionType = response.GOAL;
                    
                case DissectionStates.tissue_grabbed
                    
                    %obj.retractor_pos = obj.retractor_pos + [0.0, -0.045, 0.03];
                    obj.retractor_pos = obj.retractor_pos + [0.0, -0.025, 0.008];
                    [dp_pos, obj.retractor_ori] = getDP(obj.retractor_dp_dist, 340.0, obj.retractor_pos, obj.retractor_ori );
                    
                    %disp(obj.retractor_ori);
                    
                    response = DissectionVision.wrapPose(response, obj.retractor_pos, obj.retractor_ori);
                    response.PositionType = response.GOAL;
                    set_focus;
                    
                case DissectionStates.done_dissection_group
                    % capture img; choose group loc; choose tgt; get dp; goto tgt dp;
                    
                    [ I_l, I_r ] = stereo_capture(obj.cam_l, obj.cam_r);

                    
                    [ angle, tension, visible_size, im_coord_L ] = getRetractionAngles( I_l, I_r, obj.stereoParams, obj.im_coord_L );
                    
                    disp ('angle');
                    disp(angle);
                    disp ('tension');
                    disp(tension);
                    disp ('visible size');
                    disp(visible_size);
                    
                    [ y, z, done ] = fineRetractonCtrl( angle, tension, visible_size )
                    %[ y, z, done ] = fineRetractonCtrlFuzzy( angle, tension, visible_size )
                    obj.retractor_pos = obj.retractor_pos + [0.0, y, z];
                    obj.fine_retr_count = obj.fine_retr_count + 1;
                    
                    if obj.fine_retr_count > 2
                        done = true;
                    end
                    
                    response = DissectionVision.wrapPose(response, obj.retractor_pos,obj.retractor_ori);
                    %
                    %done = true;
                    
                    if (done)
                        response.PositionType = response.GOAL;
                        obj.do_dissection = true;
                        obj.do_retraction = false;
                        obj.fine_retr_count = 0;
                    else
                        response.PositionType = response.DP;
                    end
                    
                    set_focus;
                    
                case DissectionStates.done_retraction
                    % capture img; choose group loc; choose tgt; get dp; goto tgt dp;
                    [ I_l, I_r ] = stereo_capture(obj.cam_l, obj.cam_r);
                    
                    [ obj.dissection_profile, obj.tgt_ori, obj.im_coord_L ] = getDissectionProfileAndOri(  I_l, I_r, obj.stereoParams, obj.im_coord_L );
                    
                    [obj.groupMinIdx, obj.lastIdxs] = chooseTgt(obj.dissection_profile, obj.groupN, obj.lastIdxs, obj.memN);
                    
                    obj.dissection_group_n = obj.dissection_group_n + 1;
                    obj.local_dissection_n = 0;
                    
                    obj.tgt_idx = obj.stepPix*obj.local_dissection_n +1;
                    [obj.tgt_pos, tgt_ori_NOT_USED] = getTgt(obj.tgt_idx, ...
                        obj.groupMinIdx, obj.groupN, obj.dissection_profile);
                    
                    obj.dist_ori = obj.tgt_ori;
                    obj.tgt_pos = obj.tgt_pos + [0.0, 0.0, 0.005];
                    
                    [dp_pos, dp_ori] = getDP(obj.dp_dist, obj.dp_rot, obj.tgt_pos, obj.tgt_ori );
                    
                    response = DissectionVision.wrapPose(response, dp_pos, dp_ori);
                    response.PositionType = response.DP;
                    
                    
                case DissectionStates.at_tgt_dp
                    % goto tgt as goal
                    response = DissectionVision.wrapPose(response, obj.tgt_pos, obj.tgt_ori);
                    response.PositionType = response.GOAL;
                    
                case DissectionStates.at_tgt_goal
                    % goto distant dp as goal
                    
                    % or go to distant dp as dp
                    obj.local_dissection_n = obj.local_dissection_n + 1;
                    
                    [dp_pos, dp_ori] = getDP(obj.dp_dist, obj.dp_rot, obj.tgt_pos, obj.tgt_ori );
                    
                    response = DissectionVision.wrapPose(response, dp_pos, dp_ori);
                    
                    if obj.local_dissection_n >= obj.n
                        if obj.dissection_group_n >= obj.groupN
                            obj.do_dissection = false;
                            obj.do_retraction = true;
                        end
                        done = true;
                        response.PositionType = response.DP;
                    else
                        done = false;
                        response.PositionType = response.GOAL;
                    end
                    
                case DissectionStates.at_distant_dp
                    %go to distant goal
                    response = DissectionVision.wrapPose(response, obj.dist_pos, obj.dist_ori);
                    response.PositionType = response.GOAL;
                    
                case DissectionStates.at_distant_goal
                    % choose tgt; get dp; go to tgt dp
                    obj.tgt_idx = obj.stepPix*obj.local_dissection_n +1;
                    [obj.tgt_pos, tgt_ori_NOT_USED] = getTgt(obj.tgt_idx, ...
                        obj.groupMinIdx, obj.groupN, obj.dissection_profile);
                    
                    obj.dist_ori = obj.tgt_ori;
                    obj.tgt_pos = obj.tgt_pos + [0.00, 0.00, 0.005];
                    
                    [dp_pos, dp_ori] = getDP(obj.dp_dist, obj.dp_rot, obj.tgt_pos, obj.tgt_ori );
                    
                    response = DissectionVision.wrapPose(response, dp_pos, dp_ori);
                    response.PositionType = response.DP;
                    
                otherwise
                    warning('Unexpected query, do nothing...')
            end
            
            % Step state
            disp('1');
            obj.state = obj.state.next(reqmsg, done);
            disp(reqmsg);
            disp(obj.state);
            if obj.state == DissectionStates.abort
                response = defaultrespmsg;
                stop(obj.cam_r);
                stop(obj.cam_l);
                % Do err handling
            end
            
        end
        
        
        
        % Callback for task done
        function response = toDoDissectionCallback(obj,server,reqmsg,defaultrespmsg)
            response = defaultrespmsg;
            % Build the response message here
            
            response.Data = obj.do_dissection;
        end
        
        % Callback for task done
        function response = toDoRetractionCallback(obj,server,reqmsg,defaultrespmsg)
            response = defaultrespmsg;
            % Build the response message here
            
            response.Data = obj.do_retraction;
        end
    end
    
    
    methods(Static)
        function response = wrapPose(response, pos, ori)
            response.Pose.Position.X = pos(1);
            response.Pose.Position.Y = pos(2);
            response.Pose.Position.Z = pos(3);
            response.Pose.Orientation.X =  ori(2);
            response.Pose.Orientation.Y =  ori(3);
            response.Pose.Orientation.Z =  ori(4);
            response.Pose.Orientation.W =  ori(1) ;
        end
    end
    
end
