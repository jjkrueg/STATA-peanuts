/*
Weighted Missingness Analysis

wmc Version 2.3

Date: 19/10/2024

Jan Jakob Krüger - info@jjkrueger.de

Uses the mdesc command as a baseline to add a weighted missingness analysis option
allowing for seeing how much of one variable in terms of another variable is missing.

Command allows for the use of multiple weights as well as graphing the output to 
give an overview over the missingness in one visualisation. Basic statistics on
the weighting variables included at the end of the command. 

mdesc Version 2.1 developped by Rose Anne Medeiros & Dan Blanchette

*/

/*
Idea of this iteration is to add the option of looking at grouped patterns of 
missingness. A variable that has multiple observations per country might be 
missing 0% of times for Country A and 50% for country B. This information helps
discover missingness and address it adequately.  

TODO: 
1. Add group option in command [Y]
2. Add layout for groups in the mdesc commands [Y]
3. Add grouped calculations without weights [Y]
4. Add grouped calculations with weights [Y]
5. Add more graphing options with plottabs [under development]
*/

********************************************************************************
********************************************************************************

cap qui program drop wmc
program wmc, rclass byable(recall)
version 18
    syntax [varlist] [if] [in] [, ABbreviate(integer 12) wv(string) MVals(string) GRoups(string) figure]

local nvars : word count `varlist'
// this just counts the number of variables for which we do the missingness analysis

	****************************************
	* Error messages and input consistency *
	****************************************
		local nvars_weight: word count `wv'
			if `nvars_weight' > 3 {
				display as error "Too many weight variables specified"
				exit 001
			}
		// Stop the program if there are too many weighting variables
			
		local weight_var = "`wv'"
		if `nvars_weight' >= 1 {
			local var_1 "`=word("`weight_var'", 1)'"
			qui count if missing(`var_1')
			local count_wv_miss = r(N)
			if `count_wv_miss' > 0 {
				display as error "`var_1' contains missing values"
				exit 021
			}
		} 
		if `nvars_weight' >= 2 {
			local var_2 "`=word("`weight_var'", 2)'"
			qui count if missing(`var_2')
			local count_wv_miss = r(N)
			if `count_wv_miss' > 0 {
				display as error "`var_2' contains missing values"
				exit 022
			}
		} 
		if `nvars_weight' == 3 {
			local var_3 "`=word("`weight_var'", 3)'"
			qui count if missing(`var_3')
			local count_wv_miss = r(N)
			if `count_wv_miss' > 0 {
				display as error "`var_3' contains missing values"
				exit 023
			}
		}	
		// Stop the program if the weighting variable is missing ever
			
		local weight_var = "`wv'"
		if `nvars_weight' >= 1 {
			local wvar_1 = substr("`: type `var_1' '", 1, 3)
			if "`wvar_1'" == "str" {
				display as error "`var_1' should be in numeric format"
				exit 003
			}
		} 
		if `nvars_weight' >= 2 {
			local wvar_2 = substr("`: type `var_2' '", 1, 3)
			if "`wvar_2'" == "str" {
				display as error "`var_2' should be in numeric format"
				exit 003
			}
		} 
		if `nvars_weight' == 3 {
			local wvar_3 = substr("`: type `var_3' '", 1, 3)
			if "`wvar_3'" == "str" {
				display as error "`var_3' should be in numeric format"
				exit 003
			}
		}
		// Stop the program if your weighting variable is in string format
		
		if `abbreviate' > 16 {
		local abbreviate = 16
		}
		// to make sure the abbreviation works, define a maximum variable length
		
		local nvals_miss: word count `mvals'
		if `nvals_miss' > 3 {
			display as error "Too many alternate missing values specified"
			exit 004
		}
		// Exit if too many alternative missing values are specified
		
		forvalues i = 1 / `nvals_miss' {
			local mval_`i' "`=word("`mvals'", `i')'"
		}
		// Create the individual list of values to also count as missing
		
		local nvals_group: word count `groups'
		if `nvals_group' > 1 {
			display as error "Too many group variables specified"
			exit 005
		}
		// Exit if there is more than 1 group variable specified
		
		local group_var "`groups'"
		cap qui levelsof `group_var', local(grp_vals)
		local num_groups: word count `grp_vals'
		if `num_groups' > 20 {
			display as error "Too many distinct values in grouping variable"
			exit 006
		}		
		
	**************************************
	* Formatting of STATA console output *
	**************************************
		
		local c1 = 17
		local c2 = 16
		local c3 = 47
		local c4 = 70
		local c5 = 96
		local c6 = 119
		
		if `abbreviate' > 16 {
		local c1= `abbreviate' + 2
		local c2= `abbreviate' + 1
		local c3= `abbrevaite' + 17
		local c4= `abbreviate' + 30
		local c5= `abbreviate' + 53
		local c6= `abbreviate' + 76
		}
		// make the adjustments relevant for the formatting of the output of the tables
		
		if `nvals_miss' == 1 {
			display as text _n "List of values considered missing: . , `mval_1' "
		}
		if `nvals_miss' == 2 {
			display as text _n "List of values considered missing: . , `mval_1' , `mval_2'"
		}
		if `nvals_miss' == 3 {
			display as text _n "List of values considered missing: . , `mval_1' , `mval_2' , `mval_3'"
		}
		
		
		if `nvars_weight' >= 1 {
			display as text _n "1. Weighting variable: `var_1'"
		} 
		if `nvars_weight' >= 2 {
			display as text "2. Weighting variable: `var_2'"
		} 
		if `nvars_weight' == 3 {
			display as text "3. Weighting variable: `var_3'"
		}
		
		if `nvals_group' > 0 {
			display as text _n "Grouping variable: `group_var'"
			display as text _n
		}
		
		if `nvars_weight' == 0 {
			
			display as text _n "    Variable" _column(`c1')"{c |}     Missing          Total     Percent Missing"
			display as text "{hline `c2'}{c +}{hline `c3'}"
			
		}
		
		if `nvars_weight' == 1 {
			
			display as text _n "    Variable" _column(`c1')"{c |}     Missing          Total     Percent Missing      Weighted Missing"
			display as text "{hline `c2'}{c +}{hline `c4'}"
			
		}
		
		else if `nvars_weight' == 2 {
			
			display as text _n "    Variable" _column(`c1')"{c |}     Missing          Total     Percent Missing      Weighted Missing 1      Weighted Missing 2"
			display as text "{hline `c2'}{c +}{hline `c5'}"
			
		}
		
		else if `nvars_weight' == 3 {
			display as text _n "    Variable" _column(`c1')"{c |}     Missing          Total     Percent Missing      Weighted Missing 1      Weighted Missing 2      Weighted Missing 3"
			display as text "{hline `c2'}{c +}{hline `c6'}"
		}
		// start by generating the displayed output
		

	*******************************************
	* Generating the missingness calculations *
	*******************************************
	
		marksample touse, novarlist
		quietly: count  if `touse' == 1
		tempvar total
		scalar `total' = r(N)
		
		if `nvals_miss' > 0 {
			qui cap frame drop miss
			qui frame copy default miss
			qui frame change miss
			
			foreach var of local varlist {
				forvalues i = 1 / `nvals_miss' {
					
					qui replace `var' = . if `var' == `mval_`i''
					
				}
			}
		}
		
		if `nvals_group' == 0 {
		
			**************
			* No Weights *
			**************
		
		if `nvars_weight' == 0 {
			foreach var of local varlist {
				quietly {
					count if missing(`var') & `touse' == 1
					return scalar miss = r(N)
					return scalar total= scalar(`total')
					return scalar percent= (return(miss)/return(total) * 100)
		
						}
						
				display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
				as result %11.0gc `return(miss)' "    "     ///
				%11.0gc `return(total)' "       " ///
				%8.2f `return(percent)'
					}
		}
		
			***********
			* Weights *
			***********
		
		else if `nvars_weight' > 0 {
			quietly {
				if `nvars_weight' == 1 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
				}
				
				if `nvars_weight' == 2 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
					
					cap qui summ `var_2'
					local wv_sum2 = r(sum)
				}
				
				if `nvars_weight' == 3 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
					
					cap qui summ `var_2'
					local wv_sum2 = r(sum)	
					
					cap qui summ `var_3'
					local wv_sum3 = r(sum)	
				}
			}
				
		foreach var of local varlist {
			quietly {
					
					if `nvars_weight' == 1 {
						
						count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total= scalar(`total')
						return scalar percent= (return(miss)/return(total) * 100)
						
						summ `var_1' if `touse' == 1 & missing(`var')
						return scalar miss_var_sum_1 = r(sum)
						return scalar wv_sum_1 = `wv_sum1'
						return scalar w_percent_1 = (return(miss_var_sum_1) / return(wv_sum_1) * 100)							
					}
					
					if `nvars_weight' == 2 {
						
						count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total= scalar(`total')
						return scalar percent= (return(miss)/return(total) * 100)
						
						forvalues i = 1/2 {
							qui summ `var_`i'' if `touse' == 1 & missing(`var')
							return scalar miss_var_sum_`i' = r(sum)
							return scalar wv_sum_`i' = `wv_sum`i''
							return scalar w_percent_`i' = (return(miss_var_sum_`i') / return(wv_sum_`i') * 100)				
						}
						
					}
					
					if `nvars_weight' == 3 {
						
						count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total= scalar(`total')
						return scalar percent= (return(miss)/return(total) * 100)						
						
						forvalues i = 1/3 {
							qui summ `var_`i'' if `touse' == 1 & missing(`var')
							return scalar miss_var_sum_`i' = r(sum)
							return scalar wv_sum_`i' = `wv_sum`i''
							return scalar w_percent_`i' = (return(miss_var_sum_`i') / return(wv_sum_`i') * 100)				
						}						
						
					}
				}
			
			if `nvars_weight' == 1 {
				display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
				as result %11.0gc `return(miss)' "    "     ///
				%11.0gc `return(total)' "       " ///
				%8.2f `return(percent)' "       " ///
				%8.2f `return(w_percent_1)'
			}
			else if `nvars_weight' == 2 {
				display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
				as result %11.0gc `return(miss)' "    "     ///
				%11.0gc `return(total)' "       " ///
				%8.2f `return(percent)' "       " ///
				%8.2f `return(w_percent_1)' "               " ///
				%8.2f `return(w_percent_2)'			
			}
			else if `nvars_weight' == 3 {
				display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
				as result %11.0gc `return(miss)' "    "     ///
				%11.0gc `return(total)' "       " ///
				%8.2f `return(percent)' "       " ///
				%8.2f `return(w_percent_1)' "                 " ///
				%8.2f `return(w_percent_2)' "                 " ///
				%8.2f `return(w_percent_3)'		
			}
		}
	}	
	}
	
	if `nvals_group' == 1 {
		
			**************
			* No Weights *
			**************
		
		if `nvars_weight' == 0 {
			foreach var of local varlist {
				quietly {
					count if missing(`var') & `touse' == 1
					return scalar miss = r(N)
					return scalar total= scalar(`total')
					return scalar percent= (return(miss)/return(total) * 100)
		
						}
						
				display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
				as result %11.0gc `return(miss)' "    "     ///
				%11.0gc `return(total)' "       " ///
				%8.2f `return(percent)'
				
			display as text %`=`c1'-2's "`group_var':" _column(`c1')"{c |}"
			
			foreach value of local grp_vals {
				
				qui count if missing(`var') & `group_var' == `value' & `touse' == 1
				return scalar miss_`value' = r(N)
				qui count if `group_var' == `value' & `touse' == 1
			 	return scalar total_`value' = r(N)
			 	return scalar percent_`value' = (return(miss_`value')/return(total_`value') * 100)
				
				display as text %`=`c1'-2's "`value'" _column(`c1')"{c |} " ///
			 	as result %11.0gc `return(miss_`value')' "    "     ///
			 	%11.0gc `return(total_`value')' "       " ///
			 	%8.2f `return(percent_`value')'
				
			}
			
			display as text %`=`c1'-2's " " _column(`c1')"{c |}"
				
			}
		}
			
			***********
			* Weights *
			***********
		
		else if `nvars_weight' > 0 {
			
		quietly {
				if `nvars_weight' == 1 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
				}
				
				if `nvars_weight' == 2 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
					
					cap qui summ `var_2'
					local wv_sum2 = r(sum)
				}
				
				if `nvars_weight' == 3 {
					cap qui summ `var_1'
					local wv_sum1 = r(sum)
					
					cap qui summ `var_2'
					local wv_sum2 = r(sum)	
					
					cap qui summ `var_3'
					local wv_sum3 = r(sum)	
				}
			}	
			
			foreach var of local varlist {
					
					if `nvars_weight' == 1 {
						
						qui count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total = scalar(`total')
						return scalar percent = (return(miss)/return(total) * 100)
						
						qui summ `var_1' if `touse' == 1 & missing(`var')
						return scalar miss_var_sum_1 = r(sum)
						return scalar wv_sum_1 = `wv_sum1'
						return scalar w_percent_1 = (return(miss_var_sum_1) / return(wv_sum_1) * 100)
						
						display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
						as result %11.0gc `return(miss)' "    "     ///
						%11.0gc `return(total)' "       " ///
						%8.2f `return(percent)' "       " ///
						%8.2f `return(w_percent_1)'
						
						display as text %`=`c1'-2's "`group_var':" _column(`c1')"{c |}"
						
						foreach value of local grp_vals {
							
							qui summ `var_1' if `group_var' == `value'
							local wv_sum1_`value' = r(sum)
							
							qui count if missing(`var') & `group_var' == `value' & `touse' == 1
							return scalar miss_`value' = r(N)
							qui count if `group_var' == `value' & `touse' == 1
							return scalar total_`value' = r(N)
							return scalar percent_`value' = (return(miss_`value')/return(total_`value') * 100)
							
							qui summ `var_1' if `touse' == 1 & missing(`var') & `group_var' == `value'
							return scalar miss_var_sum_1_`value' = r(sum)
							return scalar wv_sum_1_`value' = `wv_sum1_`value''
							return scalar w_percent_1_`value' = (return(miss_var_sum_1_`value') / return(wv_sum_1_`value') * 100)
							
							display as text %`=`c1'-2's "`value'" _column(`c1')"{c |} " ///
							as result %11.0gc `return(miss_`value')' "    "     ///
							%11.0gc `return(total_`value')' "       " ///
							%8.2f `return(percent_`value')' "       " ///
							%8.2f `return(w_percent_1_`value')'
				
					}	
					}
					
					if `nvars_weight' == 2 {
						
						qui count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total = scalar(`total')
						return scalar percent = (return(miss)/return(total) * 100)
						
						forvalues i = 1/2 {
							qui summ `var_`i'' if `touse' == 1 & missing(`var')
							return scalar miss_var_sum_`i' = r(sum)
							return scalar wv_sum_`i' = `wv_sum`i''
							return scalar w_percent_`i' = (return(miss_var_sum_`i') / return(wv_sum_`i') * 100)				
						}
						
						display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
						as result %11.0gc `return(miss)' "    "     ///
						%11.0gc `return(total)' "       " ///
						%8.2f `return(percent)' "       " ///
						%8.2f `return(w_percent_1)' "                " ///
						%8.2f `return(w_percent_2)'
						
						display as text %`=`c1'-2's "`group_var':" _column(`c1')"{c |}"
						
						foreach value of local grp_vals {
							
							forvalues i = 1 / 2 {
								qui summ `var_`i'' if `group_var' == `value'
								local wv_sum`i'_`value' = r(sum)
							}
							
							qui count if missing(`var') & `group_var' == `value' & `touse' == 1
							return scalar miss_`value' = r(N)
							qui count if `group_var' == `value' & `touse' == 1
							return scalar total_`value' = r(N)
							return scalar percent_`value' = (return(miss_`value')/return(total_`value') * 100)
							
							forvalues i = 1 / 2 {
								qui summ `var_`i'' if `touse' == 1 & missing(`var') & `group_var' == `value'
								return scalar miss_var_sum_`i'_`value' = r(sum)
								return scalar wv_sum_`i'_`value' = `wv_sum`i'_`value''
								return scalar w_percent_`i'_`value' = (return(miss_var_sum_`i'_`value') / return(wv_sum_`i'_`value') * 100)
							} 
							
							display as text %`=`c1'-2's "`value'" _column(`c1')"{c |} " ///
							as result %11.0gc `return(miss_`value')' "    "     ///
							%11.0gc `return(total_`value')' "       " ///
							%8.2f `return(percent_`value')' "       " ///
							%8.2f `return(w_percent_1_`value')' "                " ///
							%8.2f `return(w_percent_2_`value')'
				
					}	
						
					}
					
					if `nvars_weight' == 3 {
						
						qui count if missing(`var') & `touse' == 1
						return scalar miss = r(N)

						return scalar total = scalar(`total')
						return scalar percent = (return(miss)/return(total) * 100)
						
						forvalues i = 1/3 {
							qui summ `var_`i'' if `touse' == 1 & missing(`var')
							return scalar miss_var_sum_`i' = r(sum)
							return scalar wv_sum_`i' = `wv_sum`i''
							return scalar w_percent_`i' = (return(miss_var_sum_`i') / return(wv_sum_`i') * 100)				
						}
						
						display as text %`=`c1'-2's abbrev("`var'",`abbreviate') _column(`c1')"{c |} " ///
						as result %11.0gc `return(miss)' "    "     ///
						%11.0gc `return(total)' "       " ///
						%8.2f `return(percent)' "       " ///
						%8.2f `return(w_percent_1)' "                " ///
						%8.2f `return(w_percent_2)' "                " ///
						%8.2f `return(w_percent_3)'
						
						display as text %`=`c1'-2's "`group_var':" _column(`c1')"{c |}"
						
						foreach value of local grp_vals {
							
							forvalues i = 1 / 3 {
								qui summ `var_`i'' if `group_var' == `value'
								local wv_sum`i'_`value' = r(sum)
							}
							
							qui count if missing(`var') & `group_var' == `value' & `touse' == 1
							return scalar miss_`value' = r(N)
							qui count if `group_var' == `value' & `touse' == 1
							return scalar total_`value' = r(N)
							return scalar percent_`value' = (return(miss_`value')/return(total_`value') * 100)
							
							forvalues i = 1 / 3 {
								qui summ `var_`i'' if `touse' == 1 & missing(`var') & `group_var' == `value'
								return scalar miss_var_sum_`i'_`value' = r(sum)
								return scalar wv_sum_`i'_`value' = `wv_sum`i'_`value''
								return scalar w_percent_`i'_`value' = (return(miss_var_sum_`i'_`value') / return(wv_sum_`i'_`value') * 100)
							} 
							
							display as text %`=`c1'-2's "`value'" _column(`c1')"{c |} " ///
							as result %11.0gc `return(miss_`value')' "    "     ///
							%11.0gc `return(total_`value')' "       " ///
							%8.2f `return(percent_`value')' "       " ///
							%8.2f `return(w_percent_1_`value')' "                " ///
							%8.2f `return(w_percent_2_`value')' "                " ///
							%8.2f `return(w_percent_3_`value')'
				
					}						
						
					}
				
				display as text %`=`c1'-2's " " _column(`c1')"{c |}"
				
			}
		}	
	}

		
	***********************************************
	* Generating the final stats on weighting var *
	***********************************************
	
		if `nvals_group' > 0 {
			display as text _n
		}
	
		if `nvars_weight' == 0 {
			
		}
		
		else if `nvars_weight' == 1 {
			
			display as text _n "Weighting variable statistics"
			
			display as text _n "    Variable" _column(`c1')"{c |}       Sum            Mean"
			display as text "{hline `c2'}{c +}{hline `c2'}{hline `c2'}"
		
			qui summ `var_1'
			local wv_sum = r(sum)
			local wv_sum: display %9.0fc `wv_sum'
			
			local wv_mean = round(r(mean),0.01)
			local wv_mean: display %9.2fc `wv_mean'
			
			display as text %`=`c1'-2's abbrev("`var_1'",`abbreviate') _column(`c1')"{c |}  `wv_sum'      `wv_mean'"
			
		}
		
		else if `nvars_weight' == 2 {
			
			display as text _n "Weighting variable statistics"
			
			display as text _n "    Variable" _column(`c1')"{c |}     Sum          Mean"
			display as text "{hline `c2'}{c +}{hline `c2'}{hline `c2'}"
			
			forvalues i = 1/2 {
				
			qui summ `var_`i''
			local wv_sum = r(sum)
			local wv_sum: display %9.0fc `wv_sum'
			
			local wv_mean = round(r(mean),0.01)
			local wv_mean: display %9.2fc `wv_mean'
			
			display as text %`=`c1'-2's abbrev("`var_`i''",`abbreviate') _column(`c1')"{c |}  `wv_sum'      `wv_mean'"
			
			}
			
		}
		
		else if `nvars_weight' == 3 {
			
			display as text _n "Weighting variable statistics"
			
			display as text _n "    Variable" _column(`c1')"{c |}     Sum          Mean"
			display as text "{hline `c2'}{c +}{hline `c2'}{hline `c2'}"
			
			forvalues i = 1/3 {
				
			qui summ `var_`i''
			local wv_sum = r(sum)
			local wv_sum: display %9.0fc `wv_sum'
			
			local wv_mean = round(r(mean),0.01)
			local wv_mean: display %9.2fc `wv_mean'
			
			display as text %`=`c1'-2's abbrev("`var_`i''",`abbreviate') _column(`c1')"{c |}  `wv_sum'      `wv_mean'"
			
			}

		}
		
	******************************************
	* Generating relevant missingness graphs *
	******************************************
	
		if !missing("`graph'"){	
			if missing("`tvar'") {
				if `nvars_weight' == 0 {
					foreach var of local varlist  {
							* Unweighted Graphs
							tempvar miss_var 
							gen `miss_var'= missing(`var')
							qui summ `miss_var'
							
							tempvar nmiss_var 
							gen `nmiss_var'= !missing(`var')
							qui summ `nmiss_var'
						
							graph pie `miss_var' `nmiss_var', ///
									title(`var') ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(`var', replace) nodraw									
					}
				
						graph combine `varlist', ///
							title("Share of Missing values") ///
							note(Note: Blue indicates missing values, size(small))
				}
				
				if `nvars_weight' == 1 {
					foreach var of local varlist  {
							* Unweighted Graphs
							tempvar miss_var 
							gen `miss_var'= missing(`var')
							qui summ `miss_var'
							
							tempvar nmiss_var 
							gen `nmiss_var'= !missing(`var')
							qui summ `nmiss_var'
						
							graph pie `miss_var' `nmiss_var', ///
									title("Unweighted" " ") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g1, replace) nodraw	
							
							* Weighted Graphs
							qui summ `var_1'
							tempvar wv_sum
							gen `wv_sum' = r(sum)
							
							qui summ `var_1' if missing(`var')
							tempvar wv_miss
							gen `wv_miss' = r(sum) 
							
							tempvar share_miss
							gen `share_miss' = `wv_miss' / `wv_sum'
							tempvar share_nmiss
							gen `share_nmiss' = 1 - `share_miss'
							
							graph pie `share_miss' `share_nmiss', ///
									title("Weighted" "(by `weight_var')") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g2, replace) nodraw
									
							qui graph combine g1 g2, ///
										title(Variable: `var') ///
										name(`var', replace) ///
										nodraw							
									
							}
				
						graph combine `varlist', ///
							title("Share of Missing values") ///
							note(Note: Blue indicates missing values, size(small))
				}
				
				if `nvars_weight' == 2 {
					foreach var of local varlist  {
							* Unweighted Graphs
							tempvar miss_var 
							gen `miss_var'= missing(`var')
							qui summ `miss_var'
							
							tempvar nmiss_var 
							gen `nmiss_var'= !missing(`var')
							qui summ `nmiss_var'
						
							graph pie `miss_var' `nmiss_var', ///
									title("Unweighted" " ") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g, replace) nodraw	
							
							* Weighted Graphs
							forvalues i = 1/2 {
							qui summ `var_`i''
							tempvar wv_sum
							gen `wv_sum' = r(sum)
							
							qui summ `var_`i'' if missing(`var')
							tempvar wv_miss
							gen `wv_miss' = r(sum) 
							
							tempvar share_miss
							gen `share_miss' = `wv_miss' / `wv_sum'
							tempvar share_nmiss
							gen `share_nmiss' = 1 - `share_miss'
							
							graph pie `share_miss' `share_nmiss', ///
									title("Weighted" "(by `var_`i'')") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g`i', replace) nodraw
							}
							
							qui graph combine g g1 g2, ///
										title(Variable: `var') ///
										name(`var', replace) ///
										nodraw ///
										rows(1)
									
							}
				
						graph combine `varlist', ///
							title("Share of Missing values") ///
							note(Note: Blue indicates missing values, size(small))
				}	
				
				if `nvars_weight' == 3 {
					foreach var of local varlist  {
							* Unweighted Graphs
							tempvar miss_var 
							gen `miss_var'= missing(`var')
							qui summ `miss_var'
							
							tempvar nmiss_var 
							gen `nmiss_var'= !missing(`var')
							qui summ `nmiss_var'
						
							graph pie `miss_var' `nmiss_var', ///
									title("Unweighted" " ") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g, replace) nodraw	
							
							* Weighted Graphs
							forvalues i = 1/3 {
							qui summ `var_`i''
							tempvar wv_sum
							gen `wv_sum' = r(sum)
							
							qui summ `var_`i'' if missing(`var')
							tempvar wv_miss
							gen `wv_miss' = r(sum) 
							
							tempvar share_miss
							gen `share_miss' = `wv_miss' / `wv_sum'
							tempvar share_nmiss
							gen `share_nmiss' = 1 - `share_miss'
							
							graph pie `share_miss' `share_nmiss', ///
									title("Weighted" "(by `var_`i'')") ///
									legend(off) ///
									plabel( _all per, for(%9.2f) size(medlarge)) ///
									name(g`i', replace) nodraw
							}
							
							qui graph combine g g1 g2 g3, ///
										title(Variable: `var') ///
										name(`var', replace) ///
										nodraw ///
										rows(1)
									
							}
				
						graph combine `varlist', ///
							title("Share of Missing values") ///
							note(Note: Blue indicates missing values, size(small))
				}	

			}
		}
		
		
		if `nvals_miss' > 0 {
			frame change default
			frame drop miss
		}
		
	
end
