function detrend_nmme_anomalies
% ================================================================
% Remove linear trend from NMME forecast SST anomalies
%
%   detrend_nmme_anomalies
%
% M. Jacox
% 2021
% ================================================================

% Suppress warnings about poorly conditioned fits
warning off

% Years used for anomaly calculations
years = [1991 2020];

% Input/output directories
dirin = '/Volumes/Data_2TB/NMME/SST/by_lead/anomaly';
dirout = '/Volumes/Data_2TB/NMME/SST/by_lead/anomaly/detrended';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nDetrending anomalies for NMME forecasts...\n')
for imod = 1:nmod
    
    fprintf('\nProcessing %s...\n',mods{imod})
    fprintf('Lead')
    
    % Loop through lead times
    for il = 0:nl(imod)
        fprintf(' %d',il)
        
        % Load anomalies
        f_in = sprintf('%s/sst_%s_l%d_anomaly_%d_%d.mat',dirin,mods{imod},il,years(1),years(2));
        load(f_in)
        
        % Reshape for detrending, making first dimension time
        tmp = permute(sst_an,[4 1 2 3]);
        
        % Detrend
        tmp_dt = detrend(tmp,'omitnan');
        
        % Return to original shape
        sst_an_dt = permute(tmp_dt,[2 3 4 1]);

        % Save to file
        f_out = sprintf('%s/sst_%s_l%d_anomaly_detrended_%d_%d.mat',dirout,mods{imod},il,years(1),years(2));
        sst_an_dt = single(sst_an_dt);
        save(f_out,'-v7.3','lon','lat','sst_an_dt','time','year','month')
        clear sst_an* tmp* time year month
    end
end
fprintf('\nDone\n\n')