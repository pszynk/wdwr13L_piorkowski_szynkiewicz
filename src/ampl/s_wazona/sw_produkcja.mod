################################################################################
## Model z wykorzystaniem sumy wazonej jako funkcji skalaryzyjacej
################################################################################

## ============================================================================
## ======================= PARAMETRY i ZBIORY =================================
## ============================================================================

## POMOCNICZE: --------------------------------
# ograniczenia na wartosc lambda
# mamy 4 scenariusze ponumeorwane 1..4 wystepujace z prawd. 0.3 0.2 0.2 0.3
# rownowazna sytucja bylaby dla 10 scenariuszy rownoprawdopodobynych
# kazdy odpowiada jednemu z 4 pierwotnych scenaruszy:
# nr.           1   2   3   4   5   6   7   8   9  10
# prawd       0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
# scenariusz    1   1   1   2   2   3   3   4   4   4
# czyli m = 10, limit dla lambda = m/m-1 => 10/9

param MIN_lambda default 0;
param MAX_lambda default 1.1111111111;


## MODELU: --------------------------------
# zbior maszyn: (M1, M2, M3)
set MACHINES;

# zbior czesci: (a, b, c, d, e)
set PARTS;

# liczba scenariuszy: (4)
param S;

# maksymalny miesieczny czas pracy jednej maszyny w godzinach (180)
param limit;

# maksymalny czas na jaki mozna wydzierzawic jedna maszyne (50)
param add_limit;

# dodatkowa oplata od kazdej godziny przy wydzierzawieniu (10)
param surcharge;

# czasy produkcji czesci przez maszyny
param production_time{m in MACHINES, r in PARTS};

# koszty pracy dla kazdej maszyny w kolejnych scenariuszach
param scenarios{1..S, m in MACHINES};

# zapotrzebowanie na kazda z czesci
param demand{r in PARTS};

# prawdopodobienstwo kazdego ze scenariuszy
param probability{1..S};

# lambda to wspolczynnik awersji do ryzyka
param lambda default 1, > MIN_lambda, < MAX_lambda;

## ============================================================================
## ============================== ZMIENNE =====================================
## ============================================================================

## MODELU: --------------------------------
# czasy pracy maszyn na podstawowych warunkach, nad czesciami
var work_time{m in MACHINES, r in PARTS} >= 0, integer;

# czasy pracy maszyn przy dodatkowym wydzierzawieniu, nad czesciami
var add_work_time{m in MACHINES, r in PARTS} >= 0, integer;

# koszty pracy maszyn dla kolejnych scenariuszy
var costs{s in 1..S} >= 0;

# [koszt] srednia kosztow ze scenariuszy (wartosc oczekiwana)
var mean >= 0;

# [ryzyko*] odchylenie semi przecietne z kosztow dla scenariuszy
# (average absolute deviation)
var aa_semi_deviation >=0;

# [ryzyko] odchylenie przecietne z kosztow dla scenariuszy
# (average absolute deviation)
var aa_deviation >=0;


## POMOCNICZE: --------------------------------
# zmienna pomocnicza sluzaca do wyliczania odchylenia standardowego
# (zbiera tylko dodatnie roznice [mean - costs(i)] dla scen.)
var _abs_handle{s in 1..S} >= 0;

## ============================================================================
## ============================ FUNKCJA CELU ==================================
## ============================================================================

# minimalizacja kosztu i ryzyka pomnozonego przez wspolczynnik awersji do
# ryzyka
minimize objective_func:
    mean  + lambda * aa_semi_deviation;



## ============================================================================
## ============================ OGRANICZENIA ==================================
## ============================================================================


# [1] spelnienie zapotrzebowania:
subject to s_demand {r in PARTS}:
    sum{m in MACHINES} ( (work_time[m,r] + add_work_time[m,r]) /
                         (production_time[m,r]/60) ) >= demand[r];


# [2] ograniczenie standardowego czasu pracy maszyn
subject to s_supply {m in MACHINES}:
    sum{r in PARTS} work_time[m,r] <= limit;

# [3] ograniczenie dodatkowego czasu pracy maszyn
subject to s_add_supply {m in MACHINES}:
    sum{r in PARTS} add_work_time[m,r] <= add_limit;

# [4] koszty pracy maszyn dla kazdego ze scenariuszy
subject to s_costs {s in 1..S}:
    sum{m in MACHINES} ((sum{r in PARTS} work_time[m, r]) * scenarios[s,m] +
        (sum{r in PARTS} add_work_time[m,r]) * (scenarios[s,m] + surcharge)) = costs[s];

# [5] srednia z kosztow scenariuszy
subject to s_mean:
    (sum{s in 1..S} costs[s] * probability[s]) = mean;

# umieszcza w zmiennej _abs_handle koszty dla scenariuszow
# jezeli sa one mniejsze od wartosci oczekiwanej kosztu,
# wpp zostaje 0
subject to s__abs_handle1 {s in 1..S}:
    mean - costs[s] <= _abs_handle[s];

# [6] odchylenie przecietne z kosztow scenariuszy
subject to s_aa_semi_deviation:
    ( (sum{s in 1..S} _abs_handle[s] * probability[s]) ) = aa_semi_deviation;

# [7] odchylenie przecietne to 2 * semi
subject to s_aa_deviation:
    aa_deviation  = aa_semi_deviation * 2;


