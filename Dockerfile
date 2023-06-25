# Global ARG for all stage
ARG REQUIREMENTS_PATH=./app/requirements.txt
ARG PORT_WEB_MIRROR=80
ARG PYTHON=python3.10

ARG GIT_PYTHON_REFRESH

# Base image at the start of the build
FROM ubuntu:22.04 AS builder-image
ARG REQUIREMENTS_PATH
ARG PYTHON

ENV PYTHON=${PYTHON}
ENV REQUIREMENTS_PATH=${REQUIREMENTS_PATH}
ENV APP_VIRTUAL_ENV=/home/app/venv
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/app/venv/bin:${PATH}"

RUN apt-get -o Acquire::Max-FutureTime=86400 update  && apt-get install --no-install-recommends -yq ${PYTHON}-dev ${PYTHON}-venv python3-pip python3-wheel build-essential && \
        apt-get clean && rm -rf /var/lib/apt/lists/*
# create and activate virtual environment
# using final folder name to avoid path issues with packages
RUN ${PYTHON} -m venv /home/app/venv
# RUN export PATH=$PATH:/home/app/venv/bin
# install requirements
COPY ${REQUIREMENTS_PATH} /requirements.txt
RUN pip3 install --no-cache-dir wheel && \
    pip3 install --no-cache-dir -r /requirements.txt

############################################# 2 STAGE #############################################
FROM ubuntu:22.04 AS runner-image
ARG REQUIREMENTS_PATH
ARG PORT_WEB_MIRROR
ARG PORT_WEB_EXPORTER
ARG PYTHON

ENV PYTHON=${PYTHON}
ENV REQUIREMENTS_PATH=$REQUIREMENTS_PATH
ENV PYTHONUNBUFFERED=1
ENV APP_VIRTUAL_ENV=$APP_VIRTUAL_ENV
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/app/venv/bin:${PATH}"
ENV PORT_WEB_MIRROR=$PORT_WEB_MIRROR
ENV UID=40000
ENV GID=40000
ENV GIT_PYTHON_REFRESH=${GIT_PYTHON_REFRESH}

ENV APP_WORKDIR=/usr/src/app

RUN apt-get -o Acquire::Max-FutureTime=86400 update && apt-get install -qq --no-install-recommends -y ${PYTHON} ${PYTHON}-venv libmagic1 git curl ca-certificates && \
        apt-get clean && rm -rf /var/lib/apt/lists/* && \
    groupadd -g ${GID} app-user && \
    useradd -u ${UID} -g ${GID} --create-home app-user

# migrating a python virtual environment from a base image
COPY --from=builder-image /home/app/venv /home/app/venv
RUN ${PYTHON} -m venv /home/app/venv

USER app-user
WORKDIR /${APP_WORKDIR}
COPY ./app /${APP_WORKDIR}/

EXPOSE $PORT_WEB_MIRROR
CMD ["python", "./app.py"]
