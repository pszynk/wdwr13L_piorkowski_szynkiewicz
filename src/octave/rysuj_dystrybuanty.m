#! /usr/bin/octave -qf
_BIG = -30000;

my_sort = @(x) sort(x, 2, 'ascend')
P = [0 .3 .5 .7 1;
     0 .3 .5 .8 1;
     0 .3 .5 .7 1];

pp = [.3 .2 .2 .3];
PP = [pp;pp;pp];

Z = [8100 12800 10350 15650;
          12650 17910 15250 16050;
          8800 13450 10950 15100];
[Z, per] = my_sort(-Z);
per
PP(1, :) = PP(1, :)(per(1, :));
PP(2, :) = PP(2, :)(per(2, :));
PP(3, :) = PP(3, :)(per(3, :));
PP
P = sort(cat(2, [0;0;0;], cumsum(PP, 2)), 2, 'ascend');

_min = min(min(Z));
_max = max(max(Z));

_colrs = ['r' 'g' 'b'];

for i = [1:length(_colrs)]
   stairs(my_sort([0, Z(i, :), _BIG]), my_sort([P(i, :) + i/800, 1]), _colrs(i), "linewidth", 1.5);
   hold on;
end

title("Dystrybuanta pierwszego rzedu dla punktow {-Z^1}, {-Z^2}, {-Z^3}", "fontsize", 20);
xlabel("koszt (srednia)", "fontsize", 14);
ylabel("prawd.", "fontsize", 14);


axis([_min - 400 _max + 400 0 1.2]);
legend("{F^{(1)}} dla punktu {-Z^1}", "{F^{(1)}} dla punktu {-Z^2}",
    "{F^{(1)}} dla punktu {-Z^3}");
hold off;
print -dpng -r300 "-S800,600" dyst1r.png;
pause();

bs = cat(2, [0;0;0], -Z(:, 1) .* P(:,2),
    -(Z .* P(:, 2:5))(:, 2:4) + cumsum(P(:, 2:4) .* (Z(:, 2:4) - Z(:, 1:3)), 2));
    bs
%bs = [0 -2430 -4500 -7060 -11755;
%      0 -3795 -6843 -12435 -16422;
%      0 -2640 -4830 -8165 -13945];

xs = [(_min - 400):1:(_max + 400)];
for i = [1:length(_colrs)]
   plot(xs, pl_func(xs, P(i, :), bs(i, :), Z(i, :)), _colrs(i), "linewidth", 1.5);
   hold on;
end

title("Dystrybuanta drugiego rzedu dla punktow {-Z^1}, {-Z^2}, {-Z^3}", "fontsize", 20);
xlabel("koszt (srednia)", "fontsize", 14);
ylabel("y", "fontsize", 14);

legend("{F^{(2)}} dla punktu {-Z^1}", "{F^{(2)}} dla punktu {-Z^2}",
    "{F^{(2)}} dla punktu {-Z^3}");

hold off;
print -dpng -r300 "-S800,600" dyst2r.png;
pause();


