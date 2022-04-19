# MHW_Forecasts

Code used to create forecasts in Jacox et al. (2022), Global Seasonal Forecasts of Marine Heatwaves, Nature, doi:10.1038/s41586-022-04573-9.

MHW forecasts are calculated using monthly sea surface temperature output from the North American Multimodel Ensemble. Steps in the workflow, with associated matlab scripts, are:
  
  
## 1. Download NMME forecasts
Download SST forecasts from the North American Multimodel Ensemble using OPeNDAP. Saves file organized by lead time for use in subsequent analyses.

Script called:  
download_nmme_forecasts.m

Data generated:  
Hindcast and forecast SST organized by lead time
  
  
## 2. Concatenate hindcasts and forecasts
Join hindcasts and forecasts to a single dataset for each model
Keeps same number of forecast ensemble members as used for hindcast
Applies hindcast land mask to forecasts
Converts units from K to C where needed

Script called:  
concatenate_nmme_forecasts.m

Data generated:  
Concatenated forecasts organized by lead time
  
  
## 3. Calculate model ensemble means
Calculate ensemble means for each model from concatenated hindcast/forecast output

Script called:  
calc_nmme_ensemble_means.m

Data generated:  
Ensemble means for each model
  
  
## 4. Calculate model ensemble mean climatologies
Calculate climatologies from ensemble means of concatenated hindcast/forecast output

Script called:  
calc_nmme_climatology.m

Data generated:  
Climatologies for each model
  
  
## 5. Calculate forecast anomalies
Calculate SST anomalies from SST forecasts and lead-dependent monthly climatologies

Script called:  
calc_nmme_anomalies.m

Data generated:  
Concatenated forecast anomalies organized by lead time for each model
  
  
## 6. Detrend forecast anomalies
Remove linear trends from forecast anomalies. Subsequent steps are performed using forecast with trends removed as well as with trends retained.

Script called:  
detrend_nmme_anomalies.m

Data generated:  
Detrended forecast anomalies organized by lead time for each model
  
  
## 7. Calculate MHW thresholds and identify MHWs
Calculate seasonally-varying 90th percentile SST anomaly thresholds and use them to define forecast MHWs

Script called:  
calc_nmme_mhw.m

Data generated:  
Forecast MHWs organized by lead time for each model, with and without detrending
  
  
## 8. Create multimodel ensemble MHW forecasts
Combine MHW forecasts from individual models into a multimodel ensemble

Scripts called:  
nmme_ensemble_mhw.m

Data generated:  
Multimodel ensemble forecast MHWs organized by lead time, with and without detrending
