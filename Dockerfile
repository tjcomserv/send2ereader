# Use Debian instead of Alpine for better Python wheel compatibility
FROM node:lts-bookworm-slim

WORKDIR /usr/src/app

# Install system dependencies and 32-bit libraries for legacy kindlegen
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        python3 \
        pipx \
        libc6:i386 \
        libstdc++6:i386 && \
    rm -rf /var/lib/apt/lists/*

# Install kepubify
RUN wget https://github.com/pgaskin/kepubify/releases/download/v4.0.4/kepubify-linux-64bit \
    -O /usr/local/bin/kepubify && \
    chmod +x /usr/local/bin/kepubify

# Download and install kindlegen
RUN wget https://github.com/zzet/fp-docker/raw/f2b41fb0af6bb903afd0e429d5487acc62cb9df8/kindlegen_linux_2.6_i386_v2_9.tar.gz && \
    echo "9828db5a2c8970d487ada2caa91a3b6403210d5d183a7e3849b1b206ff042296 kindlegen_linux_2.6_i386_v2_9.tar.gz" | sha256sum -c && \
    mkdir kindlegen && \
    tar xzf kindlegen_linux_2.6_i386_v2_9.tar.gz --no-same-owner -C kindlegen && \
    cp kindlegen/kindlegen /usr/local/bin/kindlegen && \
    chmod +x /usr/local/bin/kindlegen && \
    rm -rf kindlegen kindlegen_linux_2.6_i386_v2_9.tar.gz

# Install PDF cropping dependency
ENV PATH="/root/.local/bin:${PATH}"
RUN pipx install pdfCropMargins

# Install Node dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy application
COPY . ./

RUN mkdir -p uploads

EXPOSE 3001
CMD ["npm", "start"]
