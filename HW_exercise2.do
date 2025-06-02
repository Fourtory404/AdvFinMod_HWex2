cls
clear all

import excel "/Users/shiyiwen/Desktop/Advanced Fin Modeling/homework/HOMEWORKDATA.xls", sheet("DATAEX2") firstrow

*Author: Eleni Triantou, I-Wen Shih, Garrick Morlaes

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
estimates store robust_model

*8. ii.) Two-way cluster-robust standard errors (individual and year):
* in order to do a two-way cluster-robust standard errors
egen id_year = group(id year)
regress LLPTA PBTLLPTA LTA ILTA SIZE, cluster(id_year)
estimates store clustered_model

*8. comments: The outcomes of this two models are exactly the same data is likely cross-sectional (each firm appears only once) rather than panel data, making clustering irrelevant. (should be revised before submitting)
estimates table robust_model clustered_model, b(%9.4f) se(%9.4f)

*9. Building on the two-way cluster-robust standard errors, test the null hypothesis that the coefficients associated with LTA, ILTA and SIZE are jointly zero.
* Step 1: Run the regression
reghdfe LLPTA PBTLLPTA LTA ILTA SIZE, cluster(id_year)

* Step 2: Test joint significance
test LTA ILTA SIZE

* Step 3: Display results
display "F-statistic: " r(F)
display "p-value: " r(p)

*10. 
* Store the baseline model first
reghdfe LLPTA PBTLLPTA LTA ILTA SIZE, cluster(id_year)
estimates store baseline

* Store the extended model
reghdfe LLPTA PBTLLPTA LTA ILTA SIZE, ///
    absorb(country year) cluster(id_year)
estimates store extended

* Compare results
esttab baseline extended, ///
    title("Baseline vs Extended Model with Fixed Effects") ///
    mtitles("Baseline" "Country & Year FE") ///
    b(%9.4f) se(%9.4f) ///
    stats(N r2) star(* 0.10 ** 0.05 *** 0.01)

*10. (cont.) Do you notice any remarkable change with respect to the baseline model? 
* Ans. : (to be added, check before submitting)

*11. Test the null hypothesis that all the country-related dummy variables included in the model have associated a zero coefficient using an F-type test. 
reg LLPTA PBTLLPTA LTA ILTA SIZE i.country i.year
testparm i.country
* The above codes sometimes only works if we do it seperately, that is first do the codes for the first 10 question then start again from Q11

*12. Xtset the variables id and year to declare the panel-data nature of our data and enable the panel-data estimators in Stata.
xtset id 
xtset year

*13. Use xtreg to estimate the baseline model extended with FE at the individual level. Do we still observe evidence supporting earnings smoothing?
xtreg LLPTA PBTLLPTA LTA ILTA SIZE, fe robust
*estimates store fe_extended
* Ans. to be added!

*14. use xtreg to estimate the baseline model with FE at the individual level and time dummies controlling fixed effect. Can we still conclude that bank managers engage in earning-smoothing strategies when setting LLP?
xtreg LLPTA PBTLLPTA LTA ILTA SIZE i.year, fe robust
* Ans. to be added!

*15. Given the estimates of the previous model, test the hypothesis that all the time dummy variables included in the model are redundant building on an F test.
reg LLPTA PBTLLPTA LTA ILTA SIZE i.year
testparm i.year

*16. Estimate the baseline model with FE and RE using conventional standard errors. Given those estimates, implement the Hausman test. On the basis of the resulting evidence, which estimation technique is better suited on this sample?
xtreg LLPTA PBTLLPTA LTA ILTA SIZE, fe
estimates store fixed

xtreg LLPTA PBTLLPTA LTA ILTA SIZE, re
estimates store random

hausman fixed random, sigmamore
*baseline model with FE is better since it's more consistent under H0 and Ha, to add more!!
