FROM rocm/pytorch:rocm7.0_ubuntu24.04_py3.12_pytorch_release_2.8.0

RUN DEBIAN_FRONTEND=noninteractive sudo apt update --quiet \
    && sudo apt install --yes --quiet --no-install-recommends wget unzip \
    && cd \
    && git clone --recursive https://github.com/BonsonW/slorado \
    && cd slorado \
    && make rocm=1 ROCM_ARCH=--offload-arch=gfx1100 LIBTORCH_DIR=/opt/venv/lib/python3.12/site-packages/torch cxx11_abi=1 -j

WORKDIR /root/slorado
