FROM alpine:3.8

# Python 3 dependencies
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
 	pip3 install google-cloud-storage && \
 	pip3 install encode_utils==2.5.0 && \
    rm -r /root/.cache

# Cromwell needs bash
RUN apk add --no-cache bash

# Make directory for all softwares
RUN mkdir /software
WORKDIR /software
ENV PATH="/software:${PATH}"

COPY src pipeline_accessioning/src
RUN chmod +x pipeline_accessioning/src/*.py
ENV PATH="/software/pipeline_accessioning/src:${PATH}"