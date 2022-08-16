# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# This file is included in the final Docker image and SHOULD be overridden when
# deploying the image to prod. Settings configured here are intended for use in local
# development environments. Also note that superset_config_docker.py is imported
# as a final step as a means to override "defaults" configured here
#

import logging
import os
from datetime import timedelta
from typing import Optional

from cachelib.file import FileSystemCache
from celery.schedules import crontab

logger = logging.getLogger()


def get_env_variable(var_name: str, default: Optional[str] = None) -> str:
    """Get the environment variable or raise exception."""
    try:
        return os.environ[var_name]
    except KeyError:
        if default is not None:
            return default
        else:
            error_msg = "The environment variable {} was missing, abort...".format(
                var_name
            )
            raise EnvironmentError(error_msg)

## Reference: https://github.com/apache/superset/blob/master/superset/config.py

DATABASE_DIALECT = get_env_variable("DATABASE_DIALECT")
DATABASE_USER = get_env_variable("DATABASE_USER")
DATABASE_PASSWORD = get_env_variable("DATABASE_PASSWORD")
DATABASE_HOST = get_env_variable("DATABASE_HOST")
DATABASE_PORT = get_env_variable("DATABASE_PORT")
DATABASE_DB = get_env_variable("DATABASE_DB")

# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = "%s://%s:%s@%s:%s/%s" % (
    DATABASE_DIALECT,
    DATABASE_USER,
    DATABASE_PASSWORD,
    DATABASE_HOST,
    DATABASE_PORT,
    DATABASE_DB,
)

REDIS_HOST = get_env_variable("REDIS_HOST")
REDIS_PORT = 6379
REDIS_CELERY_DB = "0"
REDIS_RESULTS_DB = "1"
RESULTS_BACKEND = FileSystemCache("/app/superset_home/sqllab")

class CeleryConfig(object):
    BROKER_URL = "sqs://"
    BROKER_TRANSPORT_OPTIONS = {'region': 'ap-northeast-1'}
    CELERY_IMPORTS = ("superset.sql_lab",)
    CELERY_RESULT_BACKEND = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_RESULTS_DB}"
    CELERYD_LOG_LEVEL = "DEBUG"
    CELERYD_PREFETCH_MULTIPLIER = 1
    CELERY_ACKS_LATE = False
    CELERYBEAT_SCHEDULE = {
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
        "reports.prune_log": {
            "task": "reports.prune_log",
            "schedule": crontab(minute=10, hour=0),
        },
    }


CELERY_CONFIG = CeleryConfig

FEATURE_FLAGS = {"ALERT_REPORTS": True}
ALERT_REPORTS_NOTIFICATION_DRY_RUN = True
WEBDRIVER_BASEURL = os.environ.get('WEBDRIVER_BASEURL')
# The base URL for the email report hyperlinks.
WEBDRIVER_BASEURL_USER_FRIENDLY = WEBDRIVER_BASEURL
SQLLAB_CTAS_NO_LIMIT = True
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY')


DATA_CACHE_CONFIG = {
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 3600,
    # "CACHE_DEFAULT_TIMEOUT": 86400,  # 60 seconds * 60 minutes * 24 hours
    # "CACHE_KEY_PREFIX": "superset_results",  # make sure this string is unique to avoid collisions
    # 'CACHE_REDIS_HOST': os.environ.get('SUPERSET_CACHE_REDIS_HOST'),
    # 'CACHE_REDIS_PORT': os.environ.get('SUPERSET_CACHE_REDIS_PORT', 6379),
    # 'CACHE_REDIS_DB': os.environ.get('SUPERSET_CACHE_REDIS_DB', 0)
}

FILTER_STATE_CACHE_CONFIG = {
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 3600,
    # "CACHE_DEFAULT_TIMEOUT": 86400,  # 60 seconds * 60 minutes * 24 hours
    # "CACHE_KEY_PREFIX": "superset_results",  # make sure this string is unique to avoid collisions
    # 'CACHE_REDIS_HOST': os.environ.get('SUPERSET_CACHE_REDIS_HOST'),
    # 'CACHE_REDIS_PORT': os.environ.get('SUPERSET_CACHE_REDIS_PORT', 6379),
    # 'CACHE_REDIS_DB': os.environ.get('SUPERSET_CACHE_REDIS_DB', 1)
}
EXPLORE_FORM_DATA_CACHE_CONFIG = {
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 3600,
    # "CACHE_DEFAULT_TIMEOUT": 86400,  # 60 seconds * 60 minutes * 24 hours
    # "CACHE_KEY_PREFIX": "superset_results",  # make sure this string is unique to avoid collisions
    # 'CACHE_REDIS_HOST': os.environ.get('SUPERSET_CACHE_REDIS_HOST'),
    # 'CACHE_REDIS_PORT': os.environ.get('SUPERSET_CACHE_REDIS_PORT', 6379),
    # 'CACHE_REDIS_DB': os.environ.get('SUPERSET_CACHE_REDIS_DB', 0)
}


## Notification 
## Ref:
## - https://github.com/apache/superset/blob/master/superset/config.py#L957
## - https://superset.apache.org/docs/installation/alerts-reports#alerts-and-reports

###  Slack configuration
# SLACK_API_TOKEN = os.environ.get('SUPERSET_NOTIFICAITON_SLACK_API_TOKEN', '')

### Email configuration
# SMTP_HOST = os.environ.get('SUPERSET_NOTIFICATION_SMTP_HOST', '')
# SMTP_STARTTLS = os.environ.get('SUPERSET_NOTIFICATION_SMTP_STARTTLS', True)
# SMTP_SSL = os.environ.get('SUPERSET_NOTIFICATION_SMTP_SSL', False)
# SMTP_USER = os.environ.get('SUPERSET_NOTIFICATION_SMTP_USER', "your_user")
# SMTP_PORT = os.environ.get('SUPERSET_NOTIFICATION_SMTP_PORT', 2525)
# SMTP_PASSWORD = os.environ.get('SUPERSET_NOTIFICATION_SMTP_PASSWORD', "your_password")
# SMTP_MAIL_FROM = os.environ.get('SUPERSET_NOTIFICATION_SMTP_MAIL_FROM', "noreply@youremail.com")

#
# Optionally import superset_config_docker.py (which will have been included on
# the PYTHONPATH) in order to allow for local settings to be overridden
#
try:
    import superset_config_docker
    from superset_config_docker import *  # noqa

    logger.info(
        f"Loaded your Docker configuration at " f"[{superset_config_docker.__file__}]"
    )
except ImportError:
    logger.info("Using default Docker config...")