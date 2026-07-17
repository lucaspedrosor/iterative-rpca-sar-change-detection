# Iterative RPCA/TRPCA-Based SAR Change Detection

Official MATLAB implementation accompanying the paper:

> **An Iterative Unsupervised Change Detection Method Based on Robust PCA for Small SAR Image Datasets**
>
> **Lucas P. Ramos**, D. I. Alves, Leonardo T. Duarte, Renato Machado, Viet Thuy Vu, and Mats I. Pettersson.
>
> *IEEE Transactions on Geoscience and Remote Sensing, vol. 64, 2026, Art. no. 5212213.*

**DOI:** https://doi.org/10.1109/TGRS.2026.3710985

**IEEE Xplore:** https://ieeexplore.ieee.org/document/11598913

---

## Overview

This repository contains the official MATLAB implementation of the iterative SAR change detection framework proposed in the paper.

The proposed framework iteratively reconstructs the reference SAR image using either Robust Principal Component Analysis (RPCA) or Tensor Robust Principal Component Analysis (TRPCA). At each iteration, the reconstructed reference image is incorporated into the decomposition process, progressively improving the background estimation and the corresponding change detection map, particularly in scenarios with limited SAR acquisitions.

The repository includes:

- Iterative RPCA-based change detection
- Iterative TRPCA-based change detection
- Method Rules (MR) proposed in the paper
- Example scripts for both RPCA and TRPCA implementations
- Automatic repository configuration through `setup.m`

---

## Dataset

The SAR images used in the paper are **not distributed** with this repository.

The experiments were conducted using the **CARABAS-II** dataset, which is publicly available through the Air Force Research Laboratory (AFRL) Sensor Data Management System (SDMS):

https://www.sdms.afrl.af.mil/

To reproduce the examples, place one surveillance SAR image and one reference SAR image inside the `data` folder using the filenames:

```text
data/
├── surveillance.mat
└── reference.mat
```

Both MAT files must contain the SAR image stored in a variable named:

```matlab
im
```

---

## Getting Started

Configure the repository:

```matlab
setup
```

Run the RPCA example:

```matlab
run_rpca_example
```

Run the TRPCA example:

```matlab
run_trpca_example
```

---

## External Dependencies

This implementation relies on publicly available RPCA and TRPCA implementations.

### Robust PCA (RPCA)

https://github.com/dlaptev/RobustPCA

### Tensor Robust PCA (TRPCA)

https://github.com/canyilu/Tensor-Robust-Principal-Component-Analysis-TRPCA

Download both repositories and place them inside the `external` directory. The `setup.m` script will automatically configure the MATLAB path.

---

## Repository Structure

```text
iterative-rpca-sar-change-detection/
│
├── README.md
├── LICENSE
├── .gitignore
├── setup.m
├── run_rpca_example.m
├── run_trpca_example.m
│
├── src/
│   ├── iterative_rpca_cd.m
│   ├── iterative_trpca_cd.m
│   ├── apply_method_rules.m
│   ├── load_sar_image.m
│   └── default_parameters.m
│
├── external/
├── data/
├── docs/
└── results/
```

---

## Citation

If you use this repository in your research, please cite:

```bibtex
@ARTICLE{Ramos2026IterativeRPCA,
  author={Ramos, Lucas P. and Alves, D. I. and Duarte, Leonardo T. and Machado, Renato and Vu, Viet Thuy and Pettersson, Mats I.},
  title={An Iterative Unsupervised Change Detection Method Based on Robust PCA for Small SAR Image Datasets},
  journal={IEEE Trans. Geosci. Remote Sens.},
  volume={64},
  year={2026},
  articleno={5212213},
  doi={10.1109/TGRS.2026.3710985}
}
```

---

## License

This project is released under the MIT License.
