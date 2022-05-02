FROM ubuntu:18.04

MAINTAINER jeremy.ellman@northumbria.ac.uk

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
	 apt-get -y install --no-install-recommends openjdk-8-jre-headless \
	 ca-certificates-java  wget tar bash zip unzip nano && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Spark dependencies
#ENV APACHE_SPARK_VERSION=3.2.1 \
#    HADOOP_VERSION=2.7

RUN wget --quiet https://downloads.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz  &&\
    mkdir -p /usr/local/spark && tar -xzf spark-3.2.1-bin-hadoop3.2.tgz && \
    mv spark-3.2.1-bin-hadoop3.2 /usr/local/spark && \
    rm spark-3.2.1-bin-hadoop3.2.tgz 

ENV SPARK_HOME=/usr/local/spark/spark-3.2.1-bin-hadoop3.2
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=ERROR" 

# Install Miniconda3 &  clean up
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    apt-get autoremove  && \
    echo 'export PATH=/opt/conda/bin:$PATH' >> /etc/profile.d/conda.sh 

ENV PATH=/opt/conda/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Install Jupyter, Pandas, Scikit-learn, numpy
RUN /opt/conda/bin/conda install -q -y --quiet --yes \
    nomkl \
    numpy jupyter pandas \
    scikit-learn matplotlib \
    seaborn statsmodels && \
    /opt/conda/bin/conda clean --yes --all && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete 
#    find /opt/conda/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete

RUN /opt/conda/bin/conda install -q -y -c conda-forge --quiet --yes \
    pyspark pyarrow  rise jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator jupyterthemes azure-storage-blob awscliv2 pandoc


#To avoid warnings from nbextensions
#
RUN conda install -q -y -c conda-forge --quiet --yes nbconvert==5.6.1

# Create a group and user
# Tell docker that all future commands should run as the notebookuser user

RUN useradd -ms /bin/bash notebookuser && \
    mkdir -p /home/notebookuser && \
    mkdir -p /home/notebookuser/.jupyter && \
    chown -R notebookuser:notebookuser /home/notebookuser
RUN jupyter nbextensions_configurator enable --user

VOLUME /home/notebookuser
WORKDIR /home/notebookuser

USER notebookuser
RUN jupyter-notebook --generate-config 
# Add config with hashed password to image
COPY jupyter_notebook_config.py /home/notebookuser/.jupyter/jupyter_notebook_config.py

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]


