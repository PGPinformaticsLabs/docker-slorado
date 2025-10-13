FROM rocm/pytorch:rocm7.0_ubuntu24.04_py3.12_pytorch_release_2.8.0 AS build

WORKDIR /root
RUN git clone --recursive https://github.com/BonsonW/slorado

WORKDIR /root/slorado
RUN git checkout -b build f0e816bdd666340bbcaad90a454f4c0840adb319 \
    && git submodule update
RUN make rocm=1 ROCM_ARCH=--offload-arch=gfx1100 LIBTORCH_DIR=/opt/venv/lib/python3.12/site-packages/torch flash=1 cxx11_abi=1 -j
RUN strip slorado; exit 0
RUN find /opt/rocm/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/amdgpu/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/venv/lib/python3.12/site-packages/torch/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/rocm/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0
RUN find /opt/amdgpu/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0
RUN find /opt/venv/lib/python3.12/site-packages/torch/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0

FROM ubuntu:noble-20250925
COPY --from=build /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=build /opt/rocm/lib /opt/rocm/lib
COPY --from=build /opt/amdgpu/lib /opt/amdgpu/lib
COPY --from=build /opt/venv/lib/python3.12/site-packages/torch/lib/* /usr/local/lib/
COPY --from=build /root/slorado/slorado /usr/local/bin/slorado
COPY --from=build /usr/share/libdrm /usr/share/libdrm
RUN ldconfig /opt/rocm/lib /opt/amdgpu/lib /usr/local/lib
