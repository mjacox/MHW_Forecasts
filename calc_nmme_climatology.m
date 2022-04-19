function calc_nmme_climatology
% ================================================================
% Calculate and save ensemble mean climatologies from NMME forecasts
% from lead-dependent hindcast/forecast output
%
%   calc_nmme_climatology
%
% M. Jacox
% 2021
% ================================================================

% Years used for climatology
clim_years = [1991 2020];

% Input/output directory
dirin = '/Volumes/Data_2TB/NMME/SST/by_lead/concatenated';
dirout = '/Volumes/Data_2TB/NMME/SST/by_lead/climatology';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nCalculating climatologies for NMME forecasts...\n')
for imod = 1:nmod
    
    fprintf('Processing %s...\n',mods{imod})
    
    % Loop through lead times
    for il = 0:nl(imod)
        
        % Load hindcast
        f_in = sprintf('%s/sst_%s_l%d_concatenated_ensmean.mat',dirin,mods{imod},il);
        load(f_in,'sst','time','lon','lat')
        
        % Find year and month (time is in months since 1960-1-1)
        time = double(time);
        [yy,mm,~]=datevec(datenum([1960*ones(size(time)) time+1 ones(size(time))]));

        % Calculate climatology
        for im = 1:12
            ind = find(mm==im & yy>=clim_years(1) & yy<=clim_years(2));
            sst_clim(:,:,im) = nanmean(sst(:,:,ind),3); 
        end

        % Save to file
        f_out = sprintf('%s/sst_%s_l%d_ensmean_climatology_%d_%d.mat',dirout,mods{imod},il,clim_years(1),clim_years(2));
        save(f_out,'lon','lat','sst_clim')
    end
end
fprintf('Done\n\n')