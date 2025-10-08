FROM rocm/pytorch:rocm6.4.4_ubuntu22.04_py3.10_pytorch_release_2.7.1 

RUN DEBIAN_FRONTEND=noninteractive sudo apt update --quiet \
    && sudo apt upgrade --yes --quiet \
    && sudo apt install --yes --quiet --no-install-recommends wget unzip \
    && cd \
    && git clone --recursive https://github.com/BonsonW/slorado \
    && cd slorado \
    && make rocm=1 ROCM_ARCH=--offload-arch=gfx1100 LIBTORCH_DIR=/opt/conda/envs/py_3.10/lib/python3.10/site-packages/torch cxx11_abi=1 -j

WORKDIR /root/slorado
