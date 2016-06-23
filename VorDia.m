function [vVertices, vRegions, clickedRegion] = VorDia(VALL,clickPoint)
% Constructs the Voronoi diagram for a set of vertices in R^2 and returns
% the index of the Voronoi region that was clicked by the user.
%
% INPUTS
% VALL: (N x 1) cell array of vertices. Entry i is a (2 x 1) column 
% vector representing the R^2 coordinates of the ith vertex.
% clickPoint: (2 x 1) column vector representing the R^2 coordinates of
% user click inside the image.
%
% OUTPUTS
% vVertices: (M x 2) matrix with Voronoi vertex coordinates along each row.
% vRegions: A cell array of length equal to the number of elements in VALL,
% elements of vRegions are row numbers of vVertices.
% clickedRegion: Integer representing the index of nearest vertex clicked.
%
% Neel K. Prabhu

%% Check inputs
if nargin < 1 || isempty(VALL)
    error('No vertices provided!')
end
if nargin < 2 || isempty(clickPoint)
    clickPoint = [];
end

%% Format data
vMatrix = zeros(numel(VALL),2);
for n = 1:numel(VALL)
    VALL{n} = VALL{n}';
    vMatrix(n,:) = VALL{n};
end

%% Create Voronoi diagram
DT = delaunayTriangulation(vMatrix);
[vVertices,vRegions] = voronoiDiagram(DT);

%% Plot stuff
figure(1)
for m = 1:numel(vRegions)
    drawVorPoly(vVertices,vRegions{m})
    hold on
%     for q = 1:numel(vRegions{m})
%         plot(vVertices(vRegions{m}(q),1),vVertices(vRegions{m}(q),2))
%         hold on
%     end
end
plot(vMatrix(:,1),vMatrix(:,2),'r.','MarkerSize',10)
set(gca,'XLim',[25 175]); set(gca,'YLim',[25 175]);

function drawVorPoly(vList,relList)

allVX = vList(:,1);
allVY = vList(:,2);
X = allVX(relList);
Y = allVY(relList);
plot(X,Y,'b-')

%% Check region clicked
% if isempty(clickPoint)
%     fprintf('No point clicked.\n')
% else
%     clickedRegion = inVoronoi(vVertices,vRegions,clickPoint);
% end