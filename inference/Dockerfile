FROM ghcr.io/ggerganov/llama.cpp:server

ARG MODEL_URL=https://huggingface.co/EleutherAI/llemma_7b-GGUF/resolve/main/llemma_7b-Q4_K_M.gguf

RUN mkdir -p /models && wget -q -O /models/llemma.gguf "$MODEL_URL"

EXPOSE 8080

ENTRYPOINT ["/llama-server", "-m", "/models/llemma.gguf", "-c", "4096", "--host", "0.0.0.0", "--port", "8080"]
