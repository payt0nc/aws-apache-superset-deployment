FROM apache/superset

# Switching to root to install the required packages
USER root

COPY local_requirements.txt .
RUN pip install -r local_requirements.txt

COPY local_requirements.txt .
RUN pip install -r local_requirements.txt

# Switching back to using the `superset` user
USER superset

COPY pythonpath/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

COPY docker/ /app/docker/