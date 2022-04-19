function nmme_ensemble_mhw(is_detrend)
% ================================================================
% Combine MHW forecasts of individual NMME models to produce a 
% multimodel ensemble forecast
%
%   nmme_ensemble_mhw(is_detrend)
%
% Input:
%   is_detrend: 1 to use detrended anomalies (default), 0 otherwise

% M. Jacox
% July 2021
% ================================================================

% Input/output directory
if nargin==1 && is_detrend==0
    dir = '/Volumes/Data_2TB/NMME/SST/by_lead/mhw';
else
    is_detrend = 1;
    dir = '/Volumes/Data_2TB/NMME/SST/by_lead/mhw/detrended';
end

% Years being processed
years = [1991 2020];

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through lead times
fprintf('\nBuilding multimodel ensemble for NMME MHW forecasts...\n')
fprintf('Lead')
for il = 0:max(nl)
    fprintf(' %d',il)
        
    % Loop through models
    mm = 1;
    for imod = 1:nmod
    
        if il<=nl(imod)
            
            % Load MHWs
            if is_detrend==1
                f_in = sprintf('%s/mhw_%s_l%d_detrended_%d_%d.mat',dir,mods{imod},il,years(1),years(2));
            else
                f_in = sprintf('%s/mhw_%s_l%d_%d_%d.mat',dir,mods{imod},il,years(1),years(2));
            end
            load(f_in)      
        
            if exist('is_mhw_ens','var')
                is_mhw_ens = cat(3,is_mhw_ens,is_mhw);
            else
                is_mhw_ens = is_mhw;
            end 
            
            % Record which model is associated with which forecasts
            nm = size(is_mhw,3);
            for im = 1:nm
                model{mm} = mods{imod};
                mm = mm+1;
            end
        end
    end
        
    % Find forecast MHW probability
    mhw_prob = squeeze(mean(is_mhw_ens,3,'omitnan'));

    % Save to file
    if is_detrend==1
        f_out = sprintf('%s/mhw_MME_l%d_detrended_%d_%d.mat',dir,il,years(1),years(2));
    else
        f_out = sprintf('%s/mhw_MME_l%d_%d_%d.mat',dir,il,years(1),years(2));
    end
    is_mhw = single(is_mhw_ens);
    mhw_prob = single(mhw_prob);
    save(f_out,'-v7.3','lon','lat','time','year','month','model','is_mhw','mhw_prob')
    clear is_mhw* mhw_prob* time year month model
end
fprintf('\nDone\n\n')