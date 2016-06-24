function [vertexIndex] = eucDistance(VALL,clickPoint)
% Computes the distance from a clicked point to all vertices, and returns
% the index of the vertex closest to the clicked point
%
% INPUTS
% VALL: (N x 1) cell array of vertices. Entry i is a (2 x 1) column 
% vector representing the R^2 coordinates of the ith vertex.
% clickPoint: (2 x 1) column vector representing the R^2 coordinates of
% user click inside the image.
%
% OUTPUTS
% vertexIndex: An integer representing the index of closest vertex.
%
% Neel K. Prabhu

%% Format data
vMatrix = zeros(2,numel(VALL));
for n = 1:numel(VALL)
    vMatrix(:,n) = VALL{n};
end
clickPoint = repmat(clickPoint,1,n);

%% Compute distances
diff = vMatrix - clickPoint;
diff = diff.^2;
sums = sum(diff);
sums = sqrt(sums);
[~,vertexIndex] = min(sums);