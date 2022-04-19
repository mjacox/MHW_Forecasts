function calc_nmme_anomalies
% ================================================================
% Calculate and save NMME forecast SST anomalies, calculated
% relative to model ensemble mean climatologies
%
%   calc_nmme_anomalies
%
% M. Jacox
% 2021
% ================================================================

% Years used for anomaly calculations
years = [1991 2020];

% Input/output directories
dir_forc = '/Volumes/Data_2TB/NMME/SST/by_lead/concatenated';
dir_clim = '/Volumes/Data_2TB/NMME/SST/by_lead/climatology';
dirout = '/Volumes/Data_2TB/NMME/SST/by_lead/anomaly';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nCalculating anomalies for NMME forecasts...\n')
for imod = 1:nmod
    
    fprintf('\nProcessing %s...\n',mods{imod})
    fprintf('Lead')
    
    % Loop through lead times
    for il = 0:nl(imod)
        fprintf(' %d',il)
        
        % Load climatology
        f_clim = sprintf('%s/sst_%s_l%d_ensmean_climatology_1991_2020.mat',dir_clim,mods{imod},il);
        load(f_clim,'sst_clim')
    
        % Load hindcast/forecast
        f_in = sprintf('%s/sst_%s_l%d_concatenated.mat',dir_forc,mods{imod},il);
        load(f_in,'sst','time','lon','lat')
        
        % Constrain to specified years
        time = double(time);
        [yy,mm,~]=datevec(datenum([1960*ones(size(time)) time+1 ones(size(time))]));
        ind = find(yy>=years(1)&yy<=years(end));
        sst = sst(:,:,:,ind);
        yy = yy(ind);
        mm = mm(ind);
        time = time(ind);
        
        % Loop through time and compute anomalies
        nt = length(yy);
        for it = 1:nt
            sst_an(:,:,:,it) = sst(:,:,:,it) - sst_clim(:,:,mm(it));
        end

        % Save to file
        f_out = sprintf('%s/sst_%s_l%d_anomaly_%d_%d.mat',dirout,mods{imod},il,years(1),years(2));
        year = yy;
        month = mm;
        sst_an = single(sst_an);
        save(f_out,'-v7.3','lon','lat','sst_an','time','year','month')
        clear sst sst_an time year month
    end
end
fprintf('\nDone\n\n')