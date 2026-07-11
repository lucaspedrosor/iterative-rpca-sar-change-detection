# Iterative RPCA-Based SAR Change Detection

Official MATLAB implementation accompanying the paper:

> **An Iterative Unsupervised Change Detection Method Based on Robust PCA for Small SAR Image Datasets**
>
> **Lucas P. Ramos**, D. I. Alves, Leonardo T. Duarte, Renato Machado, Viet Thuy Vu, and Mats I. Pettersson.
>
> *IEEE Transactions on Geoscience and Remote Sensing (TGRS), Early Access, 2026.*

**DOI:** https://doi.org/10.1109/TGRS.2026.3710985

**IEEE Xplore:** https://ieeexplore.ieee.org/document/11598913

---

## Overview

This repository contains the official MATLAB implementation of the iterative SAR change detection framework proposed in the paper.

The proposed approach iteratively reconstructs the reference SAR image using Robust Principal Component Analysis (RPCA) or Tensor Robust Principal Component Analysis (TRPCA). At each iteration, the reconstructed reference image is incorporated into the decomposition process, allowing the method to progressively refine the background representation and improve change detection performance in scenarios with limited SAR acquisitions.

This repository includes:

- Iterative RPCA-based change detection
- Iterative TRPCA-based change detection
- Method Rules (MR) proposed in the paper
- Example script for processing a pair of SAR images

---

## Dataset

The SAR images used in the paper are **not distributed** with this repository.

The experiments were conducted using the **CARABAS-II** dataset, which is publicly available through the Air Force Research Laboratory (AFRL) Sensor Data Management System (SDMS):

https://www.sdms.afrl.af.mil/

After obtaining the dataset, users only need to provide **one surveillance SAR image** and **one reference SAR image** to reproduce the example included in this repository.

---

## External Dependencies

This implementation relies on publicly available implementations of RPCA and TRPCA.

### RPCA

https://github.com/dlaptev/RobustPCA

### TRPCA

https://github.com/canyilu/Tensor-Robust-Principal-Component-Analysis-TRPCA

Please download these repositories and add them to the MATLAB path before running the examples.

---

## Repository Structure

```text
iterative-rpca-sar-change-detection/
│
├── README.md
├── setup.m
├── run_example.m
│
├── src/
├── external/
├── data/
├── docs/
└── results/
```

---

## License

This repository is released under the MIT License.
