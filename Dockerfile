# Enterprise GPU Data Processing Service Container
# NVIDIA CUDA-enabled container for GPU-accelerated business analytics and mining services
FROM nvidia/cuda:13.0.0-runtime-ubuntu22.04

# Set environment variables for GPU business application
ENV DEBIAN_FRONTEND=noninteractive
ENV SERVICE_NAME=gpu-analytics-service
ENV COMPANY_ENV=production
ENV DATA_PROCESSING_MODE=gpu-accelerated
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install required GPU business application dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    supervisor \
    procps \
    htop \
    ca-certificates \
    build-essential \
    cmake \
    git \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Create GPU business application directories
RUN mkdir -p /app /var/log/supervisor /opt/gpu-business-data /opt/gpu-reports

# Copy GPU business service configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-service.sh /app/gpu-analytics-engine.sh

# Set appropriate permissions for GPU business services
RUN chmod +x /app/gpu-analytics-engine.sh

# Create GPU business service health monitoring script
RUN echo '#!/bin/bash\nif pgrep -f "gpu-analytics-engine.sh" > /dev/null; then\n  echo "GPU Business Analytics Service is operational"\n  exit 0\nfi\necho "GPU Business Analytics Service is offline"\nexit 1' > /app/health-check.sh && \
    chmod +x /app/health-check.sh

# Configure GPU business environment variables
ENV ANALYTICS_ENABLED=true
ENV GPU_ENABLED=true
ENV REPORTING_INTERVAL=300
ENV DATA_RETENTION_DAYS=30
ENV CUDA_VISIBLE_DEVICES=all

# Container resource configuration - full GPU access
# GPU runtime will be configured via docker-compose

# Expose standard GPU business application port
EXPOSE 8080

# Add GPU health monitoring for business continuity
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/health-check.sh

# Set GPU business application working directory
WORKDIR /app

# Start enterprise GPU business analytics service
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
