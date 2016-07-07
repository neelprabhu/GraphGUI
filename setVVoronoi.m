function dt = setVVoronoi(handles)

% @author Neel K. Prabhu

masterData = handles.masterData;
VALL = masterData(1).VALL;
EALL = masterData(1).EALL;
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
%vMatrix = unique(vMatrix,'rows','stable');
dt = delaunayTriangulation(vMatrix);
axes(gca)
triplot(dt,'g','LineWidth',1)