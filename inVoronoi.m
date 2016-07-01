function [vIndex] = inVoronoi(vVertices,vRegions,clickPoint)

allVX = vVertices(:,1);
allVY = vVertices(:,2);

for m = 1:numel(vRegions)
    Index = [vRegions{m} vRegions{m}(1)];
    X = allVX(Index);
    Y = allVY(Index);
    if inpolygon(clickPoint(1),clickPoint(2),X,Y)
        vIndex = m;
        break;
    end
end