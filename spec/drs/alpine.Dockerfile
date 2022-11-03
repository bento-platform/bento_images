# Stage 1: build
FROM ghcr.io/bento-platform/bento_base_image:nuitka-alpine-latest as builder

RUN mkdir /workspace
WORKDIR /workspace

# TODO: implement ARGS
RUN git clone https://github.com/bento-platform/bento_drs --depth 1 -b v0.6.0
WORKDIR /workspace/bento_drs

# - custom waitress wsgi "wrapper"
ADD ./waitress_wrapper.py /workspace/bento_drs/

# install drs dependencies
RUN pip install --upgrade pip
RUN apk add --no-cache \
        libressl-dev \
        musl-dev \
        libffi-dev
RUN pip install -r /workspace/bento_drs/requirements.txt

# # compile to C intermediary file, then binary
# WORKDIR /workspace
RUN python3 -m nuitka \
    --include-package-data=bento_lib \
    --include-package-data=chord_drs \
    --include-package=sqlalchemy \
    --onefile --follow-imports \
    -o /workspace/drs.bin \
    /workspace/bento_drs/waitress_wrapper.py


# Stage 2: deploy
FROM docker.io/alpine:latest as deployment

# Copy pre-built executables
COPY --from=builder /workspace/drs.bin /drs.bin

RUN chmod 700 /drs.bin

CMD [ "/drs.bin" ]