function splineGUI(control)
%nctr = 5; 


%control = [1:nctr; zeros(1, nctr)];

state.handles = example(control);
state.d.control = control;
state.d.open = true;

axis ij
axis off
state = redraw(state);

state.pointIdx = 0;
state.cp = NaN;
state.np = size(state.d.control, 2);
state.scale = 1;

zoom off;

state.WindowButtonDownFcn = get(gcf, 'WindowButtonDownFcn');
state.WindowButtonMotionFcn = get(gcf, 'WindowButtonMotionFcn');
state.WindowButtonUpFcn = get(gcf, 'WindowButtonUpFcn');
state.CloseRequestFcn = get(gcf, 'CloseRequestFcn');
state.KeyPressFcn = get(gcf, 'KeyPressFcn');

set(gcf, 'WindowButtonDownFcn', @selectPoint);
set(gcf, 'WindowButtonMotionFcn', @trackPoint);
set(gcf, 'WindowButtonUpFcn', @stopTracking);
set(gcf, 'CloseRequestFcn', @closeFigure);
set(gcf, 'KeyPressFcn', @cleanup);

set(gca, 'UserData', state);

    function selectPoint(~, ~)
        s = get(gca, 'UserData');
        s.cp = get(gca,'CurrentPoint');
        s.cp = s.cp(1, 1:2)';
        dist = s.d.control - repmat(s.cp, [1 s.np]);
        dist = sum(dist .^ 2, 1);
        [~, s.pointIdx] = min(dist);
        set(gca, 'UserData', s);
    end

    function trackPoint(~, ~)
        s = get(gca, 'UserData');
        if s.pointIdx
            newcp = get(gca,'CurrentPoint');
            newcp = newcp(1, 1:2)';
            if norm(newcp - s.cp) > 0.001 * s.scale
                s.cp = newcp;
                s.d.control(:, s.pointIdx) = s.cp;
                if s.d.open && (s.pointIdx == 1 || s.pointIdx == s.np)
                    % First and last point do not move
                    return
                end
                %s.d = splineEvalEven(s.d, true, true, s.image);
                s = redraw(s);
                set(gca, 'UserData', s);
            end
        end
    end

    function stopTracking(~, ~)
        s = get(gca, 'UserData');
        s.pointIdx = 0;
        set(gca, 'UserData', s);
    end

    function s = redraw(s)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %splineDraw(s.d, s.handles);
        example(s.d.control);
       % if s.image
       %     title(matchQuality(s.d, s.gradImg))
       % end
    end

    function cleanup(~, ~)
        s = get(gca, 'UserData');
        set(gca, 'UserData', s);
        
        % Save splines from all subplots of this figure
        f = gcf;
        child = get(get(gca, 'Parent'), 'Children');
        for c = 1:length(child)
            h = child(c);
            s = get(h, 'UserData');
            if ~isempty(s) && isstruct(s) && isfield(s, 'd')
                filename = sprintf('savedSpline.%d.mat', c);
                d = s.d; %#ok<NASGU>
                save(filename, 'd');
                fprintf(1, 'Saved spline from subplot %d in file %s\n', ...
                    c, filename);
            end
        end

        zoom off;
        
        set(gcf, 'WindowButtonDownFcn', s.WindowButtonDownFcn);
        set(gcf, 'WindowButtonMotionFcn', s.WindowButtonMotionFcn);
        set(gcf, 'WindowButtonUpFcn', s.WindowButtonUpFcn);
        set(gcf, 'CloseRequestFcn', s.CloseRequestFcn);
        set(gcf, 'KeyPressFcn', s.KeyPressFcn);
    end

    function closeFigure(~, ~)
        cleanup;
        delete(gcf);
    end
end
