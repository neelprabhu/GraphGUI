function dt = setVoronoi(handles)

%@author Neel K. Prabhu

masterData = handles.masterData;
VALL = masterData(1).VALL;
vMatrix = zeros(numel(VALL),2);
for n = 1:numel(VALL)
    VALL{n} = VALL{n}';
    vMatrix(n,:) = VALL{n};
end

dt = delaunayTriangulation(vMatrix);