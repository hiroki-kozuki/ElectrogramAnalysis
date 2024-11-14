function [R, tShift] = egmcorr_centred(e1,e2,sampleFreq, tWindowWidth, tMaxLag)
% EGMCROSSCORRELATE 
% Make sure to choose tWindowWidth to minimise mains pickup
% Author: Nick Linton (2014)
% Modifications - 


% Info on Code Testing:
						% ---------------------
                        % test code
                        % ---------------------
                        % sampleFreq = 2034.5;
                        % tS = 1 / sampleFreq;
                        % 
                        % %for egmcorr
                        % tWindowWidth = 20/1000;
                        % tMaxLag = 20/1000;
                        % 
                        % 
                        % sigma = 5/1000;
                        % t = -4*sigma:tS:4*sigma;
                        % indSpike = (1:numel(t)) - ceil(numel(t)/2);
                        % testSpike = (1-(t/sigma).^2) .* exp((-(t).^2)/2/sigma/sigma);
                        % 
                        % nSpike = 5;
                        % ind_Act = (1:nSpike) * 200;
                        % diff_Act = ((1:nSpike)-ceil(nSpike/2)) * tMaxLag/nSpike * sampleFreq;
                        % diff_Act = round(diff_Act);
                        % 
                        % e1 = zeros(ind_Act(end) + diff_Act(end) + 3*round(sampleFreq*(tWindowWidth +tMaxLag)),1);
                        % e2 = e1;
                        % 
                        % for i = 1:nSpike
                        %     ind = indSpike + ind_Act(i);
                        %     e1(ind) = testSpike;
                        %     e2(ind + diff_Act(i)) = testSpike;
                        % end
                        % 
                        % figure
                        % plot(e1)
                        % hold on
                        % plot(e2)
                        % 
                        % [R, tShift] = egmcorr(e1,e2,sampleFreq, tWindowWidth, tMaxLag);
                        %     [Rmax, iDelta] = max(R, [],2);
                        %     tDiff = tShift(iDelta);
                        % 
                        % [pks,locs] = findpeaks(Rmax, 'MinPeakHeight',1);
                        % iDelta(locs)
                        % tShift(iDelta(locs))*sampleFreq
                        % diff_Act
                        % 



% ---------------------------------------------------------------
% code
% ---------------------------------------------------------------
    
    % create window
    nW = tWindowWidth*sampleFreq; % Window length counted in terms of number of sample indices. 
    nHalfW = floor(nW/2);
    nW = 2*nHalfW+1;
    w = kaiser(nW,2); % Apply a Kaiser window (beta = 2) to smooth the edges of the time window. This helps reduce artifacts from sharp transitions at window boundaries.
    
    maxDelta = ceil(tMaxLag * sampleFreq / 2); % Unline egmcorr.m, maxDelta is defined as ceil(tMaxLag * sampleFreq / 2) instead of ceil(tMaxLag * sampleFreq). This difference effectively centers the lag range around zero more tightly, which could help if minimal shift detection is required.
    delta = -maxDelta:maxDelta; % List of all possible shifts in sample indices based on tMaxLag.
        
    k = nHalfW+delta(end);
% *************************************************************************
% This is the simple version of the code, which is slow
%**************************************************************************
%     R = NaN(numel(e1),numel(delta));
%     for t = (k+1):(numel(e1)-k);
%         for j = 1:numel(delta);
%             d = delta(j);
%             e1w = e1((t-nHalfW-d):(t+nHalfW-d)) .* w; %this will be calculated multiple times for various t/j
%             e2w = e2((t-nHalfW+d):(t+nHalfW+d)) .* w;
%             R(t,j) = e1w'*e2w;
%         end
%     end
    
% *************************************************************************
% This is the more complicated version of the code, which is faster.
% For each value of t above, we need e1w and e2w centred on t-d to t+d or,
% more formally, t+delta(:)
%**************************************************************************
% e1w is going to be an n*numel(w) array - it is e1 'windowed'
% e1w and e2w are created as matrices where each row corresponds to a buffered, windowed segment of e1 and e2, respectively.
    nBuff = numel(delta);
    e1w = zeros(nBuff, numel(w));
    e2w = zeros(nBuff, numel(w));
    tFirst = k + 1;
    
    for i = (tFirst-maxDelta):(tFirst+maxDelta)
        index = 1 + mod(i,nBuff);
        e1w(index,:) = e1((i-nHalfW):(i+nHalfW)) .* w;
        e2w(index,:) = e2((i-nHalfW):(i+nHalfW)) .* w;
    end

% In the main loop, the function iterates over each time point in e1 and performs the following steps:
% Buffering: Adds the current windowed segments of e1 and e2 to the buffers e1w and e2w for cross-correlation calculations.
% Centered Windowing: Here, the code shifts e1w and e2w centered around the current time point, offset by delta. This is done using index1 = 1 + mod(t - delta, nBuff); and index2 = 1 + mod(t + delta, nBuff);.
% Cross-Correlation Calculation: R(t, :) = sum(e1w(index1, :) .* e2w(index2, :), 2)'; calculates the cross-correlation by summing element-wise products of windowed segments of e1 and e2 at various shifts.
    
    R = zeros(numel(e1),numel(delta));
    for t = tFirst:(numel(e1)-k)
        % add next e1w and e2w to buffer
        tNewBuff = t+maxDelta;
        index = 1+mod(tNewBuff,nBuff); %mymod(tNewBuff,nBuff);
        e1w(index,:) = e1((tNewBuff-nHalfW):(tNewBuff+nHalfW)) .* w;
        e2w(index,:) = e2((tNewBuff-nHalfW):(tNewBuff+nHalfW)) .* w;
        
        index1 = 1 + mod(t-delta,nBuff);
        index2 = 1 + mod(t+delta,nBuff);
        R(t,1:numel(delta)) = sum(e1w(index1,:).*e2w(index2,:),2)';
    end
%**************************************************************************
% tShift converts the sample shift indices indShift into actual time values using sampleFreq, making the lag interpretation in seconds.
    tShift = delta * 2/sampleFreq;
end
       
function c = mymod(a,b)
    c = 1+mod(a,b);
end
            
            
            
