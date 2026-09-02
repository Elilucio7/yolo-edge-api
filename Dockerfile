# ───────────────────────────────────────────────────────
# Imagem base: python:3.11-slim
# Equilibrio entre tamanho (~130 MB) e compatibilidade com ARM64
# ────────────────────────────────────────────────────────
FROM python:3.11-slim

# Metadados da imagem
LABEL maintainer="disciplina-visao-computacional"
LABEL description="API de inferencia YOLO em ARM64 via Docker"

# ── CAMADA 1: Dependências de sistema (cache estavel) ──────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ── CAMADA 2: Dependências Python (cache por requirements) ──────
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir -r requirements.txt

# ── CAMADA 3: Código da API ──────────────────────────────
COPY app/ .

# Diretorio de saida dos resultados
RUN mkdir -p /app/output /app/models

# Variavel de ambiente padrao para o modelo
ENV MODEL_NAME=yolov8n.pt

EXPOSE 8000

# Ponto de entrada: sobe a API FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
