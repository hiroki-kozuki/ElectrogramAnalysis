function [shift, shiftAlt, SCORE] = generatewarpshift(RXY, RXX, RYY, noiseLevel)
% GENERATEWARP We will create and then modify a SCORE matrix (as opposed to
% COST, we are trying to maximse a score not minimise cost) which consists
% of ... SCORE(index,indshift) where index is the time index into the
% signal e1 and indshift is the shift is the best shift between 1 and 2
% (see egmcorr). Note that this corresponds to the central diagonal band in
% the cost matrix that is more commonly used (see: Multi-Functional Sensing
% for Swarm Robots Using Time Sequence Classification: HoverBot, an
% Example).
%   
%
%
% Rules are as follows:
%   1. when R11 or R12 is below the noise threshold then no shift is
%   applied and one of the signals is held such that shift decreases
%   towards zero.
%
%   2. with a change in time of one index, the shift cannot change by more
%   than +/-1 (this corresponds to one signal being held stationary whilst
%   the other moves.
%
%
%
%
%
% Author: Nick Linton (2020)
% Added comments by Hiroki (2024)
% Modifications - 


% Info on Code Testing:
						% ---------------------
                        % test code
                        % ---------------------



% ---------------------------------------------------------------
% code
% ---------------------------------------------------------------

        debug = true;
        debug = false;
        if debug; hPScore = []; end

    % noiseLevel = 1.5*10^(-5);


    SCORE = RXY; % Initialise SCORE as a copy of RXY representing the alignment quality for each time index and shift.
    [nRows, nCols] = size(SCORE);
    cMid = (nCols+1)/2; 
    indShift = (1:nCols) - cMid; % Array of possible shifts (column indices) in the cross-correlation matrix, with the center shift (cMid) representing zero lag.

    % now in this matrix,   indX-> (rX,cX) <=> rX=indX,     rC = all;
    %                       indY-> (rY,cY) <=> rY=indY-n    rC = cMid-n
    % so ... 
    %   to set or retrieve all numbers at indX=ix, use C(ix,:)
    %   to set or retrive all numbers at indY=iy, use nested_indX2indC(indX)



    % *************************************************************************
    % set the SCORE to NaN for 
    %   i) the start and end of the matrix (to avoid edge effects)
    %   ii) RYY below noise (corresponding to regions with weak signals)
    %   iii) RXX below noise (corresponding to regions with weak signals)
    %   iv) RXY below noise
    
    RXX(RXX<noiseLevel) = NaN;
    RYY(RYY<noiseLevel) = NaN;
    RXY(RXY<noiseLevel) = NaN;
    
    
    % i)
    SCORE(1:nCols,:) = NaN;
    SCORE((end-nCols-1):end,:) = NaN;

    %ii)
    iYbad = isnan(RYY);
    SCORE(iYbad,cMid) = NaN;
    iYbad_lead = iYbad;     iYbad_lag = iYbad;
    
    for i = 1:(cMid-1)
                            if debug; nested_debug0(); end
        iYbad_lead = [iYbad_lead(2:end)    ; false];
        SCORE(iYbad_lead,cMid+i) = NaN;

        iYbad_lag  = [false; iYbad_lag(1:(end-1))];
        SCORE(iYbad_lag,cMid-i) = NaN;
    end
    
    % iii)
    iXbad = isnan(RXX);
    SCORE(iXbad,:) = NaN;
        if debug; nested_debug0(); end
  
    % iv)
    iXYbad = isnan(RXY);
    SCORE(iXYbad) = NaN;
        if debug; nested_debug0(); end
    
    % *************************************************************************
    % Peak Identification and Scoring:
    % Finding Peaks: After filtering for noise, SCORE is processed to identify local maxima using imregionalmax, which flags points that represent the best potential shifts for alignment.
    % Peaks are sorted by score value in descending order, allowing the function to prioritize higher-confidence shifts for alignment.
    
    if debug; nested_debug1(); end

    % find all of the peaks in SCORE
    temp = SCORE;
    temp(isnan(temp)) = 0;
    BW = imregionalmax(temp,4); % imregionalmax returns the binary image BW that identifies the regional maxima in grayscale image I. 4 specifies the pixel connectivity.
    [peakRow, peakCol] = find(BW); % find returns a vector containing the linear indices of each nonzero element in array BW.
    peakVal = SCORE(sub2ind(size(SCORE),peakRow,peakCol)); % ind = sub2ind(sz,row,col) returns the linear indices ind corresponding to the row and column subscripts in row and col for a matrix of size sz.

    % This will be used to store the column number that gives the best shift for the signals.
    % shift and shiftAlt are arrays for storing the best alignment shift at each time index.
    shiftAlt = nan(nRows,1);
    shift = nan(nRows,1);


    % Constructing the Shift Paths:
    % The function iteratively follows each peak in SCORE (starting from the highest) to build a smooth alignment path. It does this by:
    % Selecting the highest SCORE value (representing the best alignment shift) at each time point.
    % Limiting the change in shift to +/-1 per time index, ensuring smoothness in alignment.
    % This step constructs the main and alternative shift paths for alignment.

    %sort with largest peak first
    [peakVal , i] = sort(peakVal,'descend');
    peakRow = peakRow(i); % Sort row in descending order of PeakVal. 
    peakCol = peakCol(i); % Sort column in descending order of PeakVal. 
    
    if debug; nested_debug2(); end

    while (~isempty(peakVal) && ~isnan(peakVal(1))) % while peakVal is not empty and the largest peak is not NAN:
        %take the largest peak that is still in the running
        r = peakRow(1);
        c = peakCol(1);

        nested_followdownpeak(r,c,+1);
        nested_followdownpeak(r,c,-1);

        if debug; nested_debug2(); end
    end

    % Shift Adjustment: 
    % After constructing shift and shiftAlt, the zero-lag center is adjusted by subtracting cMid, providing the final time shifts needed to align the signals.
    % a shift of cMid corresponds to zero ...
    shift = shift - cMid;
    shiftAlt = shiftAlt - cMid;
    
    
    return;






%**************************************************************************
% nested functions
%**************************************************************************
            
    function nested_followdownpeak(r,c,direction)
    % This function iteratively follows a peak in SCORE, adjusting the shift in a way that ensures smooth transitions and removes bad peaks.
        cAtPeak = c;
        currentScore = SCORE(r,c);
        % we will check r,c which we don't need to, but makes code shorter
        while ~isnan(currentScore) % While current score is not NAN:
            cChoice = max(c-1,1):min(c+1,nCols); % we can only move one column along for each new row
            cScores = SCORE(r,cChoice);
            [cBestScore,iBest] = max(cScores);
            if isnan(cBestScore)
                return % we have reached the edge of this peak
            elseif cBestScore > currentScore
                return % we are going uphill, so must be starting up a different peak
            else
                currentScore = cBestScore;
                c = cChoice(iBest);
                shiftAlt(r) = c;
                shift(r) = cAtPeak; % we could use c, but we want electrogram distortion to be minimal
                nested_removebadpeaks(r,c);
            end
            
            r = r+direction; % and now start to roll along
            
        end
    end

    function nested_removebadpeaks(r,c)
    % This function deletes peaks that no longer qualify as local maxima due to new adjustments in SCORE.
        rowDiff = peakRow - r;
        colDiff = peakCol - c;
        
        badPeaks = abs(colDiff) >= abs(rowDiff);
        peakVal(badPeaks) = [];
        peakRow(badPeaks) = [];
        peakCol(badPeaks) = [];
    end

%**************************************************************************
% nested functions for debugging and visualisation
%**************************************************************************
% nested_debug0, nested_debug1, and nested_debug2 are included to allow visual inspection of SCORE, peak positions, and shift paths during debugging.

    function nested_debug0()
        if isempty(hPScore)
            figure;
        else
            delete(hPScore)
        end
            hPScore = pcolor(SCORE');
        set(hPScore, 'EdgeColor','none')
        set(gca, 'YDir','reverse')
        pause
    end
    
    
    
    function nested_debug1()
        figure
        hold on
        plot(RXY, 'g','LineWidth',2)
        plot(RXX, 'b','LineWidth',2)
        plot(RYY, 'r','LineWidth',2)
        %set(gca,'Xlim', xlim)
        figure
        surf(SCORE, 'EdgeColor','none')
        figure
        h = pcolor(SCORE');
        hold on
        set(h, 'EdgeColor','none')
        set(gca, 'YDir','reverse')
        axis equal
        axis tight
        %set(gca,'Ylim', xlim)
    end
    function nested_debug2()
        persistent hPeaks hShift
        try; delete(hPeaks);delete(hShift); end %#ok<NOSEMI,TRYNC>
        hPeaks = plot(peakRow,peakCol,'*r','MarkerSize',5);
        hShift = plot(1:nRows,shiftAlt,'r');
        pause
    end
            
end



    
