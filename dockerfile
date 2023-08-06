# Builds GPU docker image of PyTorch
# Uses multi-staged approach to reduce size
# Stage 1
# Use base conda image to reduce time
FROM continuumio/miniconda3:latest AS compile-image
# Specify py version
ENV PYTHON_VERSION=3.8
# Install apt libs - copied from https://github.com/huggingface/accelerate/blob/main/docker/accelerate-gpu/Dockerfile
RUN apt-get update && \
    apt-get install -y curl git wget software-properties-common git-lfs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

# Install audio-related libraries 
RUN apt-get update && \
    apt install -y ffmpeg

RUN apt install -y libsndfile1-dev
RUN git lfs install

# Create our conda env - copied from https://github.com/huggingface/accelerate/blob/main/docker/accelerate-gpu/Dockerfile
RUN conda create --name peft python=${PYTHON_VERSION} ipython jupyter pip
RUN python3 -m pip install --no-cache-dir --upgrade pip

# Below is copied from https://github.com/huggingface/accelerate/blob/main/docker/accelerate-gpu/Dockerfile
# We don't install pytorch here yet since CUDA isn't available
# instead we use the direct torch wheel
ENV PATH /opt/conda/envs/peft/bin:$PATH
# Activate our bash shell
RUN chsh -s /bin/bash
SHELL ["/bin/bash", "-c"]
# Activate the conda env and install transformers + accelerate from source
RUN source activate peft && \
    python3 -m pip install --no-cache-dir \
    librosa \
    "soundfile>=0.12.1" \
    scipy \
    git+https://github.com/huggingface/transformers \
    git+https://github.com/huggingface/accelerate \
    peft[test]@git+https://github.com/huggingface/peft

RUN python3 -m pip install --no-cache-dir bitsandbytes

# Stage 2
FROM nvidia/cuda:11.3.1-devel-ubuntu20.04 AS build-image
COPY --from=compile-image /opt/conda /opt/conda
ENV PATH /opt/conda/bin:$PATH

# Install apt libs
RUN apt-get update && \
    apt-get install -y curl git wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

RUN echo "source activate peft" >> ~/.profile

COPY config/ $PIP_CONF
RUN pip install -r ${PIP_CONF}/requirements.txt
RUN pip install -I git+https://github.com/huggingface/peft