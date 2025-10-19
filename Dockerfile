ARG FROM_TAG=release
FROM ghcr.io/ponylang/ponyc:${FROM_TAG}

ARG PACKAGE

RUN apk add --update --no-cache \
  bash \
  libffi \
  libffi-dev \
  libressl \
  libressl-dev \
  make \
  python3 \
  python3-dev \
  py3-pip \
  tar

RUN pip3 install --upgrade --break-system-packages pip \
  gitpython \
  in_place \
  mkdocs \
  ${PACKAGE} \
  pylint \
  pyyaml

COPY entrypoint.py /entrypoint.py

ENTRYPOINT ["/entrypoint.py"]
