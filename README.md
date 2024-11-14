## Clone of Nick's repository for analysing electrograms.

# egmcorr.m
This MATLAB function calculates the cross-correlation between two intracardiac electrograms eX and eY using a moving window approach. It determines the time shift and amplitude of correlation between eX and eY by buffering and shifting eY. 

**Inputs**: \
**eX, eY** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals \[Hz\]. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. 

**Outputs**: \
**RXY** : Cross-correlation matrix between eX and eY for different time points and shifts (lags).\
**tShift** : Array of time shifts (lags) for calculating cross-correlation (calculated from indShift) \[s\].\
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
**tShift** : Array of time shifts (lags) for calculating cross-correlation (calculated from indShift) \[s\].\

# generatewarpshift.m
This MATLAB function refines the output from egmcorr by identifying optimal alignment points (or shifts) between two intracardiac electrogram signals. It dynamically maps out a time-warp function that handles varying delays to accurately align signals with complex timing patterns. This is done by filtering out unreliable regions based on noise level, identifying and following peaks in a cross-correlation score matrix, and ensuring smoothness in shifts over time to reduce alignment artifacts. 

**Inputs**: \
**RXY** : Cross-correlation matrix between two electrograms eX and eY (from egmcorr), reflecting alignment quality across different time points and lags.\
**RXX, RYY**: Autocorrelation values of each electrogram, which help assess the reliability of cross-correlation values in RXY.\
**noiseLevel** : Threshold for distinguishing meaningful signal correlations from noise.

**Outputs**: \
**shift** : Primary array of shifts for aligning eX and eY at each time point.
**shiftAlt** : Alternative alignment shift values.
**SCORE** : Refined score matrix that highlights optimal alignment paths.

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





