function [y] = pl_func(x, as, bs, steps)
    steps = sort(steps);
    y = [];
    for i = 1:length(x)
        sidx = sum(x(i) >= steps) + 1;
        y(i) = as(sidx) * x(i) + bs(sidx);
        %printf("y = %f * x + (%f)\n", as(sidx), bs(sidx));
    end
end;
