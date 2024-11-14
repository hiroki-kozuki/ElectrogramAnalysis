% Added comments by Hiroki (2024)
 
 close all
clear all
load('C:\Users\nick\Documents\NickData\NickMatlab\Library\GridProcessing\sample_1.mat') % Load data


% 1) Data Preparation and Plotting:
% Plot the bipolars
% Bipolar signals are arranged with some vertical spacing to aid visualization.
space = 2;
data = egmBIP;
data = bsxfun(@plus,data,space*(1:size(data,2)));

h1 = subplot(2,2,1);
plot(data);

% Plot the unipolars
uni = egmUNI;

% take the difference from the shaft (subtracting the reference signal at channel 18 and trimming to focus on the first 16 channels.)
uni = bsxfun(@minus,uni,uni(:,18));
%uni(uni>0) = 0;

uni = uni(:,1:16);


% 2) Hilbert transform on unipolar signals:
% Hilbert kernel (hilb) is calculated, reduced to a lower dimension by taking every other element, and windowed with a Tukey window to reduce edge effects.
hilb = hilbertkernel(30);
hilb(1:2:end) = [];
hilb = hilb .* tukeywin(numel(hilb),0.3);
% Hilber kernel is applied to the unipolar signals (uni) using convolution. 
% This yields a Hilbert-transformed signal (uniHilb), which gives an analytic signal emphasizing phase information.
uniHilb = conv2(uni,hilb(:),'same');


% 3) Windowing to Smooth Signal:
% Window is applied to the Hilbert-transformed signal to further smooth it. 
% We use a normalized Tukey window with adjusted weights centered around zero to help retain signal features while smoothing.
nW = 31;
w = tukeywin(nW,0.5);
w = w / sum(w);
centre = (nW+1)/2;
w = -w;
w(centre) = w(centre)+1;

uniHilb2 = conv2(uniHilb,w(:),'same');


% 4) Spatial Interpolation Set-up:
[x,y] = meshgrid(1:4,1:4); % 4x4 grid of points representing electrode locations.
p = [x(:) , y(:)];
tri = delaunayTriangulation(p); % Delaunay triangulation (tri) is created on these points to model spatial relationships.

% A finer grid (pNew) is generated for spatial interpolation, where newSpace controls the resolution.
newSpace = 0.05;
[xNew,yNew] = meshgrid(1:newSpace:4,1:newSpace:4);
pNew = [xNew(:) , yNew(:)];


% 5) Electrogram Interpolation using interpegm on finer grid (pNew):
sampleFreq = 2034.5;
noiseLevel = 1.5*10^(-5);
eInterp = interpegm(pNew, tri, uniHilb2, sampleFreq, noiseLevel);
% Interpolated data is reshaped to match the spatial dimensions of the new grid (xNew, yNew).
eInterp = reshape(eInterp,[size(eInterp,1) size(xNew)]);


% 6) 3D Plot Setup:
hFig = figure();
i = 1;

% Interpolated data for the first time frame is plotted as a 3D mesh on the grid defined by (xNew, yNew). 
% This creates a 3D surface showing the spatial distribution of the interpolated EGMs.
hS = mesh(xNew, yNew, squeeze(eInterp(i,:,:)));
hold on  % Retain the current plot while adding new plot.
set(hS,'EdgeColor','k')
set(gca, 'ZLim',[-2 8])

% plotsphere is used to add spheres at electrode positions. 
% Each electrode’s z-position (ZData) is adjusted based on the Hilbert-transformed signals (uniHilb2).
for iE = 1:16 % For each electrode:
    hE(iE) = plotsphere(x(iE),y(iE),0,'k', 0.2, 5);
    z{iE} = get(hE(iE),'ZData')/1;
    set(hE(iE), 'ZData',z{iE});
end

pause


% 7) Video Recording Setup:
% A video writer is set up to save the animated visualization.
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


% 8) Animation Loop:
% In each iteration, the Z-data of the mesh plot (hS) is updated to the interpolated EGM values for the current time frame.
% Each electrode sphere’s Z-position is updated according to uniHilb2 to refelct changes in the EGM data over time.
% If hMov is active, each frame is captured and written to the video file.
tic % Records current time
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
    toc % Calculates elapsed time since tic
    tic % Records current time
end











