# Stage 1: build
FROM ghcr.io/bento-platform/bento_base_image:nuitka-alpine-latest as builder

RUN mkdir /workspace
WORKDIR /workspace

ARG TAG
RUN git clone https://github.com/bento-platform/bento_service_registry --depth 1 -b $TAG
WORKDIR /workspace/bento_service_registry

# - custom waitress wsgi "wrapper"
ADD ./waitress_wrapper.py /workspace/bento_service_registry/

# install service-registry dependencies
RUN pip install -r requirements.txt

# # compile to C intermediary file, then binary
WORKDIR /workspace
RUN pwd && ls -lah
RUN python3 -m nuitka \
    --include-package-data=bento_lib \
    --include-package-data=bento_service_registry \
    --onefile --follow-imports \
    -o /workspace/service_registry.bin \
    /workspace/bento_service_registry/waitress_wrapper.py
    # --include-data-files=./bento_service_registry/bento_service_registry/package.cfg=./bento_service_registry/bento_service_registry/ \



# Stage 2: deploy
FROM docker.io/alpine:latest as deployment

# Copy pre-built executables
COPY --from=builder /workspace/service_registry.bin /service_registry.bin

RUN chmod 700 /service_registry.bin

CMD [ "/service_registry.bin" ]