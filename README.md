# AWS_MD — GROMACS Batch Runner for GPU instances

This repository contains tooling, data layout, and Docker configuration to run GROMACS molecular dynamics workloads on GPU-equipped cloud instances (tested with NVIDIA H100/H200-class GPUs and Ubuntu 22.04).

The project is organised to support multiple independent simulation projects under `gromacs_data/` and includes a Docker image, example run scripts, forcefields, and common mdp files.

## Highlights

- Dockerfile to build GROMACS 2024.4 with CUDA support
- `run_batch.sh` to iterate through `project*/` folders and run/continue simulations
- Example forcefields (CHARMM) and mdp templates under `gromacs_data/`

## Quick start (recommended)

1. Build the Docker image (from `Docker/`):

```bash
cd Docker
docker build -t gromacs-h200:2024.4 .
```

2. Prepare large storage (recommended for production runs). If you have an EBS or attached disk, mount it (example: `/mnt/md_storage`) and move `gromacs_data` there so it is persisted outside the container:

```bash
# from repository root
mv gromacs_data /mnt/md_storage/
# full path used below: /mnt/md_storage/gromacs_data
```

3. Run the container with GPUs and enough CPU/memory. This repository includes a recommended `docker run` command in `Docker/Build_and_run_docker.txt` — here's an example tuned for 22 CPU threads and a large memory allocation:

```bash
docker run --gpus all \
  --cpus="22" \
  --memory="200g" \
  --shm-size=16g \
  -v /mnt/md_storage/gromacs_data:/data \
  -w /data \
  gromacs-h200:2024.4 \
  bash run_batch.sh
```

Notes:
- Adjust `--cpus`, `--memory`, and `--shm-size` to match your instance size.
- The image is based on `nvidia/cuda:12.2.0-devel-ubuntu22.04` and builds GROMACS 2024.4 with CUDA support (see `Docker/Dockerfile`).

## Running locally (without Docker)

If you have GROMACS 2024.4 installed with GPU support, you can run `gromacs_data/run_batch.sh` directly from the repository root after ensuring your current working directory is the `gromacs_data` folder:

```bash
# run from the repository root
cd gromacs_data
bash run_batch.sh
```

The script will iterate over `project*/` directories and run `gmx mdrun` for each project that contains an `md.tpr` file. If a checkpoint `md.cpt` exists, the script resumes the run.

## Repository layout

Top-level files and directories:

- `Docker/` — Dockerfile and instructions to build the GROMACS CUDA image
- `gromacs_data/` — data folder containing multiple `project*/` folders, `forcefields/`, `mdp_files/`, and `run_batch.sh`
  - `project1/`, `project2/`, ... — example project folders; each should contain the topology, coordinates and `md.tpr` (or the steps to create it).
  - `forcefields/` — CHARMM forcefields included for convenience
  - `mdp_files/` — template mdp files (nvt, npt, md, ions, em)
  - `logs/` — runtime logs written by `run_batch.sh`

## Important files

- `Docker/Dockerfile` — builds GROMACS 2024.4 with CUDA
- `Docker/Build_and_run_docker.txt` — example docker build & run commands
- `gromacs_data/run_batch.sh` — batch script that runs `gmx mdrun` on each project

## Customising runs

- Edit the `mdp` files in `gromacs_data/mdp_files/` to change integration parameters.
- Prepare `md.tpr` files per project using `gmx grompp` before running `run_batch.sh`.
- Adjust `-ntomp` and other `gmx mdrun` options in `run_batch.sh` to match your CPU/GPU topology.

## Troubleshooting

- If the container cannot access GPUs, ensure the NVIDIA Container Toolkit is installed on the host and the `--gpus all` flag is supported.
- If runs fail due to insufficient memory or CPU, increase `--memory` and `--cpus` or reduce thread count in the script.
- Check individual project logs under `gromacs_data/logs/` and the `batch_summary.log` for a summary.

## Contributing

If you'd like to contribute:

1. Fork the repository.
2. Make small, focused changes and open a pull request with a clear description.

If you add new `project` folders, consider adding a README in that folder describing inputs and expected behavior.

## License & Contact

This repository does not contain an explicit license file. If you plan to share or publish this project, add a `LICENSE` file (MIT, Apache 2.0, etc.).

For questions or help, open an issue in this repository or contact the maintainer.

---

Generated: 2026-03-03
