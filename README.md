# ROCm Strix Docker

Docker infrastructure for AMD Strix Halo (RDNA 3.5 / gfx1151) with ROCm PyTorch and Ollama support.

## Project Structure

```
.
├── .env                      # Environment variables (VIDEO_GID, RENDER_GID)
├── .env.template             # Template for environment variables
├── .gitignore                # Git ignore rules
├── Dockerfile                # Base ROCm PyTorch container
├── docker-compose.yml        # Docker Compose configuration
├── entrypoint.sh             # Base container entrypoint
├── llm.txt                   # Complete technical reference
├── ollama/                   # Ollama LLM service
│   ├── Dockerfile            # Ollama ROCm container
│   └── entrypoint.sh         # Ollama auto-model loader entrypoint
├── README.md                 # This file
└── workspace/                # Mounted volume for persistent data
```

## Quick Start

### 1. Get Your GIDs

```bash
getent group video | cut -d: -f3
getent group render | cut -d: -f3
```

### 2. Configure Environment

```bash
cp .env.template .env
# Edit .env with your numeric GIDs (NOT group names)
```

### 3. Build & Run

```bash
docker compose up -d --build
docker logs rocm-strix
```

## Services

### Base ROCm Container (`rocm-strix`)

Ubuntu Rolling + ROCm PyTorch for ML workloads.

**Verify GPU:**
```bash
docker exec rocm-strix python -c "import torch; print(torch.cuda.get_device_name(0)); print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')"
```

### Ollama Service (`ollama/`)

Ollama LLM inference with automatic model download.

**Features:**
- ROCm GPU acceleration
- Auto-download configured model on first start
- Default model: `gpt-oss:20b`

**Build & Run Ollama:**
```bash
cd ollama
docker build -t ollama-strix .
docker run -d --name ollama-strix \
  --privileged \
  --device /dev/kfd \
  --device /dev/dri \
  -p 11434:11434 \
  -e VIDEO_GID=44 \
  -e RENDER_GID=991 \
  -e HSA_OVERRIDE_GFX_VERSION=11.5.1 \
  -e HIP_VISIBLE_DEVICES=0 \
  ollama-strix
```

**API Usage:**
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "gpt-oss:20b",
  "prompt": "Hello!"
}'
```

## Requirements

- Ubuntu 25.04+ host (Kernel 6.12+)
- AMD Ryzen AI Max (Strix Halo)
- Docker with compose plugin

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VIDEO_GID` | Numeric GID of video group | `44` |
| `RENDER_GID` | Numeric GID of render group | `991` |
| `HSA_OVERRIDE_GFX_VERSION` | GPU architecture override | `11.5.1` |
| `HIP_VISIBLE_DEVICES` | Visible GPU devices | `0` |

## Notes

- Use **numeric GIDs** in `.env`, not group names (`video`, `render`)
- The `workspace/` folder is mounted at `/workspace` in the base container
- Ollama container exposes port `11434` for API access
