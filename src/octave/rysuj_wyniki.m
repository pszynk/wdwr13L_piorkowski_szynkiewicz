function rysuj_wyniki(wyniki_pr, wyniki_sw)
% wyniki_pr -> pliki z rozwiazaniami efektywnymi dla rozw. progowego
% wyniki_sw -> pliki z rozwiazaniami efektywnymi dla sumy wazonej
    pr_rozw = cell2mat(cellfun(@load, wyniki_pr, 'UniformOutput', 0));
    sw_rozw = cell2mat(cellfun(@load, wyniki_sw, 'UniformOutput', 0));

    [mm min_risk_idx] = min(pr_rozw(:, 3));
    [mm min_cost_idx] = min(pr_rozw(:, 2));

    plot(pr_rozw(:, 3), pr_rozw(:, 2), "@3*", "markersize", 9);
    axis([1400, 2800, 11500, 14500]);
    title("zbior rozwiazan efektwynych", "fontsize", 20);
    xlabel("ryzyko (odchylenie przecietne)", "fontsize", 14);
    ylabel("koszt (srednia)", "fontsize", 14);

    hold on;
    plot(sw_rozw(:, 3), sw_rozw(:, 2), "@1o", "markersize", 13);
    plot([1400, 2800], [pr_rozw(min_cost_idx, 2), pr_rozw(min_cost_idx, 2)], "-c;;",
         [pr_rozw(min_risk_idx, 3), pr_rozw(min_risk_idx, 3)], [11500, 14500], "-c;;");
    legend("progi maks. kosztu", "srednia wazona", "wyniki skrajne");
    hold off;
    [1400, 2800], [pr_rozw(min_cost_idx, 2), pr_rozw(min_cost_idx, 2)]
    [pr_rozw(min_risk_idx, 3), pr_rozw(min_risk_idx, 3)], [11755, 14500]

end;
