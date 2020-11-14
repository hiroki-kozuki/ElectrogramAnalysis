function [R, tShift] = egmcorr(e1,e2,sampleFreq, tWindowWidth, tMaxLag)
% EGMCROSSCORRELATE 
% Make sure to choose tWindowWidth to minimise mains pickup (ie 20ms is a
% bad choice)
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
    nW = tWindowWidth*sampleFreq;
    nHalfW = floor(nW/2);
    nW = 2*nHalfW+1;
    w = kaiser(nW,2);
    
    maxDelta = ceil(tMaxLag * sampleFreq / 2);
    delta = -maxDelta:maxDelta;
        
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
    nBuff = numel(delta);
    e1w = zeros(nBuff, numel(w));
    e2w = zeros(nBuff, numel(w));
    tFirst = k + 1;
    
    for i = (tFirst-maxDelta):(tFirst+maxDelta)
        index = 1 + mod(i,nBuff);
        e1w(index,:) = e1((i-nHalfW):(i+nHalfW)) .* w;
        e2w(index,:) = e2((i-nHalfW):(i+nHalfW)) .* w;
    end
    
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

    tShift = delta * 2/sampleFreq;
end
       
function c = mymod(a,b)
    c = 1+mod(a,b);
end
            
            
            