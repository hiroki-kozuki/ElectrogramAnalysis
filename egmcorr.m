function [RXY, tShift, indShift, RXX, RYY ] = egmcorr(eX,eY,sampleFreq, tWindowWidth, tMaxLag)
% EGMCROSSCORRELATE 
% Make sure to choose tWindowWidth to minimise mains pickup
% Author: Nick Linton (2020)
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
    
    % make column vectors (data access faster in columns of matrices)
    eX = eX(:); eY = eY(:);
    
    % create window
    nW = tWindowWidth*sampleFreq; % Window length counted in terms of number of sample indices. 
    nHalfW = floor(nW/2);
    nW = 2*nHalfW+1;
    w = kaiser(nW,2); % Apply a Kaiser window (beta = 2) to smooth the edges of the time window. This helps reduce artifacts from sharp transitions at window boundaries.
    % normalise
    w = w/sum(w);
    
    maxDelta = ceil(tMaxLag * sampleFreq); % Maximum lag counted in terms of number of samples. 
    indShift = -maxDelta:maxDelta; % List of all possible shifts in sample indices based on tMaxLag.
    indShiftZero = 1+maxDelta; 
        
    k = nHalfW+indShift(end); 

    
    
% *************************************************************************
% This is the simple version of the code, which is slow
%**************************************************************************
%     R = NaN(numel(eX),numel(delta));
%     for t = (k+1):(numel(eX)-k);
%             eXw = eX((t-nHalfW):(t+nHalfW)) .* w;
%         for j = 1:numel(delta);
%             d = delta(j);
%             eYw = eY((t-nHalfW+d):(t+nHalfW+d)) .* w; %this will be calculated multiple times for various t/j
%             R(t,j) = eXw'*eYw;
%         end
%     end
    



% *************************************************************************
% This is the more complicated version of the code, which is faster.
% For each value of t above, we need eYw centred on t-d to t+d, ie t+delta(:)
%**************************************************************************
% eYwB is going to be an n*numel(w) array - eY 'windowed' and buffered. By buffering eY in this way, the function avoids recalculating windows of eY each time it shifts; \
% instead, it rotates through the buffer, reducing computation time.
    nBuff = numel(indShift);
    eYwB = zeros(numel(w), nBuff); %B for buffer
    tFirst = k + 1;
    
    for i = (tFirst-maxDelta):(tFirst+maxDelta)
        index = 1 + mod(i,nBuff);
        eYwB(:,index) = eY((i-nHalfW):(i+nHalfW)) .* w;
    end
    
    RXY = zeros(numel(eX),numel(indShift));
    RXX = zeros(numel(eX),1);
    RYY = zeros(numel(eX),1);
    for t = tFirst:(numel(eX)-k)
        % add next eXw and eYw to buffer
        tNewBuff = t+maxDelta;
        index1 = 1+mod(tNewBuff,nBuff); %mymod(tNewBuff,nBuff);
        eYwB(:,index1) = eY((tNewBuff-nHalfW):(tNewBuff+nHalfW)) .* w;
        
        eXw = eX((t-nHalfW):(t+nHalfW)) .* w;
        index2 = 1 + mod(t+indShift,nBuff); % i.e. eYw(t+delta,:)
        eYw_shifted = eYwB(:,index2);
        
        
        RXY(t,1:numel(indShift)) = (eXw'*eYw_shifted);
        RXX(t) = (eXw'*eXw);
        
        index3 =  1 + mod(t,nBuff); % i.e. eYw(t+delta,:)
        eYw = eYwB(:,index3);
        RYY(t) = (eYw'*eYw);
    end
%**************************************************************************

    tShift = indShift * 2/sampleFreq;
end
