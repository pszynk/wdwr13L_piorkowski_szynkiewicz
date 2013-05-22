set Machines;
set Parts;

param S;
param limit;
param add_limit;
param surcharge;
param lambda;

param production_time{m in Machines, r in Parts};
param scenarios{1..S, m in Machines};
param demand{r in Parts};
param probability{1..S};

var work_time{m in Machines, r in Parts} >= 0, integer;
var add_work_time{m in Machines, r in Parts} >= 0, integer;

# koszty dla kolejnych scenariuszy
var costs{s in 1..S} >= 0;

# srednia kosztow (wartosc oczekiwana)
var mean >= 0;

# odchylenie przecietne (average absolute deviation)
var aa_deviation >=0;

var _abs_handle{s in 1..S} >= 0;

minimize min_func:
    #mean;
    mean  + lambda * aa_deviation;

subject to s_demand {r in Parts}:
    sum{m in Machines} ( (work_time[m,r] + add_work_time[m,r]) / (production_time[m,r]/60) ) >= demand[r];

subject to s_supply {m in Machines}:
    sum{r in Parts} work_time[m,r] <= limit;

subject to s_add_supply {m in Machines}:
    sum{r in Parts} add_work_time[m,r] <= add_limit;

subject to s_costs {s in 1..S}:
    sum{m in Machines} ((sum{r in Parts} work_time[m, r]) * scenarios[s,m] +
        (sum{r in Parts} add_work_time[m,r]) * (scenarios[s,m] + surcharge)) = costs[s];

subject to s_mean:
    (sum{s in 1..S} costs[s] * probability[s]) = mean;


subject to s__abs_handle1 {s in 1..S}:
    costs[s] - mean <= _abs_handle[s];

subject to s__abs_handle2 {s in 1..S}:
    costs[s] - mean >= -_abs_handle[s];

#subject to s_aa_deviation:
#    ( (sum{s in 1..S} _abs_handle[s])/S ) = aa_deviation;

subject to s_aa_deviation:
    ( (sum{s in 1..S} _abs_handle[s] * probability[s]) ) = aa_deviation;
