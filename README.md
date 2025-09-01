### Usage

```
docker compose run --build stable-diffusion python -m scripts.txt2img --prompt "a photograph of a white cat standing on top of a television" --seed "$RANDOM"
```

### Preparing

```
COMPOSE_BAKE=true docker compose build
```

```
mkdir -p models/ldm/stable-diffusion-v1/
aria2c -c -x 10 https://hf-mirror.com/CompVis/stable-diffusion-v-1-1-original/resolve/main/sd-v1-1.ckpt?download=true -o models/ldm/stable-diffusion-v1/sd-v1-1.ckpt

ln -sf sd-v1-1.ckpt models/ldm/stable-diffusion-v1/model.ckpt
```

```
huggingface-cli download --local-dir models/CompVis/stable-diffusion-safety-checker --resume-download CompVis/stable-diffusion-safety-checker

huggingface-cli download --local-dir models/openai/clip-vit-large-patch14 --resume-download openai/clip-vit-large-patch14 preprocessor_config.json config.json pytorch_model.bin
```
