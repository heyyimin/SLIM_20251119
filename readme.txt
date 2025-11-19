Description: This software package provides a reference implementation of the SLIM (simultaneous super-resolution and lifetime imaging microscopy) technique, as presented in our paper "SLIM: Functional Nanoscopy for Simultaneous Super-resolution and Quantitative Lifetime Imaging by Spatiotemporal Multiplexing of Spontaneous Emission." It is designed to reconstruct super-resolution fluorescence lifetime images from time-gated FLIM data acquired using the SLIM method.

1. Prerequisites
Ensure the following software is installed on your system:
* MATLAB (R2019b or a compatible later version)

2. Data Preparation
Before starting, prepare the following data files:
* Raw FLIM Data: Spatiotemporal encoded FLIM data in Becker & Hickl TCSPC format (.sdt files).
* Reference Lifetime Map: The fluorescence lifetime map (in .asc format) obtained by fitting the spontaneous emission (pre-depletion) photons from the same dataset, typically generated using software as SPCImage.

3. Processing Workflow
To reconstruct images using MATLAB, follow these steps:
(1) Start MATLAB.
(2) Open and run the script SLIM.m.
(3) When prompted, select the target .sdt file for processing.
(4) The script will generate the final super-resolution fluorescence lifetime image as: SLIM_image.tif.

4. Parameter Configuration
To ensure optimal results, configure the following key parameters in the code:
(1) Pulse Interval (Line 33): Adjust the pulse_interval value (in nanoseconds) to match the actual time delay between your excitation and depletion laser pulses. An incorrect value will lead to improper temporal gating and erroneous results.
(2) SCD Factor (Line 91): The Secondary Computational Depletion (SCD_Factor) is crucial for background suppression and resolution enhancement. Empirically adjust this value based on your data quality and depletion efficiency. Begin with a low value (e.g., 1.5) and increase it gradually until optimal image clarity is achieved without introducing artifacts.
(3) Lifetime Display Threshold (Lines 103-104): Similar to SPCImage, set an appropriate fluorescence lifetime display threshold to achieve a clear visualization of the sample's lifetime distribution.

5. Example
For a complete walkthrough using the provided example data:
(1) Run SLIM.m in MATLAB, ensuring the pulse_interval and SCD_Factor are properly set, along with a suitable lifetime display threshold.
(2) Select the target .sdt file when prompted.
(3) The final output, SLIM_image.tif, will be generated, which integrates the super-resolved intensity with quantitative lifetime information.

