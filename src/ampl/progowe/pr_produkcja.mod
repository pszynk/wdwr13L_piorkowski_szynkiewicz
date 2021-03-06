################################################################################
## Model z minimalizacją miary ryzyka przy wymaganym maksymalnym poziomie
## kosztow.
################################################################################

## ============================================================================
## ======================= PARAMETRY i ZBIORY =================================
## ============================================================================

## POMOCNICZE: --------------------------------

param MIN_mean_level default 0;
param MAX_mean_level default 20000;


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

# maksymalny akceptowalny poziom sredniej (kosztow)
param mean_level default 12000 , > MIN_mean_level, < MAX_mean_level;

## ============================================================================
## ============================== ZMIENNE =====================================
## ============================================================================

## MODELU: --------------------------------
# czasy pracy maszyn na podstawowych warunkach, nad czesciami w godzinach
var work_time{m in MACHINES, r in PARTS} >= 0, integer;

# czasy pracy maszyn przy dodatkowym wydzierzawieniu, nad czesciami w godzinach
var add_work_time{m in MACHINES, r in PARTS} >= 0, integer;

# koszty pracy maszyn dla kolejnych scenariuszy
var costs{s in 1..S} >= 0;

# [koszt] srednia kosztow ze scenariuszy (wartosc oczekiwana)
var mean >= 0;

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
    aa_deviation;



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

# [6] miara kosztu musi byc mniejsza od ustalonego poziomu
subject to s_mean_level:
    mean <= mean_level;

# umieszcza w zmiennej _abs_handle odchylenie kosztu scenaria
# jezeli jest ono mniejsze od wartosci oczekiwanej kosztu,
# wpp zostaje 0
subject to s__abs_handle1 {s in 1..S}:
    mean - costs[s] <= _abs_handle[s];

# [7] odchylenie przecietne z kosztow scenariuszy
# mnoze semi-odchylenie * 2 aby otrzymac odchylenie przecietne
subject to s_aa_deviation:
    ( (sum{s in 1..S} _abs_handle[s] * probability[s])*2 ) = aa_deviation;

