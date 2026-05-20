FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libcurl4-openssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm config set registry https://registry.npmmirror.com

RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1 \
    && ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so

WORKDIR /app/llama.cpp

COPY ./llama.cpp /app/llama.cpp

RUN cmake -B build \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES=70 \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_SERVER_ONLY=ON \
    -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath-link,/usr/local/cuda/lib64/stubs" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link,/usr/local/cuda/lib64/stubs" \
    -DCMAKE_BUILD_TYPE=Release

RUN cmake --build build --config Release -j$(nproc)


FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libcurl4 \
    && rm -rf /var/list/apt/lists/*

WORKDIR /app

COPY --from=builder /app/llama.cpp/build/bin/ /app/

ENV LD_LIBRARY_PATH=/app:$LD_LIBRARY_PATH

EXPOSE 8080

CMD ["./llama-cli", "--help"]
