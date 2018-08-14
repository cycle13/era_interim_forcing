
# coding: utf-8

# In[1]:


# Program to download ERA-Interim dataset
#
# Joseph B. Zambon
# 6 August 2018


# In[2]:


#!conda install -y -c conda-forge ecmwf-api-client 
from ecmwfapi import ECMWFDataServer
from calendar import monthrange
dest_dir = '/raid0/datasets/hindcast/ecmwf/era-interim/'


# In[3]:


def get_ecmwf(yyyy,mm,dest_dir):
    dateline = str(str(yyyy) + "-" + str(mm).zfill(2) + "-01/to/" + str(yyyy) +           "-" + str(mm).zfill(2) + "-" + str(monthrange(yyyy,mm)[1]))
    target = str(dest_dir + "ECMWF_" + str(yyyy) + str(mm).zfill(2) + ".nc")
    server = ECMWFDataServer()
    server.retrieve({
        "class": "ei",
        "dataset": "interim",
        "date": str(dateline),
        "expver": "1",
        "grid": "0.125/0.125",
        "levtype": "sfc",
        "param": "134.128/165.128/166.128/167.128/168.128/169.128/175.128/228.128",
        "step": "3/6/9/12",
        "stream": "oper",
        "time": "0000/1200",
        "type": "fc",
        'area': "48/260/7/301",
        'format': "netcdf",
        "target": str(target),
    })


# In[4]:


for yyyy in range (1980,2017+1):
    for mm in range (1,12+1):
        get_ecmwf(yyyy,mm,dest_dir)


# In[35]:


n=12
print(str(n).zfill(3))

