function dt = setEVoronoi(handles)

% @author Neel K. Prabhu

masterData = handles.masterData;
EALL = masterData(1).EALL;
eMatrix = zeros(numel(EALL),2);

for m = 1:numel(EALL)
    if isempty(EALL{m})
        continue;
    else
        ctrl = EALL{m}.control;
        num = round(size(ctrl,2)/2);
        point = ctrl(:,num)';
        eMatrix(m,:) = point;
    end
end
    
dt = delaunayTriangulation(eMatrix);