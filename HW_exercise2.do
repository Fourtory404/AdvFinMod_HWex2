cls
clear all

import excel "/Users/shiyiwen/Desktop/Advanced Fin Modeling/homework/HOMEWORKDATA.xls", sheet("DATAEX2") firstrow

*Author: Eleni Triantou, I-Wen Shih

* 1. Remove missing observations
drop if PBTLLPTA == "."
drop if ILTA == "."
drop if LTA == "."
* now there's only 7140 observations left, which we can use count function to check 


*2. a)
encode id, generate (id2)
drop id
rename id2 id

encode countrycode, generate (country2)
drop countrycode
rename country2 country

order id year country 

*2. b)
foreach var in PBTLLPTA LLPTA SIZE LTA ILTA{
	gen `var'_2 = real(`var')
	drop `var'
	rename `var'_2 `var'
}

*3. Generate the dummy variable LOSSES taking value equal to one if PBTLLPTA is negative and zero otherwise.
gen LOSSES = 0
replace LOSSES = 1 if PBTLLPTA < 0
label variable LOSSES "Negative earnings"

*4. What is this probability in the sample? Report it using a display command in a programmatic way.
sum LOSSES
display "Sample probability of negative earnings: " %6.4f r(mean)

*5. Report a customized table using the command tabstat
tabstat LLPTA PBTLLPTA LTA ILTA SIZE LOSSES, ///
    statistics(mean sd skewness kurtosis count min max) ///
    columns(statistics)

*6. Report the sample correlation between the variables in query 5) above.
pwcorr LLPTA PBTLLPTA LTA ILTA SIZE LOSSES, sig star(0.05)

*7. Drop all observations for which LLPTA is negative.

* Check how many observations you're dropping first
count if LLPTA < 0
display "Number of observations with negative LLPTA: " r(N)

* Check total observations before dropping
count
display "Total observations before filtering: " r(N)

* Drop the negative observations
drop if LLPTA < 0

* Check remaining observations
count
display "Remaining observations after filtering: " r(N)
* Before submitting: we could keep drop if LLPTA<0 this line only, others are just for clarification

*8. i.) Heteroskedasticity-robust standard errors (POLS):
regress LLPTA PBTLLPTA LTA ILTA SIZE, robust

*8. ii.) Two-way cluster-robust standard errors (individual and year):
* in order to do a two-way cluster-robust standard errors
egen id_year = group(id year)
regress LLPTA PBTLLPTA LTA ILTA SIZE, cluster(id_year)

*9. Building on the two-way cluster-robust standard errors, test the null hypothesis that the coefficients associated with LTA, ILTA and SIZE are jointly zero.
* Step 1: Run the regression
reghdfe LLPTA PBTLLPTA LTA ILTA SIZE, cluster(id_year)

* Step 2: Test joint significance
test LTA ILTA SIZE

* Step 3: Display results
display "F-statistic: " r(F)
display "p-value: " r(p)

*10. 











