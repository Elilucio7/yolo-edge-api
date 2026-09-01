# ───────────────────────────────────────────────────────
# Imagem base: python:3.11-slim
# Equilibrio entre tamanho (~130 MB) e compatibilidade com ARM64
# ────────────────────────────────────────────────────────
FROM python:3.11-slim


# Metadados da imagem
LABEL maintainer="disciplina-visao-computacional"
LABEL description="Inferencia YOLO em ARM64 via Docker"


# ── CAMADA 1: Dependências de sistema (cache estavel) ──────────
# Instaladas antes das dependencias Python para maximizar cache
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
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# ── CAMADA 3: Codigo e pesos do modelo ───────────────────────
COPY app.py .
COPY yolov8n.pt .


# Diretorio de saida dos resultados
RUN mkdir -p /app/output


# Variavel de ambiente padrao para o modelo
ENV MODEL_NAME=yolov8n.pt


# Ponto de entrada padrao
ENTRYPOINT ["python", "app.py"]
CMD ["--mode", "detect", "--input", "/app/test_image.jpg"]
