FROM python:3.11-slim

# Install system compilation tools and FFmpeg 7 development libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    ffmpeg \
    libavformat-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavutil-dev \
    libavfilter-dev \
    libswscale-dev \
    libswresample-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency structures and install Python wheels
COPY requirements/ ./requirements/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ./requirements/_requirements.txt

# Copy the rest of your repository code
COPY . .

# Install the CLI package needed to spin up the server
RUN pip install --no-cache-dir inference-cli

# Expose Roboflow's default local inference server port
EXPOSE 9001

# Start the dev server
CMD ["inference", "server", "start", "--dev"]
