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

# Copy dependency files and install base + http server stacks
COPY requirements/ ./requirements/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ./requirements/_requirements.txt -r ./requirements/requirements.http.txt -r ./requirements/requirements.hosted.txt

# Install Uvicorn explicitly to act as the web gateway
RUN pip install --no-cache-dir uvicorn

# Copy the rest of the repository source code
COPY . .

# Inform Python to look into the current root directory for module imports
ENV PYTHONPATH=/app

# Expose Render's default routing port
ENV PORT=10000
EXPOSE 10000

# Silence the gaze model deprecation error if needed
ENV CORE_MODEL_GAZE_ENABLED=False

# Start Roboflow Inference's internal FastAPI app directly via Uvicorn
CMD ["uvicorn", "inference.core.api:app", "--host", "0.0.0.0", "--port", "10000"]
