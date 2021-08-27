FROM duartej/eudaqv1:latest
LABEL author="jorge.duarte.campderros@cern.ch" \ 
    version="v1.6-plain" \ 
    description="Docker image to integrate the RD53A chip \
    using the bdaq53 readout system into EUDAQ"

# Be sure running as root
USER 0

# Place at the directory
WORKDIR /bdaq53

# Download minicoda (and recovering permissions)
RUN mkdir -p /bdaq53 \ 
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /bdaq53/miniconda.sh \
    && chown -R eudaquser:eudaquser /bdaq53 \  
    && chown -R eudaquser:eudaquser /eudaq 

# Initialization for the scan (TB) services
COPY scan_service_init.sh /usr/bin/scan_service_init.sh

# Change to user and conda installation
USER eudaquser
ENV HOME="/home/eudaquser"
ENV PATH="${PATH}:${HOME}/.local/bin:/bdaq53/miniconda/bin"
ENV PYTHONPATH="${HOME}/.local/lib:${PYTHONPATH}:/bdaq53/miniconda"
RUN cd /bdaq53 \ 
    && /bin/bash miniconda.sh -b -p /bdaq53/miniconda \ 
    && . activate \ 
    && conda update -y -n base conda \
    && conda install -y \ 
       pip \
       numpy \ 
       bitarray \ 
       pytest \ 
       pyyaml \ 
       scipy \ 
       numba \ 
       pytables \ 
       pyqt \
       matplotlib \ 
       tqdm \ 
       pyzmq \ 
       blosc \ 
       psutil \
       pexpect \
       coloredlogs \
       ptyprocess \
       gitpython \
       iminuit \
       lxml

# The bdaq53 software v.1.6
RUN . /bdaq53/miniconda/bin/activate \ 
    && git clone -b v1.6 https://gitlab.cern.ch/silab/bdaq53.git \
    && cd bdaq53 \ 
    && python setup.py develop

# Activate conda environment and (re-)install the bdaq53 direcotory 
# (case of bind-volumen mounted)
ENTRYPOINT ["/bin/bash", "-c","source /bdaq53/miniconda/bin/activate \ 
    && cd /bdaq53/bdaq53 && export PYTHONPATH=$PYTHONPATH:/bdaq53/bdaq53 \
    && python setup.py develop && /bin/bash"]
