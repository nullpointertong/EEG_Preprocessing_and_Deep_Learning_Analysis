#!/usr/bin/env python
# coding: utf-8

# In[1]:


#Ignore if Libaries are already installed
get_ipython().system('pip install -U numpy --user')
get_ipython().system('pip install -U sklearn --user')
get_ipython().system('pip install -U torch --user')
get_ipython().system('pip install -U pandas --user')
get_ipython().system('pip install -U matplotlib --user')
get_ipython().system('pip install -U mne --user')


# In[13]:


# ignore most of these imports this notebook used to do sth else
import numpy as np

import pandas as pd

from matplotlib import pyplot

import mne
from mne.io import concatenate_raws, read_raw_fif
import mne.viz

from os import walk

# from concurrent.futures import ThreadPoolExecutor
# import multiprocessing as mp
# from threading import Thread 
# from multiprocessing import Pool


# In[14]:


# link to dataset: https://zenodo.org/record/197404#.X1Li7HlKiUl
# there are 27 participants in the trial, and each file name contains the ID of its participant
participant_prefix = ['{:02}_'.format(x) for x in range(1, 38)]
print(participant_prefix)


# In[15]:


files = []
# study1_eeg is a folder with a bunch of csv files, each file partaining to a different trial
path = 'EEG/'
for prefix in participant_prefix:
    for (dirpath, dirnames, filenames) in walk(path):
        # gets the file paths and adds them to a list
        new_names = [dirpath+f for f in filenames if (prefix in f)]
        files.extend(new_names)
        break


# In[16]:


tmp = np.loadtxt(files[0], delimiter=',', skiprows = 1, usecols=np.arange(1,13), dtype = np.float16)
# finds the number of channels from the shape of the file (channels X timepoints)

#TODO: Remove the resize
tmp = np.transpose(tmp)

#tmp = np.append(tmp, 200 * np.array([[]]), axis=0)
#tmp = np.resize(tmp,(256, tmp.shape[1]))

print(tmp.shape)
#print(tmp[200])
print(tmp)


# In[17]:


def loadFile(trial,participant_data):
     # each iteration loads data from a trial
    print(trial)
    new_data = np.loadtxt(files[trial], delimiter=',', skiprows = 1, usecols=np.arange(1,13), dtype = np.float16)
    new_data = np.transpose(new_data)
    new_data = np.resize(new_data,(n_channels,n_times))
    if trial == 0:
        # just reassuring again that is the right shape
        print('n_channels, n_times: ' + str(new_data.shape))
    #new_data = new_data.astype(float32)
    participant_data[trial] = new_data


# In[18]:


n_channels = tmp.shape[0]
n_times = tmp.shape[1]

# makes an array large enough to hold all of the data
arr = mp.Array('d', int(len(files)) * n_channels * n_times)
participant_data = np.frombuffer(arr.get_obj(), 'd')
participant_data = np.resize(participant_data,(int(len(files)), n_channels,n_times))
print(participant_data.shape)


for trial in range(0,len(files)):
    # each iteration loads data from a trial
    loadFile(trial,participant_data)
#     with Pool(processes=5) as pool:
#         pool.map(loadFile, (trial,participant_data)) 

print(participant_data[0])
print('Number of epochs: ' + str(participant_data.shape))


# In[19]:


# gets the ID of the events from the names of each file
epochs_events = []
for f in files:
    res = f.split('_')
    res[-1] = res[-1].split('.')
    epochs_events.append(res[-1][0])


# In[20]:


unique_events = list(set(epochs_events))
print(unique_events)
unique_events = sorted(unique_events)
print(unique_events)
unique_events_num = [i for i in range(len(unique_events))]

# formats a numpy array to work with the epochs object 
# format = (event #, prev event class, current event class)
epoch_events_num = np.ndarray((len(epochs_events),3),int)

for i in range(len(epochs_events)):
    for j in range(len(unique_events)):
        if epochs_events[i] == unique_events[j]:
            epoch_events_num[i,2] = unique_events_num[j]
            if i > 0:
                epoch_events_num[i,1] = epoch_events_num[i-1,2]
            else:
                epoch_events_num[i,1] = unique_events_num[j]
        epoch_events_num[i,0] = i
        
# associates each event with an index
event_id = {}
for i in range(len(unique_events)):
    event_id[unique_events[i]] = unique_events_num[i]


# In[21]:


get_ipython().run_line_magic('matplotlib', 'inline')

# data was taken with a biosemi eeg device, so biosemi64 is passed into the function
montage = mne.channels.make_standard_montage('GSN-HydroCel-256') 
print('Number of channels: ' + str(len(montage.ch_names)))
montage.plot(show_names=True)
n_channels = 256

# there are 64 channels in the cap but 67 in the montage, three are just there for
# reference (fiducial) and need to be removed
#fiducials = ['Nz', 'LPA', 'RPA']

#ch_names = montage.ch_names
ch_names = ['E86','E96','E97','E109','E116','E119','E126','E140','E150','E161','E162','E170']

#ch_names = [x for x in ch_names if x not in fiducials]
print('Number of channels after removing the fudicials: '+ str(len(ch_names)))
# Specify ampling rate
sfreq = 256  # Hz


# In[22]:


# creates an mne info instance with the different info we've collected
epochs_info = mne.create_info(ch_names, sfreq, ch_types='eeg')

# creates an mne epochs object with the info and the data
epochs = mne.EpochsArray(data=participant_data, info=epochs_info, events=epoch_events_num, event_id=event_id)
epochs.set_montage(montage)

# drops bad epochs, doesn't actually do anything rn
epochs.drop_bad()

epochs.info


# In[23]:


# save the epochs as a .fif
epochs.save('EEG/epochdata/master.fif', verbose='error', overwrite=True)


# In[24]:


# example of loading the data
data_file = 'EEG/epochdata/master.fif'

# Read the EEG epochs:
epochs = mne.read_epochs(data_file, verbose='error')
print(epochs)


# In[ ]:




