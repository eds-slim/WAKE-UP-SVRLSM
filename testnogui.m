% input=struct();
%
% input.optimization.objective_function = 'Predict Behavior';
% input.optimization.search_strategy='Grid Search';
% input.optimization.do_optimize=false;
% input.optimization.grid_divisions=10;
% input.optimization.iterations=100;
% input.score_file='PNT.csv';
% input.score_name='Sim_ROI_123';
% input.tails='tails';
% input.lesion_img_folder='lesion_imgs';
% input.imagedata.do_binarize=0;
% input.do_CFWER=false;
% input.method.mass_univariate=false;
% input.optimization.params_to_optimize.cost=true;
% input.optimization.best.cost=1;
% input.cost=1;
%
% input.optimization.params_to_optimize.sigma=true;
% input.optimization.best.sigma=1;
% input.sigma=1;

addpath(genpath('/home/eckhard/Documents/MATLAB/toolboxes/svrlsmgui-master'))
addpath(genpath('/home/eckhard/Documents/MATLAB/toolboxes/spm12'))

input=GetDefaultParameters();
input.waitbar = [];
parameters.lesion_thresh = 2; % The least lesion subject number for a voxel to be considered in the following analysis.

poolsizes=[8];



for perms = [2]

input.PermNumVoxelwise = perms;
input.PermNumClusterwise = perms;

input.is_saved = 0;

mypath = fileparts(which('svrlsmgui'));

input.analysis_out_path = fullfile(pwd,'output'); % input.analysis_root; % is this a good default?
input.score_file = fullfile(mypath,'default2','PNT.csv');
input.score_name = 'Sim_ROI_123';
input.lesion_img_folder = fullfile(mypath,'default2','lesion_imgs');

j=0;
telapsed=nan(size(poolsizes));
for ps=poolsizes
    j=j+1;
    myCluster = parcluster('local');
    myCluster.NumWorkers = ps;
    saveProfile(myCluster);
    
    tstart = tic;
    for i=1:1
        sprintf('Perms: %d, poolsize: %d, iteration: %d', perms, ps, i)
        input.analysis_name = ['Unnamed' num2str(perms) '-' num2str(ps) '-' num2str(i)];
        RunAnalysisNoGUI(input);
        delete(gcp('nocreate'))
        close
    end
    
    telapsed(j) = toc(tstart);
    sprintf('Elapsed time is %f1.2', telapsed);
    
   
    
end

save(fullfile(input.analysis_out_path, [input.analysis_name, '.mat']),'perms','poolsizes', 'telapsed')

end

return
%%
figure
loglog(poolsizes,telapsed/10,'--o')
xticks(poolsizes); grid on
xlabel('Pool size')
ylabel('Time [s]')
title(sprintf('%d Permutations; 15 Subjects; 10 Repetitions', perms))

%% 10 Subjects> ~ 540 secs

