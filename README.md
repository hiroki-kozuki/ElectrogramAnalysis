## Clone of Nick's repository for analysing electrograms.

# egmcorr.m
This MATLAB code calculates the cross-correlation between two intracardiac electrograms eX and eY using a moving window approach. It determines the time shift and amplitude of correlation between eX and eY by buffering and shifting eY. 

**Inputs**: \
**eX, eY** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. 

**Outputs**: \
**RXY** : Cross-correlation values between eX and eY across time and shifts.\
**tShift** : Time shifts for cross-correlation (calculated from indShift) \[s\].\
**indShift** : Index shifts corresponding to the cross-correlation lag values.\
**RXX** : Autocorrelation values of eX within each window.\
**RYY** : Autocorrelation values of eY within each window.

# egmcorr_centred.m
This MATLAB code also calculates the cross-correlation between two intracardiac electrograms e1 and e2, but both electrograms are shifted around the same centre point (instead of shifting just one of them). The delta range is also narrower, focusing on shifts close to zero. Here, the symmetric approach of windowing both signals around a central time point can reduce computation when signals are already roughly aligned. Hence, egmcorr_centred is optimized for scenarios where signals are already fairly aligned and only small, centered shifts are of interest.

**Inputs**: \
**e1, e2** : Two elecrograms to be cross-correlated. \
**sampleFrec** : Sampling frequency of the EGM signals. \
**tWindowWidth** : Width of the time window \[s\] over which cross-correlation is calculated. \
**tMaxLag** : Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. 

**Outputs**: \
**R** : The cross-correlation matrix for different lags and time points.\
**tShift** : Time shifts for cross-correlation corresponding to lags in delta \[s\].



