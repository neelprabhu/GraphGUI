% function [dt,assoc] = setEVoronoi(handles)
% 
% % @author Neel K. Prabhu
% 
% % assoc is an (m x 1) cell array. For edge i, assoc{i} is a row vector of
% % control point indices that belong to each edge.
% 
% masterData = handles.masterData;
% EALL = masterData(handles.f).EALL;
% ctrl = EALL{1}.control; 
% ctrl = ctrl(:,2:size(ctrl,2)-1)';
% eMatrix = ctrl; % Takes care of first entry.
% assoc{1} = [1:length(EALL{1}.control)-2];
% 
% for m = 2:numel(EALL)
%     if ~isempty(EALL{m})
%         ctrl = EALL{m}.control; ctrl = ctrl(:,2:size(ctrl,2)-1)';
%         eMatrix = [eMatrix; ctrl];
%         assoc{m,1} = [(assoc{m-1}(end)+1):(assoc{m-1}(end)+length(ctrl))];
%         %num = round(size(ctrl,2)/2);
%         %point = ctrl(:,num)';
%     else
%         assoc{m} = [];
%         %eMatrix(m,:) = [counter counter];
%         %counter = counter - 1;      
%     end
% end 
% dt = delaunayTriangulation(eMatrix);

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