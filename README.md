# era_interim_forcing

Programs to download and convert ERA-Interim data for ROMS use.\n

get_era_interim.py/ipynb program will download and store ERA-Interim to directory defined by dest_dir\n
Before downloading, you need to get an API key and save it to ~/.ecmwfapirc.\n
See documentation here: https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets\n

annual_forcing.m will convert this data from monthly to annual data.\n



