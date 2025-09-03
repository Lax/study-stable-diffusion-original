FROM nvcr.io/nvidia/pytorch:25.08-py3

WORKDIR /workspace

ARG HF_ENDPOINT=https://hf-mirror.com
ARG HF_HOME=/root/.cache/huggingface
ENV HF_HUB_OFFLINE=1

# ------------------------------
# 1. Aliyun mirrors for Ubuntu
# ------------------------------
RUN sed -i 's|archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|security.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources

# ------------------------------
# 2. Configure Pip mirrors (Tsinghua + PyTorch/NVIDIA extra)
# ------------------------------
RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = http://mirrors.aliyun.com/pypi/simple/" >> /root/.pip/pip.conf && \
    echo "extra-index-url =" >> /root/.pip/pip.conf && \
    echo "    https://mirrors.aliyun.com/pytorch-wheels" >> /root/.pip/pip.conf && \
    echo "    https://pypi.ngc.nvidia.com" >> /root/.pip/pip.conf && \
    pip config set global.trusted-host mirrors.aliyun.com

# ------------------------------
# 3. Download and extract Stable Diffusion source
# ------------------------------
RUN wget -O- https://github.com/CompVis/stable-diffusion/archive/refs/heads/main.tar.gz | tar zxvf -
WORKDIR /workspace/stable-diffusion-main

# 用 sed 递归修改 txt2img.py / img2img.py 等脚本
RUN grep -rl 'torch.load(ckpt, map_location="cpu")' scripts | xargs sed -i 's/torch.load(ckpt, map_location="cpu")/torch.load(ckpt, map_location="cpu", weights_only=False)/g'

# ------------------------------
# 4. Install environment deps
# ------------------------------
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/huggingface \
    apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libsm6 libxext6 libxrender1 libgl1 && \
    pip install \
        numpy==1.26.4 \
        omegaconf==2.1.1 \
        invisible-watermark \
        pytorch-lightning==1.4.2 \
        torchmetrics==0.6.0 \
        diffusers \
        transformers==4.44.2 "tokenizers>=0.13,<0.20" \
        kornia==0.6 && \
    pip install -e "git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers" && \
    pip install -e "git+https://github.com/openai/CLIP.git@main#egg=clip"

## ------------------------------
## 5. Default entrypoint
## ------------------------------
ADD ./entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
CMD ["python", "-m", "scripts.txt2img", "--prompt", "a photograph of 2 pure white cats fighting", "--plms", "--skip_grid", "--skip_save"]

