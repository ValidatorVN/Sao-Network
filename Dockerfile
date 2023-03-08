# Use the official Golang image as the base image
FROM golang:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    make \
    jq \
    gcc \
    snapd \
    chrony \
    lz4 \
    tmux \
    unzip \
    bc

# Clone the repository and switch to the desired branch
RUN git clone https://github.com/SaoNetwork/sao-consensus.git && \
    cd sao-consensus && \
    git checkout testnet0

# Build and install the project
RUN cd sao-consensus && \
    make && \
    make install
WORKDIR /app
# RUN cd /app
# Set the default command to start the application
COPY script.sh script.sh
RUN chmod +x script.sh
CMD ./script.sh