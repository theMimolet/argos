# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/aurora:stable

COPY --from=ctx /build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && \
    /tmp/build.sh && \
    rpm-ostree initramfs --enable && \
    rm /tmp/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
