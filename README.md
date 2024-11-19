## Mirror of Nick's repository for analysing electrograms.

File descriptions by Hiroki Kozuki

# egmcorr.m
This MATLAB function calculates the cross-correlation between two intracardiac electrograms eX and eY using a moving window approach. It determines the time shift and amplitude of correlation between eX and eY by buffering and shifting eY. 

**Inputs**: \
**eX, eY** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals \[Hz\]. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. 

**Outputs**: \
**RXY** : Cross-correlation matrix between eX and eY for different time points and shifts (lags).\
**tShift** : Array (vector) of time shifts (lags) for calculating cross-correlation (calculated from indShift) \[s\].\
**indShift** : Index shifts corresponding to the cross-correlation lag values.\
**RXX** : Autocorrelation values of eX within each window.\
**RYY** : Autocorrelation values of eY within each window.

# egmcorr_centred.m
This MATLAB function also calculates the cross-correlation between two intracardiac electrograms e1 and e2, but both electrograms are shifted around the same centre point (instead of shifting just one of them). The delta range is also narrower, focusing on shifts close to zero. Here, the symmetric approach of windowing both signals around a central time point can reduce computation when signals are already roughly aligned. Hence, egmcorr_centred is optimized for scenarios where signals are already fairly aligned and only small, centered shifts are of interest.

**Inputs**: \
**e1, e2** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals \[Hz\]. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. 

**Outputs**: \
**RXY** : Cross-correlation matrix between e1 and e2 for different time points and shifts (lags).\
**tShift** : Array (vector) of time shifts (lags) for calculating cross-correlation (calculated from indShift) \[s\].\

# generatewarpshift.m
This MATLAB function refines the output from egmcorr by identifying optimal alignment points (or shifts) between two intracardiac electrogram signals. It dynamically maps out a time-warp function that handles varying delays to accurately align signals with complex timing patterns **(*Dynamic Time Warping*)**. This is done by filtering out unreliable regions based on noise level, identifying and following peaks in a cross-correlation score matrix, and ensuring smoothness in shifts over time to reduce alignment artifacts. 

**Inputs**: \
**RXY** : Cross-correlation matrix between two electrograms eX and eY (from egmcorr), reflecting alignment quality across different time points and lags.\
**RXX, RYY**: Autocorrelation values of each electrogram, which help assess the reliability of cross-correlation values in RXY.\
**noiseLevel** : Threshold for distinguishing meaningful signal correlations from noise.

**Outputs**: \
**shift** : Primary array (vector) of shifts for aligning eX and eY at each time point \[s\].\
**shiftAlt** : Alternative alignment shift values \[s\].\
**SCORE** : Refined score matrix that highlights optimal alignment paths.

**Uses**:\
egmcorr

# finessewarpshift.m
This MATLAB function processes a vector of shift values (shiftOld) generated in previous functions (e.g., generatewarpshift) and fills in missing values (NaN) using linear interpolation where no shift values were previously identified. This smoothens out and refines the shift sequence, ensuring continuity and gradual changes between consecutive points in time such that the maximum allowed gradient is +/- 1. 

**Inputs**: \
**shiftOld** : Array (vector) of shift values that may contain NaN entries where a shift could not be determined \[s\].

**Outputs**: \
**shift** : Array (vector) containing smoothly interpolated shifts (wihout NaN values).

**Uses**:\
generatewarpshift

# egmtimewarp.m
This MATLAB function extends the functionality of egmcorr to not only calculate the time-shifted correlation between two intracardiac electrograms (eX and eY) but also to determine and refine a "warping" or time alignment between them to map eX <-> eY. **It does this by calling *egmcorr*, *generatewarpshift*, and *finessewarpshift*.** This is particularly useful for aligning signals with non-uniform delays, as might occur in the variable timing of cardiac events.

**Inputs**: \
**eX, eY** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals \[Hz\]. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. \
**noiseLevel** : Threshold for distinguishing meaningful signal correlations from noise.

**Outputs**: \
**shift** : A refined warping shift array indicating the time shifts required to align eX to eY at each time point.

**Uses**:\
finessewarpshift

# warpegm.m
This MATLAB function interpolates between two electrograms (eX and eY) and yields eX + f*(eY-eX) based on a time-warping shift vector shiftXY and a weighting factor f. It synthesizes an electrogram (eInterp) that aligns eX and eY in a non-linear fashin and combines them accounting for their time discrepancies as specified by shiftXY. This is useful for applications where signals may be temporally misaligned due to physiological or technical reasons, such as varying conduction speeds or sensor timing differences. The resulting eInterp represents an intermediate state between eX and eY in both time and amplitude.

**Inputs**: \
**eX, eY** : Two electrograms to be interpolated. \
**shiftXY** : Vector indicating the shift (or time warping) from eX to eY at each index of eX, i.e. eX(iX) <-> eY(iX+shift(iX) (indices, but may be non-integer).\
**f** : A scalar or vector weight (0 < f < 1), representing the interpolation factor. An f value of 0 means the interpolation is fully eX, while 1 means fully eY.

**Outputs**: \
**eInterp** : Interpolated electrogram that combines eX and eY based on the shift and weighting factor f.

# testegmwarpSCRIPT.m:
This MATLAB code performs processing, alignment, and interpolation of EGMs. It uses time-warping, cross-correlation analysis, and shifts interpolation for accurate spatial and temporal alignment. This allows comparison and visualization of two EGMs (e1 and e2) from different recording locations, interpolating a new EGM (eInterp) between them.

**Uses**:\
egmcorr, interpegm

# testegmwarp3dSCRIPT.m
Simplified version of testegmwarpSCRIPT.m with only 4 grid points for electrodes. 

# interpegm.m:
This MATLAB code performs spatial interpolation of electrograms on a triangular mesh by incorporating time warping between neighboring points on the mesh. The interpegm function creates an interpolated electrogram (eInterp) at arbitrary spatial points (pNew) within a triangular mesh defined by tri. It considers time shifts (shift) between electrode recordings to achieve more accurate temporal alignment before performing the interpolation. The main interpegm function generates interpolated EGMs by calculating time shifts between EGMs along each triangle edge using ***egmtimewarp***, mapping EGM signals onto new points by incorporating these shifts, and using barycentric interpolation to produce an accurate EGM signal at arbitrary points within the triangulated region. It provides spatially continuous EGM data by capturing both temporal and spatial variations, especially useful for visualizing and analyzing electrical activity in the heart with high spatial precision.

**Inputs**: \
**pNew** : Coordinates of points where the interpolated electrogram is desired, i.e., coordinates of the electrodes. \
**tri** : A triangular mesh structure containing connectivity information for the electrodes. \
**egm** : The recorded electrograms, where each column represents an EGM signal from an electrode. \
**sampleFreq** : Sampling frequency of the EGMs \[Hz\]. \
**noiseLevel** : Noise level in the EGM signals.

**Outputs**: \
**eInterp** : The interpolated electrogram at each of the specified points in pNew.

**Uses**:\
egmtimewarp, 

# gridinterpSCRIPT.m:
This script loads EGM data and generates an animated visualization of interpolated EGMs across a 2D electrode array. It combines spatial interpolation, Hilbert transforms, and temporal smoothing to create a dynamic 3D mesh, allowing detailed observation of the signal’s spatial and temporal evolution. The final output is saved as a video, providing a comprehensive view of the electrical activity distribution across the heart’s surface.

**Uses**:\
interpegm






