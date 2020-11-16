close all
clear all
if false
    load('testData.mat')
else
    load('testData2.mat')
end

ind = 1:1300;
%e1 = e1(ind); e2 = e2(ind); e3 = e3(ind);
egm = [e1,e2,e3,e3*0];

tWindowWidth = 30/1000;
tMaxLag = 20/1000;
sampleFreq = 2034.5;
noiseLevel = 1.5*10^(-5);
f = 1;

x = [0,0;0,1;1,0;1,1];
tri = [1,2,3;2,3,4];
tri = triangulation(tri,x);
ed = tri.edges;

[xNew, yNew] = meshgrid(0:.1:1,0:.1:1);
pNew = [xNew(:) , yNew(:)];

eInterp = interpegm(pNew, tri, egm, sampleFreq, noiseLevel);

eInterp = reshape(eInterp,[size(eInterp,1) size(xNew)]);

figure
plot(squeeze(eInterp(:,:,1)))
hold on
plot(egm(:,[1,2]),'k','LineWidth',3)


figure
plot(squeeze(eInterp(:,1,:)))
hold on
plot(egm(:,[1,3]),'k','LineWidth',3)


figure
plot(squeeze(eInterp(:,6,6)))
hold on
plot(egm(:,[2,3]),'k','LineWidth',3)





