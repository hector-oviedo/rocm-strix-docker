# ROCm Strix Docker

Docker infrastructure for AMD Strix Halo (RDNA 3.5 / gfx1151) with ROCm PyTorch and Ollama LLM support.

Two independent services, each in its own folder with its own `docker-compose.yml`:

- **`rocm/`** — Base container with PyTorch + ROCm for ML workloads
- **`ollama/`** — Ollama LLM inference server with GPU acceleration

## Project Structure

```
.
├── .gitignore                    # Ignores .env files (contain machine-specific values)
├── README.md                     # This file
├── llm.txt                       # Complete technical reference
├── rocm/                         # ROCm PyTorch container
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── entrypoint.sh
└── ollama/                       # Ollama LLM service
    ├── .env                      # Your local config (git-ignored)
    ├── .env.template             # Template to copy
    ├── Dockerfile
    ├── docker-compose.yml
    └── entrypoint.sh
```

## Prerequisites

- Ubuntu 25.04+ host (Kernel 6.12+)
- AMD Ryzen AI Max (Strix Halo)
- Docker with compose plugin

## Quick Start

### 1. ROCm Container

```bash
cd rocm
docker compose up -d --build
docker logs rocm-strix
```

No configuration needed — everything is hardcoded in the compose file.

**Verify GPU:**
```bash
docker exec rocm-strix python3 -c "import torch; print(torch.cuda.get_device_name(0)); print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')"
```

### 2. Ollama Service

```bash
cd ollama
cp .env.template .env
# Edit .env — set OLLAMA_MODELS_DIR to a host directory for model storage
mkdir -p /path/to/your/models/dir
docker compose up -d --build
docker logs ollama-strix
```

`OLLAMA_MODELS_DIR` points to a directory on your host machine. Models are stored there so they survive container rebuilds. Multiple ollama instances can share the same directory.

**Test inference:**
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "gpt-oss:20b",
  "prompt": "Hello!",
  "stream": false
}'
```

## Ollama Configuration

All configurable via `ollama/.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_MODELS_DIR` | — (required) | Host directory for shared model storage |
| `OLLAMA_MODEL` | `gpt-oss:20b` | Model to auto-download on first start |
| `OLLAMA_CONTEXT_LENGTH` | `8192` | Context window size in tokens |
| `OLLAMA_KEEP_ALIVE` | `5m` | How long models stay loaded in VRAM (`-1` = forever) |
