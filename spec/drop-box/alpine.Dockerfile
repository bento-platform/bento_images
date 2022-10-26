# Stage 1: build
FROM ghcr.io/bento-platform/bento_base_image:nuitka-alpine-latest as builder

RUN mkdir /workspace
WORKDIR /workspace

# TODO: implement ARGS
RUN git clone https://github.com/bento-platform/bento_drop_box_service --depth 1 -b v0.5.0
WORKDIR /workspace/bento_drop_box_service

# - custom waitress wsgi "wrapper"
ADD ./spec/drop-box/waitress_wrapper.py /workspace/bento_drop_box_service/

# install bento-beacon dependencies
RUN pip install -r requirements.txt

# # compile to C intermediary file, then binary
# WORKDIR /workspace
RUN python3 -m nuitka \
    --include-package-data=bento_lib \
    --include-package-data=bento_drop_box_service \
    --onefile --follow-imports \
    -o /workspace/drop_box.bin \
    /workspace/bento_drop_box_service/waitress_wrapper.py
# outputs ./app.bin
    # --include-data-files=./bento_drop_box_service/package.cfg=./bento_drop_box_service/bento_drop_box_service/ \


# Stage 2: deploy
FROM docker.io/alpine:latest as deployment

# Copy pre-built executables
COPY --from=builder /workspace/drop_box.bin /drop_box.bin

RUN chmod 700 /drop_box.bin

CMD [ "/drop_box.bin" ]