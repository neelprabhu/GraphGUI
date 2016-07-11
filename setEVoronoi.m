function dt = setEVoronoi(handles)

% @author Neel K. Prabhu

masterData = handles.masterData;
EALL = masterData(handles.f).EALL;
eMatrix = zeros(numel(EALL),2);

counter = 0;
for m = 1:numel(EALL)
    if ~isempty(EALL{m})
        ctrl = EALL{m}.control;
        num = round(size(ctrl,2)/2);
        point = ctrl(:,num)';
        eMatrix(m,:) = point;
    else
        eMatrix(m,:) = [counter counter];
        counter = counter - 1;
    end
end 
dt = delaunayTriangulation(eMatrix);