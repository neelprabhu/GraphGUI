function dt = setVVoronoi(handles)

% @author Neel K. Prabhu

masterData = handles.masterData;
VALL = masterData(1).VALL;
EALL = masterData(1).EALL;
vMatrix = zeros(numel(VALL),2);

for n = 1:numel(VALL)
    VALL{n} = VALL{n}';
    if ~isnan(VALL{n}(1))
        vMatrix(n,:) = VALL{n};
    end
end
vMatrix = unique(vMatrix,'rows','stable');
dt = delaunayTriangulation(vMatrix);