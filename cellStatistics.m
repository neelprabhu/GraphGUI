function [cellArea, cellPerimeter] = cellStatistics(data,ALL,cellPoints)
% Computes biologically useful parameters, such as cell areas and
% perimeters, from a pre-processed image stack.
% 
% INPUTS
% data: A struct containing a cell array of vertices (VALL), cell array of
% edge structs (EALL), and ADJLIST/FACELIST structs.
% cellPoints: (2 x 1) column vectors representing points inside each of the
% cells to be measured.
%
% OUTPUTS
% cellArea: A matrix with cell areas measured in pixels^2.
% cellPerimeter: A matrix with cell perimeters measured in pixels^2.
%
% @author Neel K. Prabhu

