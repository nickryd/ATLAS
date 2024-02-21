# ATLAS
A Platform-Independent AI Tumor Lineage and Site (ATLAS) Classifier

Utilizing gradient-boosted machine learning (XGBoost), a pair of separate AI Tumor Lineage and Site-of-origin models from RNA expression data on 8,249 tumor samples was trained. ATLAS was validated on 10,376 total tumor samples, including 1,490 metastatic samples.

ATLAS - Cancer Site of Origin: Adrenal Gland Cancer, Bladder/Urinary Tract Cancer, Breast Cancer, Cervical Cancer, CNS Cancer, Colorectal Cancer, Gastroesophageal Cancer, Head and Neck Cancer, HPB (Hepato-pancreato-biliary) Cancer, Kidney Cancer, Lung Cancer, Lymphoid Neoplasm, Myeloid Neoplasm, Ovarian Cancer, PNS Cancer, Prostate Cancer, Skin Cancer, Soft Tissue/Bone Cancer, Testicular Cancer, Thymus Cancer, Thyroid Cancer, Uterine Cancer

ATLAS - Cancer Lineage: Adenocarcinoma, Germ Cell Tumor, Glioma, Lymphoid/Myeloid Neoplasm, Melanoma, Neuroepithelial Cancer, Sarcoma, Squamous Cell Carcinoma

The model can be run within the provided Rproject environment, with a set of examples provided to demonstrate the workflow. For both classifiers, the model output provides the individual class prediction, class probabilities for all classes, and per sample Shapley scores for assessment of feature importance.

## Data

The `data` folder in this repository contains several files essential for reproducing the ATLAS analysis:

- `samples_example.RDS`: This file includes a subset of RNAseq samples. It serves as an example dataset to demonstrate the input and output process in ATLAS.

- `samples_examples_truth.RDS`: This file includes the true Cancer Site of Origin and Cancer Lineage classes for the aobve samples

- `analysis_data.csv`: This comprehensive dataset contains all sample and outcome data necessary to reproduce the figures presented in the ATLAS manuscript. This is the source data that can be used to reproduce Figure 1b-c, 2b-h, 3, 4a-c, 5c-d, and 6 in the manuscript.

- `resamples_fig2a.csv`: Summary outcome data that can be used for reproducing Figure 2a in the manuscript.

## Installation Guide
ATLAS can be installed and run on a standard computer. ATLAS has been tested on the following systems:

macOS: Sonoma (14.2.1)
Linux: Ubuntu 20.04

Before running the project, you will need to have R and RStudio installed. If you do not have them installed, please follow the links below to download and install the latest versions:

- [Download R](https://cran.r-project.org/)
- [Download RStudio](https://www.rstudio.com/products/rstudio/download/)

The download and installation process for both R and RStudio typically takes between 10-20 minutes, depending on your internet speed and computer performance.

If you have Git installed, you can clone the ATLAS repository to your local machine with the following command:

```bash
git clone https://github.com/nickryd/ATLAS.git
```

Alternatively you can:
1. Click on the 'Code' button.
2. Select 'Download ZIP' from the dropdown menu.
3. Once downloaded, extract the ZIP file to your desired location.

Once you are within the ATLAS folder, open the .Rproj file and open scripts/ATLAS_run.R. This file will have instructions to initialize ATLAS, with installation taking approximately 5-10 minutes. Instructions on how to run ATLAS, descriptions of the output, and a sample dataset for testing is provided in this file.

## Versioning and DOI
The version of this repository is archived on Zenodo. The badge below links to the specific archived version, providing a DOI for citation purposes.
[![DOI](https://zenodo.org/badge/726159209.svg)](https://zenodo.org/doi/10.5281/zenodo.10519785)

## License
This project is covered under the **Academic Software End User License** from the University of Wisconsin-Madison.

Copyright 2023 University of Wisconsin, Nicholas Rydzewski, Shuang (George) Zhao.

For more information, see the [LICENSE.md](LICENSE.md) file in this repository.