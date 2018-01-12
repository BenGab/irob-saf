% in mm
model_3d_corners = [0, 0, 0; ...
                    0, 120.5, 0; ...
                    101, 120.5, 0; ...
                    100, -3, 0];
               
model_3d_targets = [18, 33, 0; ...    %
                    36.8, 15.8, 0; ...
                    58.6, 14.4, 0; ...
                    76.4, 35, 0; ...
                    38.8, 54.2, 0; ...
                    61.6, 52.8, 0; ...  %
                    22.5, 74.5, 0; ...  %
                    24, 98.8, 0; ...
                    48.2, 73.1, 0; ...
                    49.2, 99.0, 0; ...
                    78.8, 72.8, 0; ...
                    81.9, 97.6, 0; ...  %
                    ];
                
target_h = 40.0;

grasp_h = 9.0;

model_3d_approaches = model_3d_targets + repmat([0, 0, target_h], size(model_3d_targets, 1), 1);

model_3d_grasps = model_3d_targets + repmat([0, 0, grasp_h], size(model_3d_targets, 1), 1);

target_d = 8.0;


save pnp_phantom_model.mat model_3d_corners model_3d_targets model_3d_approaches model_3d_grasps target_h grasp_h target_d