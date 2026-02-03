#!/bin/bash
set -e

echo "=== ROCm Strix Container ==="

if [ -z "$HSA_OVERRIDE_GFX_VERSION" ]; then
    export HSA_OVERRIDE_GFX_VERSION=11.5.1
fi

echo "[INFO] Checking GPU..."
python3 -c "
import torch
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')
    print(f'ROCm: {torch.version.hip}')
else:
    print('ERROR: GPU not detected')
    exit(1)
"

echo "[INFO] GPU check passed. Container ready."
exec "$@"
