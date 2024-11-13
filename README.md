## Clone of Nick's repository for analysing electrograms.

# egmcorr.m
This MATLAB code calculates the cross-correlation between two intracardiac electrograms eX and eY using a moving window approach. It determines the time shift and amplitude of correlation between eX and eY. 
Inputs: \
eX, eY = Two elecrograms to be cross correlated. \
sampleFrec = Sampling frequency of the EGM signals. \
tWindowWidth = Width of the time window \[s\] over which cross-correlation is calculated. \
tMaxLag = Maximum shift (lag) of eY w.r.t eX \[s\] for computing cross-correlation. \
