function [vH,eH,cpH] = customdisplayGraph(I, V, E, visible)
%DISPLAYGRAPH Displays graph with splines and vertices
% 
% INPUTS
% I: (2D matrix) image.
% V: cell array of 2D vectors of vertices.
% Splines: cell array of spline structs.
% visible: {'on (default)', 'off'} whether the figure is visible.
% 
% OUTPUTS
% H: Plot handle
% 
% @author Roger Zou
% @date 5/19/15

% validate input
if nargin < 4 || isempty(visible)
    visible = 'on';
end
 
% get lengths
N = length(V);
M = length(E);

% setup figure
hold on;
imagesc(I)
colormap gray
set(gca,'visible','off')
axis equal;

vH = cell(size(V,1),1);
for ii=1:N
    
    % get current vertex
    v_i = V{ii};
    
    % draw the vertices
    if ~sum(isnan(v_i)) && ~isempty(v_i)
        vH{ii} = plot(v_i(1), v_i(2),'ro',...
            'MarkerSize',9,...
            'MarkerEdgeColor','r',...
            'MarkerFaceColor','r');
    end
end

eH = cell(size(E,1),1);
cpH = cell(100,1);
% draw the splines
for ii=1:M
    
    % get current spline
    si = E{ii};
    
    % draw the spline and the sample points on it
    if ~isempty(si)
        eH{ii} = line(si.curve(1,:), si.curve(2,:), 'Color', 'y', 'LineWidth', 3);
        cpH{ii} = plot(si.control(1, :), si.control(2, :), 'b.-', ...
            'MarkerSize', 20, 'Visible', 'off');
    end
    
end
end