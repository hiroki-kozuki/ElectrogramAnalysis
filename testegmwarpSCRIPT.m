e1 = uni_filtered3(:,2);
e2 = uni_filtered3(:,3);
close all



tWindowWidth = 30/1000;
tMaxLag = 20/1000;

[R, tShift, indShift, R11, R22 ] = egmcorr(e1,e2,egmFreq, tWindowWidth, tMaxLag);

	[Rmax, iDelta] = max(R, [],2);
	tDiff = tShift(iDelta);
    

noiseLevel = 1/100*10^(-3);
R(R<noiseLevel) = NaN;
R11(R11<noiseLevel) = NaN;
R22(R22<noiseLevel) = NaN;

ind = 3700:4700;
ind = 1:numel(e1);


figure
plot(e1,'y')
hold on
plot(e2,'y')
plot(Rmax*200,'g','LineWidth',2)
plot(R11*200,'b','LineWidth',2)
plot(R22*200,'r','LineWidth',2)
set(gca,'Xlim', [ind(1) ind(end)])
%yyaxis right
%plot(iDelta, 'k')

[shift, shiftAlt, SCORE] = generatewarp(R(ind,:), R11(ind,:), R22(ind,:));

figure
plot(e1)
hold on
plot(e2)
set(gca,'Xlim', [ind(1) ind(end)])
plot(shift / 100, 'k', 'LineWidth',3)



%plot(tDiff*egmFreq/10, 'k')
return
figure
for i = 1:10:size(uni_filtered3,1)
i
plot(tShift,R(i+(1:30),:));
pause
end