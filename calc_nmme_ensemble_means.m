function calc_nmme_ensemble_means
% ================================================================
% Calculate and save ensemble means for NMME forecasts using
% concatenated hindcast/forecast output
%
%   calc_nmme_ensemble_means
%
% M. Jacox
% 2021
% ================================================================

% Input/output directory
dir = '/Volumes/Data_2TB/NMME/SST/by_lead/concatenated';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nm = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nCalculating ensemble means for NMME forecasts...\n')
for im = 1:nm
    
    % Calculate ensemble means
    fprintf('Processing %s...\n',mods{im})
    fprintf('Lead')
    
    % Loop through lead times
    for il = 0:nl(im)
        fprintf(' %d',il)
        f_in = sprintf('%s/sst_%s_l%d_concatenated.mat',dir,mods{im},il);
        f_out = sprintf('%s/sst_%s_l%d_concatenated_ensmean.mat',dir,mods{im},il);
        load(f_in)
        sst = squeeze(nanmean(sst,3));
        save(f_out,'lon','lat','time','sst')
        clear lon lat sst
    end
end
fprintf('\nDone\n\n')

