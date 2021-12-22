FROM jupyter/minimal-notebook:2021-12-21

# Set user
USER $NB_USER

# Set environment variables for TMC.
ENV TMC_DIR=/opt/tmc/
ENV TMC_CONFIG_DIR="${HOME}/tmc-config/tmc-tmc_cli_rust"
ENV WORK_DIR=/home/$NB_USER/my-work/

# Copy the requirements.txt file from pip to /opt/app
COPY requirements.txt /opt/app/requirements.txt

# Set working directory to /opt/tmc for tmc installation
WORKDIR /opt/tmc

# Switch to root and install G++
USER root

# Update package metadata and install Python
RUN apt update \
 && apt install -y g++ \
 && apt install python-pkg-resources \
 && apt install -y --no-install-recommends curl \
 && apt clean

# Install tmc-cli-rust
RUN curl -0 https://raw.githubusercontent.com/rage/tmc-cli-rust/main/scripts/install.sh | bash -s x86_64 linux \
 && chmod a+x /opt/tmc/tmc-cli-rust-*

# Set download location for exercises
RUN mkdir -p "${TMC_DIR}" \
 && mkdir -p "${TMC_CONFIG_DIR}" \
 && echo "projects-dir = '${WORK_DIR}'" > "${TMC_CONFIG_DIR}/config.toml" \
 && fix-permissions "${HOME}" \
 && fix-permissions "${TMC_DIR}"

USER $NB_USER

# Upgrade pip and setuptools; install libraries from requirements.txt;
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir --upgrade setuptools \
 && pip install --no-cache-dir wheel \
 && pip install --no-cache-dir -r /opt/app/requirements.txt

# Set starting directory for Jupyter
RUN sed -i "s|# c.NotebookApp.notebook_dir =.*|c.NotebookApp.notebook_dir = '${WORK_DIR}'|g" \
    /home/jovyan/.jupyter/jupyter_notebook_config.py

# Switch to root
USER root

# Set working directory to /opt/tmc
WORKDIR /opt/tmc

# Set home
ENV HOME /home/$NB_USER

# Copy start script for Jupyter
COPY scripts/jupyter/custom_start.sh /usr/local/bin/custom_start.sh
RUN chmod a+x /usr/local/bin/custom_start.sh

# Archive original home directory contents. These will be extracted to the home/session volume by custom_start.sh
RUN tar cvfz /opt/home_jovyan.tar.gz -C /home/jovyan .

# Change back to default user
USER $NB_USER

# Go back to student starting folder (e.g. the folder where you would also mount CSC Notebooks' persistent folder)
WORKDIR $WORK_DIR

# Run start script (this will be actually overwritten in Notebooks by Kubernetes)
CMD ["/usr/local/bin/custom_start.sh"]
