/*
Weighted Missingness Analysis

wmc Version 1.0

Jan Jakob Krüger - info@jjkrueger.de

Uses the mdesc command as a baseline to add a weighted missingness analysis option
allowing for seeing how much of one variable in terms of another variable is missing.

mdesc Version 2.1 developped by Rose Anne Medeiros & Dan Blanchette

*/

********************************************************************************
********************************************************************************

cap qui program drop wm_count
program wmc, rclass byable(recall)
version 18
    syntax [varlist] [if] [in] [, ABbreviate(integer 12) wv(string)]

local nvars : word count `varlist'
// this just counts the number of variables for which we do the missingness analysis

local nvars_weight: word count `wv'
	if `nvars_weight' > 1 {
		display as error "Too many weight variables specified"
		exit 001
	}
// stop the programm if there is more than one weighting variable	

local weight_var = "`wv'"
count if missing(`weight_var')
local count_wv_miss = r(N)
	if `count_wv_miss' > 0 {
		display as error "The weighting variable should never be missing"
		exit 002
	}
// Stop the program if the weighting variable is missing ever

local weight_type = substr("`: type `weight_var' '", 1, 3)
	if "`weight_type'" == "str" {
		display as error "The weighting variable should be in numeric format"
		exit 003
	}
// Stop the program if your weighting variable is in string format

if `abbreviate' > 32 {
  local abbreviate = 32
}
// to make sure the abbreviation works, define a maximum variable length

local c1 = 17
local c2 = 16
local c3 = 69

if `abbreviate' > 16 {
  local c1= `abbreviate' + 2
  local c2= `abbreviate' + 1
  local c3= `abbreviate' + 30
}
// make the adjustments relevant for the formatting of the output of the tables

local weight_var = "`wv'"
// define the local for the name of the variable by which to weigh the missingness	

	display as text _n "Weighting variable: `weight_var'"
	display as text _n "    Variable" _column(`c1')"{c |}     Missing          Total     Percent Missing      Weighted Missing"
	display as text "{hline `c2'}{c +}{hline `c3'}"
// start by generating the displayed output
	

// this generates a local macro called touse
marksample touse, novarlist
quietly: count  if `touse' == 1
tempvar total
scalar `total'= r(N)

  qui summ `weight_var'
  local wv_sum = r(sum)

  foreach var of local varlist {
     quietly {
         count if missing(`var') & `touse' == 1
         return scalar miss = r(N)
		 return scalar total= scalar(`total')
         return scalar percent= (return(miss)/return(total) * 100)
		 
		 summ `weight_var' if `touse' == 1 & missing(`var')
		 return scalar miss_var_sum = r(sum)
		 return scalar wv_sum = `wv_sum'
		 return scalar w_percent = (return(miss_var_sum)/return(wv_sum) * 100)
		 
     }
         display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
           as result %11.0gc `return(miss)' "    "     ///
           %11.0gc `return(total)' "       " ///
           %8.2f `return(percent)' "       " ///
		   %8.2f `return(w_percent)'

  }
 display as text "{hline `c2'}{c +}{hline `c3'}"
  
  qui summ `weight_var'
  local wv_sum = r(sum)
  local wv_sum: display %9.0fc `wv_sum'
  
  local wv_mean = round(r(mean),0.01)
  local wv_mean: display %9.2fc `wv_mean'
  
  display as text " Sum of weighting variable: `wv_sum'"
  display as text "Mean of weighting variable: `wv_mean'"
   
  display as text "{hline `c2'}{c -}{hline `c3'}"

end