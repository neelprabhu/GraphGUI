%% Run this file to start workflow.

% @author Neel K. Prabhu, Virginia Cheng, Cheng Lu

function startup
addpath(pwd);
addpath(genpath(fullfile(pwd, 'gui')));
% Create figure
h.f = figure('units','pixels','position',[500,500,200,150],...
             'toolbar','none','menu','none','name','Data+ GUI','NumberTitle','off');
% Create yes/no checkboxes
h.c(1) = uicontrol('style','checkbox','units','pixels',...
                'position',[35,100,200,20],'string','First-Time Sequence');
h.c(2) = uicontrol('style','checkbox','units','pixels',...
                'position',[35,50,200,20],'string','Preprocessed Sequence');    
% Create OK pushbutton   
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[50,5,70,20],'string','GO',...
                'callback',@p_call);
    % Pushbutton callback
    function p_call(varargin)
        vals = get(h.c,'Value');
        checked = find([vals{:}]);
        if isempty(checked)
            checked = 'none';
        end
        if checked == 1
            closereq;
            Segmentation;
        elseif checked == 2
            closereq;
            GraphGUI;
        else
            fprintf('Please choose a selection!\n')
        end
    end
end

