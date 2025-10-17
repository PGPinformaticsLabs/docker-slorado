FROM rocm/pytorch:rocm6.1.3_ubuntu22.04_py3.10_pytorch_release-2.1.2 AS build

WORKDIR /root
RUN git clone --recursive https://github.com/BonsonW/slorado

WORKDIR /root/slorado
RUN git checkout -b build 30092a0423380c580fb3383c87bc427c5ffa2cfc \
    && git submodule update
RUN make rocm=1 ROCM_ARCH=--offload-arch=gfx1100 LIBTORCH_DIR=/opt/conda/envs/py_3.10/lib/python3.10/site-packages/torch flash=0 cxx11_abi=1 -j
RUN strip slorado; exit 0
RUN find /opt/rocm/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/rocm/magma/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/amdgpu/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/conda/envs/py_3.10/lib -name '*.so*' -type f -execdir strip '{}' ';'; exit 0
RUN find /opt/rocm/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0
RUN find /opt/rocm/magma/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0
RUN find /opt/amdgpu/lib -name '*.a*' -type f -execdir rm '{}' ';'; exit 0
RUN find /opt/conda/envs/py_3.10/lib -name '*.a' -type f -execdir rm '{}' ';'; exit 0

FROM ubuntu:jammy-20251001
COPY --from=build --exclude=*.a /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=build --exclude=*.a /etc/alternatives/libblas* /etc/alternatives/
COPY --from=build --exclude=*.a /etc/alternatives/liblapack* /etc/alternatives/
COPY --from=build --exclude=*.a /usr/lib/x86_64-linux-gnu/openblas-pthread /usr/lib/x86_64-linux-gnu/
COPY --from=build /opt/rocm/lib /opt/rocm/lib
COPY --from=build /opt/rocm/share /opt/rocm/share
COPY --from=build /opt/rocm/magma/lib /opt/rocm/magma/lib
COPY --from=build /opt/amdgpu/lib /opt/amdgpu/lib
COPY --from=build /opt/conda/envs/py_3.10/lib /usr/local/lib
COPY --from=build /root/slorado/slorado /usr/local/bin/slorado
COPY --from=build /usr/share/libdrm /usr/share/libdrm
RUN ldconfig /opt/rocm/lib /opt/rocm/magma/lib /opt/amdgpu/lib /usr/local/lib /usr/local/lib/python3.10/site-packages/torch/lib
