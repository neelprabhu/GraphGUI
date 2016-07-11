function dt = setVVoronoi(handles)

% @author Neel K. Prabhu

masterData = handles.masterData;
VALL = masterData(handles.f).VALL;
EALL = masterData(handles.f).EALL;
vMatrix = zeros(numel(VALL),2);

counter = 0;
for n = 1:numel(VALL)
    VALL{n} = VALL{n}';
    if ~isnan(VALL{n}(1))
        vMatrix(n,:) = VALL{n};
    else
        vMatrix(n,:) = [counter counter];
        counter = counter - 1;
    end
end
dt = delaunayTriangulation(vMatrix);