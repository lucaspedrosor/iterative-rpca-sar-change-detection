# Input Data

The CARABAS-II dataset is not distributed with this repository.

The dataset is publicly available from the Air Force Research Laboratory (AFRL) Sensor Data Management System (SDMS):

https://www.sdms.afrl.af.mil/

To run the example, copy one surveillance SAR image and one reference SAR image into this folder using the following filenames:

```text
data/
├── surveillance.mat
└── reference.mat
```

Both MAT files must contain the SAR image stored in a variable named:

```matlab
im
```

After preparing the input files, simply execute:

```matlab
run_example
```