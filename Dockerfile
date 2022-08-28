FROM apache/superset

# Switching to root to install the required packages
USER root

COPY local_requirements.txt .
RUN pip install -r local_requirements.txt

# Switching back to using the `superset` user
USER superset
COPY docker/ /app/docker/
ENV SUPERSET_CONFIG_PATH /app/docker/python_path/superset_config.py
