function calc_nmme_mhw(is_detrend)
% ================================================================
% Calculate MHW thresholds, identify forecast MHWs, and calculate
% forecast MHW probabilities from NMME output
% MHWs are calculated using a seasonally-varying 90th percentile
% threshold on SST anomalies
%
%   calc_nmme_mhw(is_detrend)
%
% Input:
%   is_detrend: 1 to use detrended anomalies (default), 0 otherwise
%
% M. Jacox
% July 2021
% ================================================================

% Input/output directory
if nargin==1 && is_detrend==0
    dir_in = '/Volumes/Data_2TB/NMME/SST/by_lead/anomaly';
    dir_out = '/Volumes/Data_2TB/NMME/SST/by_lead/mhw';
else
    is_detrend = 1;
    dir_in = '/Volumes/Data_2TB/NMME/SST/by_lead/anomaly/detrended';
    dir_out = '/Volumes/Data_2TB/NMME/SST/by_lead/mhw/detrended';
end

% Years to process and years to use as climatology for thresholds
years = [1991 2020];
clim_years = [1991 2020];

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nIdentifying MHWs for NMME forecasts...\n')
for imod = 1:nmod
    
    fprintf('\nProcessing %s...\n',mods{imod})
    fprintf('Lead')
    
    % Loop through lead times
    for il = 0:nl(imod)
        fprintf(' %d',il)
        
        % Load anomalies        
        if is_detrend==1
            f_in = sprintf('%s/sst_%s_l%d_anomaly_detrended_%d_%d.mat',dir_in,mods{imod},il,years(1),years(2));
            load(f_in)
            sst_an = sst_an_dt;
        else
            f_in = sprintf('%s/sst_%s_l%d_anomaly_%d_%d.mat',dir_in,mods{imod},il,years(1),years(2));
            load(f_in)
        end
        
        % Loop through month and compute sst anomaly thresholds for MHWs
        % Thresholds are computed with a 3-month moving window
        for ii = 1:12
            if ii==1
                tmp = sst_an(:,:,:,(month==12 | month<=2) & year>=clim_years(1) & year<=clim_years(2));
            elseif ii==12
                tmp = sst_an(:,:,:,(month==1 | month>=11) & year>=clim_years(1) & year<=clim_years(2));
            else
                tmp = sst_an(:,:,:,month>=ii-1 & month<=ii+1 & year>=clim_years(1) & year<=clim_years(2));
            end
            [nx,ny,nm,nt] = size(tmp);
            tmp = reshape(tmp,nx,ny,nm*nt); % Pool all members/initializations for each grid cell
            sst_an_thr(:,:,ii) = prctile(tmp,90,3);
        end
        
        % Find points that exceed thresholds
        [nx,ny,nm,nt] = size(sst_an);
        for ii = 1:nt
            for im = 1:nm
                tmp = zeros(nx,ny);
                tmp(sst_an(:,:,im,ii)>sst_an_thr(:,:,month(ii)))= 1;
                tmp(isnan(sst_an(:,:,im,ii))) = nan;
                is_mhw(:,:,im,ii) = tmp;
            end
        end     
        
        % Find forecast MHW probability
        mhw_prob = squeeze(mean(is_mhw,3,'omitnan'));
        
        % Save to file
        if is_detrend==1
            f_out = sprintf('%s/mhw_%s_l%d_detrended_%d_%d.mat',dir_out,mods{imod},il,years(1),years(2));
        else
            f_out = sprintf('%s/mhw_%s_l%d_%d_%d.mat',dir_out,mods{imod},il,years(1),years(2));
        end
        sst_an_thr = single(sst_an_thr);
        is_mhw = single(is_mhw);
        mhw_prob = single(mhw_prob);
        save(f_out,'-v7.3','lon','lat','time','year','month','sst_an_thr*','is_mhw*','mhw_prob*')
        clear sst* is_mhw* mhw_prob* time year month
    end
end
fprintf('\nDone\n\n')