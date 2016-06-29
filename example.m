function h = example(v)
%nctr = 5;
%v= [1:nctr; zeros(1, nctr)];

order = 3;
n = size(v, 2) - 1;
samples = 101;

t = linspace(1/2, n - 1/2, samples);

% Replace endpoints so that the spline passes through the first and last
% point in v
vp = [2 * v(:, 1) - v(:, 2), v(:, 2:n), 2 * v(:, end) - v(:, end-1)];
sp = zeros(2, samples);
for i = 1:length(vp)
    sp = sp + vp(:, i) * P(t - i + 1);
end

figure(1)
clf

h.ctrlPoint = plot(v(1, :), v(2, :), '-ob'); % Original control points
hold on
h.curve = plot(sp(1, :), sp(2, :), 'r');
axis equal



    