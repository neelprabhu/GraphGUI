function y = P(u)

left = -3/2 <= u & u < -1/2;
middle = -1/2 <= u & u < 1/2;
right = 1/2 <= u & u < 3/2;

y = zeros(size(u));
y(left) = B(-u(left));
y(middle) = A(u(middle));
y(right) = B(u(right));

    function y = A(u)
        y = 3/4 - u .^ 2;
    end

    function y = B(u)
        y = 1/2 * (u - 3/2) .^ 2;
    end

end