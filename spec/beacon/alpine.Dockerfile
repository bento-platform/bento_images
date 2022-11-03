# Stage 1: build
FROM ghcr.io/bento-platform/bento_base_image:nuitka-alpine-latest as builder

RUN mkdir /workspace
WORKDIR /workspace

# - custom waitress wsgi "wrapper"
ADD ./spec/beacon/waitress_wrapper.py .

# TODO: implement ARGS
ARG TAG
RUN git clone https://github.com/bento-platform/bento_beacon --depth 1 -b $TAG
WORKDIR /workspace/bento_beacon

# install bento-beacon dependencies
RUN pip install -r requirements.txt

# # compile to C intermediary file, then binary
WORKDIR /workspace
RUN python3 -m nuitka --onefile --follow-imports waitress_wrapper.py
# outputs ./app.bin



# Stage 2: deploy
FROM docker.io/alpine:latest as deployment

# Copy pre-built executables
COPY --from=builder /workspace/waitress_wrapper.bin /waitress_wrapper.bin
RUN chmod 700 /waitress_wrapper.bin

ENTRYPOINT [ "/waitress_wrapper.bin" ]