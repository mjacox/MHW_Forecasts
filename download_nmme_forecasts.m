function download_nmme_forecasts
% ================================================================
% Download NMME SST data from OEPeNDAP and save as .mat files
% Each lead time is saved to a separate file
%
% Note that matlab downloads through OPeNDAP must be processed in small
% chunks and are extremely slow. Other download options (e.g., using wget)
% are much faster.
%
%   download_nmme_forecasts
%
% M. Jacox
% 2021
% ================================================================

% Input directory for NMME forecast output
dirin = 'http://iridl.ldeo.columbia.edu/SOURCES/.Models/.NMME';

% Output directory for downloads
dirout = '/Volumes/Data_2TB/NMME/SST/by_lead';

% Model names
mods = {'CanCM4i' 'COLA-RSMAS-CCSM4' 'GEM-NEMO' 'GFDL-SPEAR' 'NASA-GEOSS2S' 'NCEP-CFSv2'};

% Model info
% Name              Hindcast folder             Forecast folder         Leads
% ----              --------                    --------                -----
% CanCM4i           10 members, 1981-2018       10 members, 2019-       0-11
% COLA-RSMAS-CCSM4  10 members, 1982-                                   0-11
% GEM-NEMO          10 members, 1981-2018       10 members, 2019-       0-11
% GFDL-SPEAR        15 members, 1991-2020       30 members, 2021-       0-11
% NASA-GEOSS2S      4 members, 1981-1/2017      10 members, 2/2017-     0-8
% NCEP-CFSv2        24-28 members, 1982-                                0-9
%
% Model outputs have dimensions [lon lat ensemble_member lead initialization]
% except CanCM4i and GEM-NEMO [lon lat lead ensemble_member initialization]

% Number of time steps to grab at each opendap call (to avoid download
% failures)
time_chunk = 10;

% Loop through models, save each lead time to a separate file
for imod = 1:length(mods)
    switch mods{imod}
        case 'COLA-RSMAS-CCSM4' % Everything in one folder
            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\nDownloading %s (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin = sprintf('%s/.%s/.MONTHLY/.sst/dods',dirin,mods{imod});
            lon = ncread(fin,'X');
            lat = ncread(fin,'Y');
            time = ncread(fin,'S');                  
            nt = length(time);
            nl = length(ncread(fin,'L'));
            nm = length(ncread(fin,'M'));

            % Need to download in small chunks to avoid errors
            for il = 1:nl
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/hindcast/sst_%s_hindcast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin,'sst',[1 1 im il tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end

        case 'NCEP-CFSv2' % Everything in one folder
            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\n\nDownloading %s hindcasts (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin_hc = sprintf('%s/.%s/.HINDCAST/.PENTAD_SAMPLES_FULL/.sst/dods',dirin,mods{imod});
            lon = ncread(fin_hc,'X');
            lat = ncread(fin_hc,'Y');
            time = ncread(fin_hc,'S');
            nt = length(time);
            nl = length(ncread(fin_hc,'L'));
            nm = length(ncread(fin_hc,'M'));
            for il = 1:nl       
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/hindcast/sst_%s_hindcast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin_hc,'sst',[1 1 im il tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end 

        case {'CanCM4i' 'GEM-NEMO'}
            % Hindcasts and forecasts in separate folders
            % These models use a different order of dimensions from others
            
            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\n\nDownloading %s hindcasts (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin_hc = sprintf('%s/.%s/.HINDCAST/.MONTHLY/.sst/dods',dirin,mods{imod});            
            lon = ncread(fin_hc,'X');
            lat = ncread(fin_hc,'Y');
            time = ncread(fin_hc,'S');
            nt = length(time);
            nl = length(ncread(fin_hc,'L'));
            nm = length(ncread(fin_hc,'M'));
            for il = 1:nl        
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/hindcast/sst_%s_hindcast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin_hc,'sst',[1 1 il im tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end

            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\n\nDownloading %s forecasts (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin_fc = sprintf('%s/.%s/.FORECAST/.MONTHLY/.sst/dods',dirin,mods{imod});
            lon = ncread(fin_fc,'X');
            lat = ncread(fin_fc,'Y');
            time = ncread(fin_fc,'S');
            nt = length(time);
            nl = length(ncread(fin_fc,'L'));
            nm = length(ncread(fin_fc,'M'));
            for il = 1:nl
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/forecast/sst_%s_forecast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin_fc,'sst',[1 1 il im tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end

        case {'GFDL-SPEAR' 'NASA-GEOSS2S'}
            % Hindcasts and forecasts in separate folders
            
            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\n\nDownloading %s hindcasts (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin_hc = sprintf('%s/.%s/.HINDCAST/.MONTHLY/.sst/dods',dirin,mods{imod});           
            lon = ncread(fin_hc,'X');
            lat = ncread(fin_hc,'Y');
            time = ncread(fin_hc,'S');
            nt = length(time);
            nl = length(ncread(fin_hc,'L'));
            nm = length(ncread(fin_hc,'M'));
            for il = 1:nl        
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/hindcast/sst_%s_hindcast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin_hc,'sst',[1 1 im il tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end

            [~,~,~,hh,mm,~] = datevec(now);
            fprintf('\n\nDownloading %s forecasts (start time %d:%02d)\n',mods{imod},hh,mm)
            fprintf('\nProgress\n--------')
            fin_fc = sprintf('%s/.%s/.FORECAST/.MONTHLY/.sst/dods',dirin,mods{imod});
            lon = ncread(fin_fc,'X');
            lat = ncread(fin_fc,'Y');
            time = ncread(fin_fc,'S');
            nt = length(time);
            nl = length(ncread(fin_fc,'L'));
            nm = length(ncread(fin_fc,'M'));
            for il = 1:nl
                fprintf('\nlead %d, member',il-1)
                fout = sprintf('%s/forecast/sst_%s_forecast_l%d',dirout,mods{imod},il-1);

                % Loop through members
                for im = 1:nm

                    % Subset times
                    tstart = 1;
                    for tt = 1:ceil(nt/time_chunk)
                        tcount = min(time_chunk,nt-tstart+1);
                        isdone = 0;
                        while isdone == 0 % Loop to ensure download succeeds
                            try 
                                sst(:,:,im,tstart:tstart+tcount-1) = squeeze(ncread(fin_fc,'sst',[1 1 im il tstart],[Inf Inf 1 1 tcount]));
                                tstart = tstart + tcount;
                                isdone = 1;
                            catch
                                fprintf(' x')
                            end                    
                        end
                    end
                    fprintf(' %d',im)
                end
                save(fout,'-v7.3','lon','lat','time','sst')
                clear sst
            end        
    end
end
fprintf('\nDONE\n\n')