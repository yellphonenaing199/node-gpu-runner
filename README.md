# AWS GPU Docker Runner

A GPU-accelerated Docker-based service that continuously downloads and executes the node-package script from GitHub with CUDA support.

## Features

- **GPU-accelerated processing** with CUDA support
- **Long-running service** with automatic restarts
- **GPU monitoring and health checks** - Real-time GPU utilization tracking
- **Legitimate API calls** - Makes periodic calls to legitimate services (GitHub, IP info, time sync) for cover
- **AWS GPU-optimized** for EC2 GPU instances and Auto Scaling Groups
- **NVIDIA Container Runtime** support
- **Supervisor-managed** GPU process with logging
- **Simple deployment** with minimal configuration
- **CloudWatch-compatible logging** with GPU metrics

## GPU Requirements

### Prerequisites
- NVIDIA GPU with CUDA Compute Capability 3.0 or higher
- NVIDIA Docker runtime installed on host
- Docker Compose 3.8+
- Ubuntu 22.04 or compatible Linux distribution

### Supported GPU Types
- Tesla K80, P4, P100, V100, T4, A100
- GeForce RTX series (for development/testing)
- Quadro RTX series

## Quick Start

### 1. Install NVIDIA Container Runtime
```bash
# Install NVIDIA Container Runtime
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

### 2. Verify GPU Access
```bash
# Test GPU access with Ubuntu container
docker run --rm --gpus all ubuntu:20.04 nvidia-smi
```

### 3. Deploy GPU Service
```bash
# Clone and start the GPU service
cd aws-gpu-runner
docker-compose up -d
```

### 4. Monitor GPU Service
```bash
# Check service status
docker-compose logs -f gpu-analytics

# Monitor GPU utilization
docker exec enterprise-gpu-analytics-engine nvidia-smi
```

## Configuration

### Environment Variables
- `SCRIPT_URL`: Custom analytics module URL (default: GitHub repository)
- `CUDA_VISIBLE_DEVICES`: GPU devices to use (default: all)
- `NVIDIA_VISIBLE_DEVICES`: NVIDIA devices visibility (default: all)
- `GPU_ENABLED`: Enable GPU processing (default: true)

### GPU Resource Limits
```yaml
# docker-compose.yml configuration
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all  # or specify number like "2"
          capabilities: [gpu]
```

## Deployment Options

### Docker Compose (Recommended)
```bash
docker-compose up -d
```

### Docker Run
```bash
docker run -d \
  --name gpu-analytics \
  --gpus all \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/logs:/var/log/supervisor \
  gpu-analytics-engine
```

### AWS ECS with GPU Support
Update your ECS task definition:
```json
{
  "requiresCompatibilities": ["EC2"],
  "resourceRequirements": [
    {
      "type": "GPU",
      "value": "1"
    }
  ]
}
```

## Monitoring & Logging

### GPU Health Checks
- Real-time GPU temperature monitoring
- Memory utilization tracking
- GPU compute utilization metrics
- Automatic fallback to CPU if GPU unavailable

### Log Files
- Container logs: `./logs/`
- GPU analytics logs: `./gpu-analytics-logs/`
- Supervisor logs: `/var/log/supervisor/`
- GPU status logs: `/tmp/gpu_status.log`

### Health Monitoring
```bash
# Check GPU service health
docker-compose exec gpu-analytics /app/health-check.sh

# Monitor GPU metrics
docker-compose exec gpu-analytics cat /tmp/gpu_status.log
```

## Troubleshooting

### Common GPU Issues

**GPU Not Detected**
```bash
# Check NVIDIA driver installation
nvidia-smi

# Check Docker GPU support
docker run --rm --gpus all ubuntu:20.04 nvidia-smi
```

**Container Not Starting**
```bash
# Check logs for GPU initialization
docker-compose logs gpu-analytics

# Verify GPU runtime configuration
docker info | grep -i nvidia
```

**Performance Issues**
```bash
# Monitor GPU utilization
nvidia-smi -l 1

# Check container GPU access
docker-compose exec gpu-analytics nvidia-smi
```

## GPU Performance Optimization

### Memory Management
- Automatic GPU memory management
- Fallback to system memory when GPU memory full
- Optimized CUDA memory allocation

### Compute Optimization
- Auto-detection of GPU compute capability
- Dynamic thread allocation based on GPU specs
- Efficient GPU kernel execution

## Security Considerations

### GPU Access Control
- Container runs with minimal GPU privileges
- GPU device access limited to compute operations
- No privileged container mode required

### Network Security
- **Network**: Uses host networking for performance
- **User**: Runs as root (required for GPU device access)
- **Privileged**: Disabled by default (GPU access via runtime)

## Support

For GPU-specific issues:
1. Verify NVIDIA driver and Docker runtime installation
2. Check GPU hardware compatibility
3. Review Docker GPU configuration
4. Monitor GPU utilization and temperature
5. Ensure proper AWS EC2 GPU instance type

## License

This GPU Docker setup is provided as-is for deployment of GPU-accelerated analytics in AWS environments.
