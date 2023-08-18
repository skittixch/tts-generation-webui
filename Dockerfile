# Python 3.10 w/ Nvidia Cuda
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS env_base

# Install Pre-reqs
RUN apt-get update && apt-get install --no-install-recommends -y \
    git vim nano build-essential python3-dev python3-venv python3-pip gcc g++ ffmpeg

# Setup venv
RUN pip3 install virtualenv
RUN virtualenv /venv
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install --upgrade pip setuptools && \
    pip3 install torch torchvision torchaudio

# Set working directory
WORKDIR /app

# Clone the repo
RUN git clone https://github.com/skittixch/tts-generation-webui.git

# Set working directory to the cloned repo
WORKDIR /app/tts-generation-webui

# Install all requirements
RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements_audiocraft.txt
RUN pip3 install -r requirements_bark_hubert_quantizer.txt
RUN pip3 install -r requirements_rvc.txt

# Adding .env settings
ENV USER=$USER
ENV DOMAIN=$DOMAIN

# Run the server
CMD ssh -f -N -R 5001:127.0.0.1:7860 ${USER}@${DOMAIN} -i ~/.ssh/id_rsa \
    && python server.py
