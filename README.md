# ROCm Strix Docker

Minimal Docker image with ROCm PyTorch for AMD Strix Halo (RDNA 3.5 / gfx1151).

## Setup

```bash
# Get your GIDs
getent group video | cut -d: -f3
getent group render | cut -d: -f3

# Copy template and fill in
cp .env.template .env
# Edit .env with your GIDs
```

## Build & Run

```bash
docker compose up -d --build
docker logs rocm-strix
```

## Verify GPU

```bash
docker exec rocm-strix python -c "import torch; print(torch.cuda.get_device_name(0)); print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')"
```

## Requirements

- Ubuntu 25.04+ host (Kernel 6.12+)
- AMD Ryzen AI Max (Strix Halo)
- Docker with compose plugin
