 close all
clear all
load('C:\Users\nick\Documents\NickData\NickMatlab\Library\GridProcessing\sample_1.mat')


% Plot the bipolars
space = 2;
data = egmBIP;
data = bsxfun(@plus,data,space*(1:size(data,2)));

h1 = subplot(2,2,1);
plot(data);

% Plot the unipolars
uni = egmUNI;

% take the difference from the shaft
uni = bsxfun(@minus,uni,uni(:,18));
%uni(uni>0) = 0;

uni = uni(:,1:16);


% do the Hilbert transform
hilb = hilbertkernel(30);
hilb(1:2:end) = [];
hilb = hilb .* tukeywin(numel(hilb),0.3);
uniHilb = conv2(uni,hilb(:),'same');

% do the windowing
nW = 31;
w = tukeywin(nW,0.5);
w = w / sum(w);
centre = (nW+1)/2;
w = -w;
w(centre) = w(centre)+1;


uniHilb2 = conv2(uniHilb,w(:),'same');


[x,y] = meshgrid(1:4,1:4);
p = [x(:) , y(:)];
tri = delaunayTriangulation(p);

newSpace = 0.05;
[xNew,yNew] = meshgrid(1:newSpace:4,1:newSpace:4);
pNew = [xNew(:) , yNew(:)];



sampleFreq = 2034.5;
noiseLevel = 1.5*10^(-5);
eInterp = interpegm(pNew, tri, uniHilb2, sampleFreq, noiseLevel);

eInterp = reshape(eInterp,[size(eInterp,1) size(xNew)]);


hFig = figure();
i = 1;

hS = mesh(xNew, yNew, squeeze(eInterp(i,:,:)));
hold on
set(hS,'EdgeColor','k')
set(gca, 'ZLim',[-2 8])
for iE = 1:16
    hE(iE) = plotsphere(x(iE),y(iE),0,'k', 0.2, 5);
    z{iE} = get(hE(iE),'ZData')/1;
    set(hE(iE), 'ZData',z{iE});
end

pause



[filename,pathname] = uiputfile('*.*','Save Movie As');
if filename == 0;
    hMov = [];
else
    
    hMov = VideoWriter([pathname filename], 'MPEG-4');
    set(hMov    , 'FrameRate' , 60 ...
        , 'Quality' , 40 ...
        );
    open(hMov);
    finishup = onCleanup(@() close(hMov));
end





tic
for i = 1:1:size(eInterp,1)
    set(hS,'ZData',squeeze(eInterp(i,:,:)))
    for iE = 1:16
        set(hE(iE), 'ZData',z{iE}+uniHilb2(i,iE));
    end
    drawnow()
    
    if ~isempty(hMov)
        position = get(hFig,'Position');
        height = position(4); height = floor(height/4) * 4;
        width = position(3);  width = floor(width/4) * 4;
        
        m = getframe(hFig, [0 0 width height]);
        writeVideo(hMov,m);
    end
    i
    toc
    tic
end











