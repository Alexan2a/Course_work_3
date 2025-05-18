function [w, y, e] = LMS(L, mu, u, d)
    
    NAdapt = length(d);
    w = zeros(L, 1);
    y = zeros(NAdapt, 1);
    e = zeros(NAdapt, 1);
    u_buf = zeros(L, 1);
    
    for n = 1 : NAdapt

        u_buf = [u(n); u_buf(1:end-1)];
        y(n) = w' * u_buf;
        e(n) = d(n) - y(n);
        w = w + mu * u_buf * e(n); 

    end
end