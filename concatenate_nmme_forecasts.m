function concatenate_nmme_forecasts
% =======================================================================
% Concatenate NMME hindcasts and forecasts to make continuous time series
% Apply land mask from hindcasts to forecasts
% Convert units to K for all models
%
% For models with more ensemble members in the forecast than in the
% hindcast, only retain the number in the hindcast. For CFS, use 24
% ensemble members for all months.
%
%   concatenate_nmme_forecasts
%
% M. Jacox
% 2021
% =======================================================================

% Model info
% Name              Hindcast                Forecast                Leads
% ----              --------                --------                -----
% CanCM4i           10 members, 1981-2018	10 members, 2019-       0-11
% COLA-RSMAS-CCSM4  10 members, 1982-                               0-11
% GEM-NEMO          10 members, 1981-2018   10 members, 2019-       0-11
% GFDL-SPEAR        15 members, 1991-2020   30 members, 2020-       0-11
% NASA-GEOSS2S      4 members, 1981-1/2017  10 members, 2/2017-     0-8
% NCEP-CFSv2        24 members, 1982-                               0-9

% Directories
dir_hc = '/Volumes/Data_2TB/NMME/SST/by_lead/hindcast';
dir_fc = '/Volumes/Data_2TB/NMME/SST/by_lead/forecast';
dir_out = '/Volumes/Data_2TB/NMME/SST/by_lead/concatenated';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};
nmod = length(mods);
nl = [11 11 11 11 8 9]; % Max lead time for each model

% Loop through models
fprintf('\nConcatenating hindcasts and forecasts...\n')
for imod = 1:nmod
    
    fprintf('\nProcessing %s...\n',mods{imod})
    fprintf('Lead')
    
    % Loop through lead times
    for il = 0:nl(imod)
        fprintf(' %d',il)
        
        % Load hindcast
        f_in = sprintf('%s/sst_%s_hindcast_l%d.mat',dir_hc,mods{imod},il);
        load(f_in,'sst','time','lon','lat')
        sst1 = sst;
        time1 = time;
        if imod~=6
            nm = size(sst1,3); % # of ensemble members
        else
            nm = 24; % For CFSv2
            sst1 = sst1(:,:,1:24,:);
        end
        clear sst time
        
        % Get mask
        if il==0
            tmp = sst1(:,:,1,1);
            mask = ones(size(tmp));
            switch mods{imod}
                case {'CanCM4i' 'GEM-NEMO'}
                    mask(tmp==0) = 0;
                case {'COLA-RSMAS-CCSM4' 'GFDL-SPEAR'}
                    mask(abs(tmp)>1e3) = 0;
                case {'NASA-GEOSS2S' 'NCEP-CFSv2'}
                    mask(isnan(tmp)) = 0;
            end
        end
        
        if imod~=2 && imod~=6
            % Load forecast
            f_in = sprintf('%s/sst_%s_forecast_l%d.mat',dir_fc,mods{imod},il);
            load(f_in,'sst','time')
            sst2 = sst;
            time2 = time;
            clear sst time
            
            % Constrain to number of members in hindcast
            sst2 = sst2(:,:,1:nm,:);
           
            % Concatenate hindcast and forecast, eliminating temporal overlap
            ind = find(time2>max(time1));
            time2 = time2(ind);
            sst2 = sst2(:,:,:,ind);
            time = [time1;time2];
            sst = cat(4,sst1,sst2);
        else
            sst = sst1;
            time = time1;
        end
        
        % Apply mask from hindcast
        nt = length(time);
        for im = 1:nm
            for it = 1:nt
                tmp = sst(:,:,im,it);
                tmp(mask==0) = nan;
                sst(:,:,im,it) = tmp;
            end
        end
        
        % Adjust units if necessary
        switch mods{imod}
        	case {'CanCM4i' 'GEM-NEMO'}
                sst = sst - 273.15; % Convert K to C
        end
        
        % Remove outliers / missing data
        sst(abs(sst)>100) = nan;

        % Save to file
        f_out = sprintf('%s/sst_%s_l%d_concatenated.mat',dir_out,mods{imod},il);
        save(f_out,'-v7.3','time','lon','lat','sst')
    end
end
fprintf('\nDone\n\n')