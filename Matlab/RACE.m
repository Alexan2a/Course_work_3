function y = RACE(x, L, beta)

    NAdapt = length(x);
    y = zeros(NAdapt, 1);
    Rxx = zeros(1, 2*L+1);
    x_buf = zeros(1, 2*L+1);
    p = 1

    for n = 1:NAdapt-L

        x_buf = [x(n) x_buf(1:end-1)];
        Rxx = beta * Rxx + (1 - beta) * x_buf(L+1) .* x_buf;
        p = beta.*p + (1-beta).*mean(x_buf.^2);
        gain = L*p;
        y(n) = sum(Rxx .* x_buf) / gain;

    end
end