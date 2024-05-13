# Small STATA packages
This is my place for small packages that I coded while working as an RA to make my life a little easier with large amounts of data. 

## wmc

This is a small STATA package that can be interpreted as an extension to the _mdesc_ command in STATA and allows for weights when investigating missing values. You specify the variables for which you want to see the number of missing values and then specify the variable by which you want to weight the missingness. This allows researchers to see that if a variable misses 5% of its observations whether when weighted this corresponds to 1% or 50% of another variable indicating how important the missing values are. 

### Installation 

To use the `wmc` command you cna use the following code to install the package from GitHub (**v1.0**):

```
net install wmc, from("https://raw.githubusercontent.com/jjkrueg/STATA_misc/main/Installation") replace
```

Even if you have the package installed, make sure that it is updated `ado update, update`.

### Syntax

```
wmc [varlist] [if] [in] [, ABbreviate(integer 12) wv(string)]
```

We start by writing wmc which stands for weighted missingness count. We can specify the typical `if` and `in` clauses as well as the conventional abbrevation command known from the mdesc command. The innovation of this command allows for the weighting variable `wv`. Before doing any calculations the command checks that there is only one weighting variable, the weighting variable is never missing and that the weighting variable is in numeric format. 

### Use

```
sysuse auto, clear
qui replace mpg = . if mpg == 16
wmc mpg, wv(price)
```

Which then yields the following output:

```
Weighting variable: price

    Variable    |     Missing          Total     Percent Missing      Weighted Missing
----------------+---------------------------------------------------------------------
            mpg |           4             74           5.41           7.09
----------------+---------------------------------------------------------------------
 Sum of weighting variable:   456,229
Mean of weighting variable:  6,165.26
--------------------------------------------------------------------------------------
```



## Other projects (under development)

1. wmcgraph
2. multiple weighting missingness
