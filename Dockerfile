FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_CACHE_DIR=/root/.cache/uv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV HSA_OVERRIDE_GFX_VERSION=11.5.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    libgl1 libglib2.0-0 libgomp1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

RUN uv venv .venv --python 3.12 && \
    uv pip install --pre \
    torch torchvision torchaudio \
    --index-url https://rocm.prereleases.amd.com/whl/gfx1151/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "-c", "import time; print('ROCm container ready. Use docker exec to run commands.'); time.sleep(86400)"]
