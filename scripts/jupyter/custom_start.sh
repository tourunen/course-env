#!/usr/bin/env bash

# This script should be called in session startup. A custom application template is needed for this, although
# it can be shared with other application images following the same pattern.

# Copy installed content to new home volume
tar xvf /opt/home_jovyan.tar.gz -C /home/jovyan

# Move cloned git repo if it does not already exist in my-work. Adapt this as needed.
if [[ ! -d /home/jovyan/my-work/notebooks ]]; then
  mv /home/jovyan/notebooks /home/jovyan/my-work/
fi

# Become the normal startup process defined in the rest of application template 'args'
exec $*
