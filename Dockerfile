ARG VERSION=3.9
FROM python:$VERSION-alpine as builder

# Setup
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
ENV USER=docker
ENV UID=1000    
ENV GID=1000
ENV HOME=/home/$USER
ENV PATH=$home/.local/bin:$PATH

# Create uid, gid and set home
RUN addgroup -g $GID -S $USER && \
    adduser -u $UID -S $USER -G $USER -h $HOME

# OS Dependencies
RUN apk update && apk upgrade
RUN apk add gcc musl-dev libc-dev libc6-compat \ 
    linux-headers build-base git libffi-dev openssl-dev iputils 

# Create Python env with dependencies 
COPY --chown=$UID:$GID . $HOME/app/
WORKDIR $HOME
USER $USER
RUN python -m venv venv
RUN ./venv/bin/python -m pip install --upgrade pip setuptools wheel
RUN ./venv/bin/pip install -r $HOME/app/requirements.txt

EXPOSE 5500
ENTRYPOINT ["./venv/bin/python", "app/main.py"]   