function spl = showSplinePoly(s)

nctl = size(s.control, 2);
control = 0:(nctl-1);

spl = s;
spl.control = control;
spl = splineEval(spl, true, true, false);

V = s.control';

figure(1)
clf
plot(spl.t, spl.P)

figure(2)
clf
figure(3)
clf
hold on

for span = 1:(length(control)-spl.order+1)
    ti = control(span);
    tip = control(span+1);
    
    ispan = spl.t >= ti & spl.t <= tip;
    tspan = [ti spl.t(ispan) tip];
    
    B = zeros(length(tspan), 2 * spl.order);
    C = zeros(length(tspan), 2);
    P = zeros(length(tspan), spl.order);
    for j = 1:length(tspan)
        tj = tspan(j);
        
        % Normalized span coordinate
        u = (tj - ti) / (tip - ti);
        p = powers(u, spl.order);
        pM = p * spl.matrix(:, :, span);
        
        for o = 1:spl.order
            B(j, (o-1) * 2 + (1:2)) = pM(o) * V(span + o - 1, :);
        end
        C(j, :) = pM * V(span + (0:2), :);
        P(j, :) = pM;
    end
    
    figure(2)
    plot(tspan, P)
    hold on
    plot(0, 1, 'w')
    plot(spl.t(end), 0, 'w')
    hold off
    
    figure(3)
    plot(C(:, 1), C(:, 2))
    
    pause
end

% First kk powers of the scalar x (starting at x^0)
    function q = powers(x, kk)
        q = zeros(1, kk);
        q(1) = 1;
        for jj = 2:kk
            q(jj) = x * q(jj-1);
        end
    end

end