# llama.cpp Docker (Tesla V100)

Docker image for llama.cpp optimized for Tesla V100 GPUs (CUDA architecture 7.0).

## Prerequisites

- Docker
- NVIDIA Container Toolkit
- NVIDIA driver
- Tesla V100 GPU

## Build

1. Clone the latest llama.cpp source into this directory
```bash
git clone https://github.com/ggerganov/llama.cpp.git
```

The directory should look like:

```bash
├── Dockerfile
├── README.md
└── llama.cpp/          ← source code
```


2. Build the Docker image
```bash
docker build -t llama-mtp:latest .
```


## Usage

### Start llama-server (MTP speculative decoding)

```bash
docker run --rm -d \
  --name llama-server \
  --gpus all \
  -p 8080:8080 \
  -v /your/model/path:/models \
  llama-mtp:latest \
  /app/llama-server \
  --host 0.0.0.0 --port 8080 \
  --model "/models/your_model.gguf" \
  --n-gpu-layers 999 \
  --ctx-size 65536 \
  --batch-size 512 \
  --spec-type draft-mtp \
  --flash-attn on \
  --spec-draft-n-max 2 \
  --spec-draft-ngl 999 \
  --no-context-shift \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  -t 2 \
  --no-warmup
```

Replace `/your/model/path` with the local directory containing your GGUF model files, and adjust `--model` accordingly.

The server will be accessible at `http://localhost:8080`.

## Notes

Only `llama-server` is built; examples and tests are excluded
