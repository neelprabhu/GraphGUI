function h = splineDraw(s, h, drawNeedles, colorSpans)

if nargin < 3 || isempty(drawNeedles)
    drawNeedles = false;
end

if nargin < 4 || isempty(colorSpans)
    colorSpans = false;
end

control = s.control;
if ~s.open
    control = [control control(:, 1)];
end

if drawNeedles
    nx = [s.needle.in(1, :); s.needle.out(1, :)];
    ny = [s.needle.in(2, :); s.needle.out(2, :)];
end

if colorSpans
    color = 'rb';
    span = spans(s.knot, s.order, s.open);
    spanSamples = cell(length(span), 1);
    for ns = 1:length(span)
        ti = s.knot(span(ns));
        tip = s.knot(span(ns)+1);
        ispan = s.t >= ti & s.t <= tip;
        spanSamples{ns} = [ti s.t(ispan) tip];
    end
end

if nargin == 2
    if colorSpans
        segment = spanSegments;
        for ns = 1:length(segment)
            set(h.curve(ns), 'XData', segment{ns}(1, :), ...
                'YData', segment{ns}(2, :));
        end
    else
        set(h.curve, 'XData', s.curve(1, :), 'YData', s.curve(2, :));
    end
    set(h.ctrlLine, 'XData', control(1, :), 'YData', control(2, :));
    set(h.ctrlPoint, 'XData', control(1, :), 'YData', control(2, :));
    if drawNeedles
        for n = 1:length(h.needle)
            set(h.needle(n), 'XData', nx(:, n), 'YData', ny(:, n));
        end
    end
else
    oldhold = ishold;
    if colorSpans
        segment = spanSegments;
        h.curve = zeros(length(segment), 1);
        hold on
        for ns = 1:length(segment)
            h.curve(ns) = plot(segment{ns}(1, :), segment{ns}(2, :), ...
                sprintf('-%c', color(mod(ns, 2) + 1)), 'LineWidth', 4);
        end
        hold off
    else
        h.curve = plot(s.curve(1, :), s.curve(2, :), '-r', 'LineWidth', 4);
    end
    hold on
    h.ctrlLine = plot(control(1, :), control(2, :), '-g');
    h.ctrlPoint = plot(control(1, :), control(2, :), '.g', 'MarkerSize', 12);
    if drawNeedles
       h.needle = plot(nx, ny, '-y');
    end
    axis equal
    if ~oldhold
        hold off
    end
    axis ij
end

    function seg = spanSegments
        seg = cell(length(spanSamples), 1);
        for ks = 1:length(spanSamples)
            seg{ks} = interp1(s.t, s.curve', spanSamples{ks})';
        end
    end
end