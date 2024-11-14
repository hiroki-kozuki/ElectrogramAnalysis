%close all

% 1) Load Data:
clear all
if false
    load('testData.mat')
else
    load('testData2.mat')
end

ind = 1:1300; % Select signal subset.
%e1 = e1(ind); e2 = e2(ind); e3 = e3(ind);

% 2) Define Parameters:
tWindowWidth = 30/1000;
tMaxLag = 20/1000;
sampleFreq = 2034.5;
noiseLevel = 1.5*10^(-5);
f = 1;

% 3) Triangulation and Edge Setup:
x = [0,0;0,1;1,1];
t = [1,2,3];
t = triangulation(t,x);
e = t.edges;


% 4) Calculate Cross-Correlation and Shift:
[RXY, tShift, indShift, RXX, RYY ] = egmcorr(e1,e2,sampleFreq, tWindowWidth, tMaxLag);
[shift, shiftAlt, SCORE] = generatewarpshift(RXY, RXX, RYY, noiseLevel);
shiftNew = finessewarpshift(shift);

% 5) Interpolate between Signals:
eInterp = interpegm(e1, e2, shiftNew, [0:.1:1]);


% 6) Visualization:

% Initial Signals and Correlations:
figure
plot(e1,'y')
hold on
plot(e2,'y')
plot(RXY*200,'g','LineWidth',2)
plot(RXX*200,'b','LineWidth',2)
plot(RYY*200,'r','LineWidth',2)
set(gca,'Xlim', [ind(1) ind(end)])
%yyaxis right
%plot(iDelta, 'k')

        % Correlation Matrices:
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

% Interpolated Signals:
figure
plot(eInterp,'g','LineWidth',1)
hold on
plot(e1,'b','LineWidth',3 )
plot(e2,'r','LineWidth',3 )

plot(shiftNew / 100, 'c', 'LineWidth',3)
plot(shift / 100, 'k', 'LineWidth',3)



