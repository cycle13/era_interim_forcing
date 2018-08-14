# era_interim_forcing

Programs to download and convert ERA-Interim data for ROMS use.

get_era_interim.py/ipynb program will download and store ERA-Interim to directory defined by dest_dir
Before downloading, you need to get an API key and save it to ~/.ecmwfapirc.
See documentation here: https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets

annual_forcing.m will convert this data from monthly to annual data.



