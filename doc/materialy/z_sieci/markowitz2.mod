# Objective: convex quadratic 
# Constraints: linear 

param n integer > 0 default 1000; # number of investment opportunities
param T integer > 0 default 200;  # number of historical samples

param mu default 1.0;

param R {1..T,1..n} := Uniform01(); # return for each asset at each time
                                    # (in lieu of actual data,
				    # this is an expression of our true
				    # beliefs about these investments).

param mean {j in 1..n}              # mean return for each asset
	:= ( sum{i in 1..T} R[i,j] ) / T;

param Rtilde {i in 1..T,j in 1..n}  # returns ajusted for their means
	:= R[i,j] - mean[j];

var x{1..n} >= 0;
var y{1..T};

minimize linear_combination: 
	      mu *				# weight
	      sum{i in 1..T} y[i]^2  		# variance
	      -
	      sum{j in 1..n} mean[j]*x[j]       # mean
	      ;

subject to total_mass: 
    sum{j in 1..n} x[j] = 1;

subject to definitional_constraints {i in 1..T}:
    y[i] = sum{j in 1..n} Rtilde[i,j]*x[j];

solve;

printf: "Optimal Portfolio: \n";
printf {j in 1..n: x[j]>0.001}: "    %3d %10.7f \n", j, x[j];

printf: "Mean = %10.7f, Variance = %10.5f \n",
	sum{j in 1..n} mean[j]*x[j],
	sum{i in 1..T} (sum{j in 1..n} Rtilde[i,j]*x[j])^2;
