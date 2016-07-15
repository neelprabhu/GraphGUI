format short g;
format compact;
% Testing

%% load images
global TIFF; global tiffOUT; global frame_range;
global minX; global maxX; global minY; global maxY; global ALL;
GT = imread('myGT.png');
ALL = TIFF;
tiffOUT = transfer(ALL);
%xrange = minX:maxX; yrange = minY:maxY; % crop data set
%ALL = ALL(:,:,:);
%GT = GT(:,:);
GT = padarray(GT, [20,20]); % zero padding to avoid crashing due to sampling outside image
ALL = padarray(ALL, [20,20,0]);

%% optimization

% algorithm parameters
l = 17;                 % width of edge window
w = 25;                 % width of vertex window
alpha = 0.5;            % scaling edge cost contributions
interval = 1;           % merge vertices if distance is less or equal
spacing = 15;           % spacing of control points on splines
parallel = false;       % parallelization with parfor
verboseE = 0;           % verbose flag for edge optimization
verboseG = 0;           % verbose flag for vertex optimization
siftflow = true;        % SIFT flow flag
fname = ['tmp_grid2_', datestr(clock, 'mmddyy_HH:MM:SS')];
options = struct('l',l,'w',w,'alpha',alpha,'interval',interval, ...
    'spacing',spacing,'parallel',parallel,'verboseE',verboseE, ...
    'verboseG',verboseG,'siftflow',siftflow,'fname',fname);

%track graph
t1 = tic;
data = membraneTrack(ALL, GT, options);     % this is the function that performs the tracking
disp('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
toc(t1);

%% clean up

% save relevant variables
save('z_data.mat', 'data');  % data is a struct that stores all raw tracing information


% create tracking movie
Movie = [];
for ii=1:size(ALL,3)
    fig = displayGraph(ALL(:,:,ii), data(ii).VALL, data(ii).EALL, 'on');    % function parses the data struct to display tracks over original image
    Movie = [Movie, immovie(print(fig, '-RGBImage'));];                     % save current frame to movie
    close(fig);
end

%fig = displayGraphcustom(ALL(:,:,2), data(2).VALL, data(2).EALL, 'on',data(1).VALL,data(1).EALL);
fnameall = 'new_movie.avi';
writerObj = VideoWriter(fnameall);  % create VideoWriter object to write frames to AVI movie
writerObj.FrameRate = 2; writerObj.Quality = 100;
open(writerObj); writeVideo(writerObj, Movie); close(writerObj);