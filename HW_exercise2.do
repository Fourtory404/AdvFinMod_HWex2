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















