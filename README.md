# SPIE2023-ImageQuality
It contains the codes for the paper "Assessing the impact of correlated noise in digital mammography: a virtual clinical trial", submitted to the SPIE 2023 conference. We used the OpenVCT from the University of Pennsylvania, available [here](https://sourceforge.net/p/openvct/wiki/Home/). We also used The Laboratory for Individualized Breast Radiodensity Assessment ([LIBRA](https://www.med.upenn.edu/sbia/libra.html)), a software package developed by the University of Pennsylvania. The R* metric was calculated using the ImageJ plugin, available [here](https://www.ucm.es/gabriel_prieto/ssim-family-java-and-class).

Disclaimer: For education purposes only.

## Abstract:

In digital mammography, the physics of the acquisition system and post-processing algorithms can cause image noise to be spatially correlated. Noise correlation is characterized by non-constant noise power spectral density and can negatively affect image quality. Although the literature explores ways to quantify the frequency dependence of noise in digital mammography, there is still a lack of studies that explore the effect of this phenomenon on clinical tasks. Thus, the aim of this work is to evaluate the impact of noise correlation on the quality of digital mammography and the detectability of lesions using a virtual clinical trial (VCT) tool. Considering the radiographic factors of a standard full-dose acquisition, VCT was used to generate two sets of images: one containing mammograms corrupted with correlated noise and the other with uncorrelated (white) noise. Clusters of five to seven microcalcifications of different sizes and shapes were computationally inserted into the images at regions of dense tissue. We then designed a human observer study to investigate performance on a clinical task of locating microcalcifications on digital mammography from both image sets. In addition, nine objective image quality metrics were calculated on mammograms. The results obtained with four medical physicists showed that the average performance in localization was 72% for images with correlated noise and 95% with uncorrelated noise. Thus, our results suggest that correlated noise promotes a greater reduction in the conspicuity of subtle microcalcifications than uncorrelated noise. Furthermore, only four of the nine objective quality metrics calculated in this work were consistent with the results of the human observer study, highlighting the importance of using appropriate metrics to assess the quality of corrupted images with correlated noise.

## Reference:

If you use the codes, we will be very grateful if you refer to this [paper](https://doi.org/10.1117/12.2654111).

Lucas E. Soares, Renann F. Brandao, Lucas R. Borges, Renato F. Caron, Bruno Barufaldi, Andrew D. A. Maidment, and Marcelo A. C. Vieira "Assessing the impact of correlated noise in digital mammography: a virtual clinical trial", Proc. SPIE 12467, Medical Imaging 2023: Image Perception, Observer Performance, and Technology Assessment, 1246714 (3 April 2023); [https://doi.org/10.1117/12.2654111](https://doi.org/10.1117/12.2654111)

```
@inproceedings{10.1117/12.2654111,
author = {Lucas E. Soares and Renann F. Brandao and Lucas R. Borges and Renato F. Caron and Bruno Barufaldi and Andrew D. A. Maidment and Marcelo A. C. Vieira},
title = {{Assessing the impact of correlated noise in digital mammography: a virtual clinical trial}},
volume = {12467},
booktitle = {Medical Imaging 2023: Image Perception, Observer Performance, and Technology Assessment},
editor = {Claudia R. Mello-Thoms and Yan Chen},
organization = {International Society for Optics and Photonics},
publisher = {SPIE},
pages = {1246714},
keywords = {Digital mammography, Correlated noise, Image quality assessment, Virtual clinical trials, Human observer study},
year = {2023},
doi = {10.1117/12.2654111},
URL = {https://doi.org/10.1117/12.2654111}
}
```

## Acknowledgments:

This work was supported in part by the São Paulo Research Foundation ([FAPESP](http://www.fapesp.br/) grant 2021/12673-6). The authors would also like to thank Real Time Tomography for providing access to the image processing software, and the team of medical physicists who volunteered to participate in the staircase and localization studies.

---
Laboratory of Computer Vision ([Lavi](http://iris.sel.eesc.usp.br/lavi/))  
Department of Electrical and Computer Engineering  
São Carlos School of Engineering, University of São Paulo  
São Carlos - Brazil
