# ATLAS
A Platform-Independent AI Tumor Lineage and Site (ATLAS) Classifier

Utilizing gradient-boosted machine learning (XGBoost), a pair of separate AI Tumor Lineage and Site-of-origin models from RNA expression data on 8,249 tumor samples was trained. ATLAS was validated on 10,376 total tumor samples, including 1,490 metastatic samples.

ATLAS - Cancer Site of Origin: Adrenal Gland Cancer, Bladder/Urinary Tract Cancer, Breast Cancer, Cervical Cancer, CNS Cancer, Colorectal Cancer, Gastroesophageal Cancer, Head and Neck Cancer, HPB (Hepato-pancreato-biliary) Cancer, Kidney Cancer, Lung Cancer, Lymphoid Neoplasm, Myeloid Neoplasm, Ovarian Cancer, PNS Cancer, Prostate Cancer, Skin Cancer, Soft Tissue/Bone Cancer, Testicular Cancer, Thymus Cancer, Thyroid Cancer, Uterine Cancer

ATLAS - Cancer Lineage: Adenocarcinoma, Germ Cell Tumor, Glioma, Lymphoid/Myeloid Neoplasm, Melanoma, Neuroepithelial Cancer, Sarcoma, Squamous Cell Carcinoma

The model can be run within the provided Rproject environment, with a set of examples provided to demonstrate the workflow. For both classifiers, the model output provides the individual class prediction, class probabilities for all classes, and per sample Shapley scores for assessment of  feature importance.