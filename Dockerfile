FROM python:3.11-slim

# Install compilation tools and ffmpeg development libraries
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

# Copy requirements
COPY requirements/ ./requirements/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ./requirements/_requirements.txt -r ./requirements/core.txt

# Install Uvicorn
RUN pip install --no-cache-dir uvicorn

# Copy the rest of the repository source code
COPY . .

# Set PYTHONPATH directly to /app so 'inference' can be parsed as a root module
ENV PYTHONPATH=/app

# Expose Render's default routing port
ENV PORT=10000
EXPOSE 10000

# 3. Turn off the deprecated gaze model flag to silence the deprecation warning
ENV CORE_MODEL_GAZE_ENABLED=False

# 4. Invoke Uvicorn using the top-level module syntax
CMD ["uvicorn", "inference.core.api:app", "--host", "0.0.0.0", "--port", "10000"]
