
//probabiltiy weight is a pweigh in Stata calculated as N/n where N = the number of elements in the population and n = the number of elements in the sample. 

clear all
set more off, perm

//setting directory
cd "D:\Data\Seminars\Applied Survey Stata 15\"
fdause "D:\Data\Seminars\Applied Survey Stata 15\demo_g.xpt"
sort seqn
save "D:\Data\Seminars\Applied Survey Stata 15\demo_g", replace

* depression screener
clear
fdause "D:\Data\Seminars\Applied Survey Stata 15\dpq_g.xpt"
sort seqn
save "D:\Data\Seminars\Applied Survey Stata 15\dpq_g", replace

* current health status
clear
fdause "D:\Data\Seminars\Applied Survey Stata 15\hsq_g.xpt"
sort seqn
save "D:\Data\Seminars\Applied Survey Stata 15\hsq_g", replace

* physical activity
clear
cd ""
sort seqn
save "D:\Data\Seminars\Applied Survey Stata 15\paq_g", replace

clear
use "D:\Data\Seminars\Applied Survey Stata 15\demo_g"
merge 1:1 seqn using dpq_g, sorted gen(firstm)   
merge 1:1 seqn using hsq_g, sorted gen(secondm)
merge 1:1 seqn using paq_g, sorted gen(thirdm)

tab1 firstm secondm thirdm
count if firstm == 3 & secondm == 3 & thirdm == 3 
* 5615
drop firstm secondm thirdm

//svy prefix is used to specify that you are conducting analysis on survey data, taking into account the complex survey design, such as stratification, clustering, and unequal sampling weights. This prefix is used before various Stata commands to indicate that the analysis should be adjusted for the survey design to produce valid and accurate results.

svyset sdmvpsu [pw = wtint2yr], strata(sdmvstra) singleunit(centered)

//get information on the Strata and PSUs
svydescribe

//survey statistics

svy: mean age
estat sd
estat sd, var

//count when the figures are too large
svy: tab female, missing count cellwidth(15) format(%15.2g)

//Using the col option with svy: tab will give the column proportions. As you can see, the values in the column "Total" are the same as those from 

svy: tab female, col

svy: tab female rural, col 

//Using the estat post-estimation command after the svy: mean command also allows you to get the design effects, misspecification effects, unweighted and weighted sample sizes, or the coefficient of variation.

svy: mean age
estat effects
estat effects, deff deft meff meft
estat size
estat cv 

//diplay (any arithematic calculation)

gen b50subp = (race==2 & ager>=50)
svy, subpop(b50subp): mean 

svy, subpop(female): mean age
svy, subpop(is female != 1): mean age

//gives results for each category vairbale listed
svy, over(female): mean age

svy, subpop(female): mean copper, over(race region) 

***************************************************
//Data Visualisation


//Graphing with continuous variables
//We can also get some descriptive graphs of our variables. For a continuous variable, you may want a histogram. However, the histogram command will only accept a frequency weight, which, by definition, can have only integer values. 


gen int_finalwgt = int(finalwgt)
histogram copper [fw = int_finalwgt], bin(20)

histogram age [fw = int_finalwgt], bin(20) normal

graph box hct [pw = finalwgt]

graph box hct [pw = finalwgt], by(female)


twoway (scatter bpsystol bpdiast [pw = finalwgt]) (lfit bpsystol bpdiast [pw = finalwgt]), ///
title("Systolic Blood Pressure" "v. Diastolic Blood Pressure")

gen male = !female
graph bar (mean) female male [pw = finalwgt], percentages bargap(7) 

graph hbar copper [pw = finalwgt], over(race, gap(*2)) ///
title("Copper by race")

graph bar hct [pw = finalwgt], over(region, label(angle(45))) ///
title("Hemocrit by region")

save "D:\Data\Seminars\Applied Survey Stata 15\nhanes2012_merged", replace

label define gender 1 "male" 2 "female"
label values riagendr gender
svy: tab riagendr, missing count cellwidth(15) format(%15.2g)

label define race3 1 "Mexican American" 2 "Other Hispanic" 3 "White" 4 "Black" ///
6 "Asian" 7 "Other and Multi-racial"
label values ridreth3 race3

label define yesno 1 "yes" 0 "no" 7 "refused" 9 "dk"

recode dmqmiliz dmqadfc (2 = 0)

label values dmqmiliz dmqadfc yesno

replace dmqadfc = . if dmqadfc == 7 | dmqadfc == 9

label define cb 1 "born in US" 0 "born elsewhere" 77 "refused" 99 "dk"
label values dmdborn4 cb

replace dmdborn4 = . if dmdborn4 == 77 | dmdborn4 == 99
recode dmdborn4 (2 = 0)

label define cs 1 "citizen" 0 "not a citizen" 7 "refused"
label values dmdcitzn cs

replace dmdcitzn = . if dmdcitzn == 7
recode dmdcitzn (2 = 0)

label define lt 1 "less than 1 yr" 2 "1 yr, less than 5 yrs" ///
3 "5 yrs, less than 10 yrs" 4 "10 yrs, less than 15 yrs" ///
5 "15 yrs, less than 20 yrs" 6 "20 yrs, less than 30 yrs" ///
7 "30 yrs, less than 40 yrs" 8 "40 yrs, less than 50 yrs" 9 "50 yrs or more" ///
77 "refused" 99 "dk"

label values dmdyrsus lt

replace dmdyrsus = . if dmdyrsus == 77 | dmdyrsus == 99

label define edu 1 "less than 9th grade" 2 "no hs diploma" 3 "hs grad or GED" ///
4 "some college or AA degree" 5 "college grad or above" 7 "refused" 9 "dk"

label values dmdeduc2 edu
replace dmdeduc2 = . if dmdeduc2 == 7 | dmdeduc2 == 9

label define matsat 1 "married" 2 "widowed" 3 "divorced" 4 "separated" ///
5 "never married" 6 "living with partner" 77 "refused" 99 "dk"

label values dmdmartl matsat
replace dmdmartl = . if dmdmartl == 77 | dmdmartl == 99

* hsq
label define ghc 1 "excellent" 2 "very good" 3 "good" 4 "fair" 5 "poor" ///
7 "refused" 9 "dk"

label values hsd010 ghc
replace hsd010 = . if hsd010 == 7 | hsd010 == 9

replace hsq470 = . if hsq470 == 77 | hsq470 == 99

replace hsq480 = . if hsq480 == 77 | hsq480 == 99

replace hsq490 = . if hsq490 == 77 | hsq490 == 99

replace hsq493 = . if hsq493 == 77 | hsq493 == 99

replace hsq496 = . if hsq496 == 77 | hsq496 == 99

recode hsq500 hsq510 hsq520 hsq571 hsq590 (2 = 0)
label values hsq500 hsq510 hsq520 hsq571 hsq590 yesno
replace hsq500 = . if hsq500 == 7 | hsq500 == 9
replace hsq510 = . if hsq510 == 7 | hsq510 == 9
replace hsq520 = . if hsq520 == 7 | hsq520 == 9
replace hsq571 = . if hsq571 == 7 | hsq571 == 9
replace hsq590 = . if hsq590 == 7 | hsq590 == 9

* dpq
label define dur 0 "not at all" 1 "several days" 2 "more than half the days" ///
3 "nearly every day" 7 "refused" 9 "dk"

foreach var of varlist dpq010 - dpq100{
label values `var' dur
}
*label values dpq010 dpq020 dpq030 dpq040 dpq050 dpq060 dpq070 dpq080 dpq090 ///
*dpq100 dur

replace dpq010 = . if dpq010 == 7 | dpq010 == 9
replace dpq020 = . if dpq020 == 7 | dpq020 == 9
replace dpq030 = . if dpq030 == 7 | dpq030 == 9
replace dpq040 = . if dpq040 == 7 | dpq040 == 9
replace dpq050 = . if dpq050 == 7 | dpq050 == 9
replace dpq060 = . if dpq060 == 7 | dpq060 == 9
replace dpq070 = . if dpq070 == 7 | dpq070 == 9
replace dpq080 = . if dpq080 == 7 | dpq080 == 9
replace dpq090 = . if dpq090 == 7 | dpq090 == 9
replace dpq100 = . if dpq100 == 7 | dpq100 == 9

* physical activity
recode paq605 (2 = 0)
label values paq605 yesno
replace paq605 = . if paq605 == 7 | paq605 == 9

replace pad615 = . if pad615 == 9999

replace paq620 = . if paq620 == 7 | paq620 == 9

replace paq625 = . if paq625 == 99 

replace pad630 = . if pad630 == 9999

recode paq635 (2 = 0)
label values paq635 yesno
replace paq635 = . if paq635 == 7

replace paq640 = . if paq640 == 99

replace pad645 = . if pad645 == 9999

recode paq650 paq665 (2 = 0)
label values paq650 paq665 yesno
replace paq650 = . if paq650 == 7 | paq650 == 9

replace paq665 = . if paq665 == 7

replace paq670 = . if paq670 == 99

replace pad680 = . if pad680 == 7777 | pad680 == 9999

label define hours 0 "less than 1 hour" 1 "1 hour" 2 "2 hours" 3 "3 hours" ///
4 "4 hours" 5 "5 hours or more" 8 "do not watch TV or videos" 77 "refused" ///
99 "dk"

label values paq710 paq715 hours

replace paq710 = . if paq710 == 77 | paq710 == 99

replace paq715 = . if paq715 == 77 | paq715 == 99

recode riagendr (1 = 0) (2 = 1), gen(female)
label define fm 0 "male" 1 "female"
label values female fm

tab riagendr female
drop riagendr

save "D:\Data\Seminars\Applied Survey Stata 15\nhanes2012", replace

* begin analysis
* open dataset, issue -svyset- command and describe data
use "D:\Data\Seminars\Applied Survey Stata 15\nhanes2012", clear
svyset sdmvpsu [pweight = wtint2yr], strata(sdmvstra) singleunit(centered)

svydescribe
* 14 strata with either 2 or 3 PSUs per strata and a different number of obs 
* in each min = 140, mean = 314.7 and max = 388

* descriptives with continuous variables (including binary variables)
svy: mean ridageyr
estat sd
estat sd, var
svy: mean pad630
svy: mean hsq496
svy: mean ridageyr pad630 hsq496

* descriptives with binary variables
svy: mean female
estat sd
svy: mean dmdborn4
estat sd

svy: tab female

svy: tab female, missing count cellwidth(15) format(%15.2g)

svy: tab female dmdborn4, missing count cellwidth(15) format(%15.2g)
svy: tab female dmdborn4, col 

svy: proportion female

svy: mean ridageyr
estat effects
estat effects, deff deft meff meft
estat size
estat cv
display (.6964767/37.18519)*100

* subpops
svy: mean ridageyr
svy, subpop(female): mean ridageyr
svy, subpop(if female != 1): mean ridageyr
svy, over(female): mean ridageyr
svy, over(dmdmartl female): mean pad630

svy, subpop(female): mean pad630, over(dmdmartl dmdeduc2) 
estat size
list pad630 if female == 1 & dmdmartl == 6 & dmdeduc2 == 1

* comparing between two subpops
svy, over(female): mean hsq496
lincom [hsq496]male - [hsq496]female
display 4.589723 - 6.153479

svy, over(dmdmartl): mean hsq496
lincom [hsq496]married - [hsq496]_subpop_6
lincom [hsq496]married - [hsq496]widowed

* graphics

* need to create an weight variable with integer values to use as fw
capture drop int_wtint2yr
gen int_wtint2yr = int(wtint2yr)
histogram pad630 [fw = int_wtint2yr], bin(20)
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph1.png", replace
histogram ridageyr [fw = int_wtint2yr], bin(20) normal
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph2.png", replace

graph box hsq496 [pw = wtint2yr]
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph3.png", replace
graph box hsq496 [pw = wtint2yr], by(female) ylabel(0(5)30)
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph4.png", replace

svy, over(female): mean hsq496
estat sd

* population totals
svy: total pad630
estimates table, b(%15.2f) se(%13.2f)
estimates table, b(%15.0g) se(%12.0g)
svy: total pad630
matlist e(b), format(%15.2f)
svy, over(female): total pad630
estimates table, b(%15.2f) se(%13.2f)

* bivariate relationships
svy: mean pad630 pad675
twoway (scatter pad630 pad675 [pw = wtint2yr]) (lfit pad630 pad675 [pw = wtint2yr]), ///
title("minutes of moderate intensity work" ///
"v. minutes of moderate recreational activities")
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph5.png", replace

* descriptives with categorical variables

svy: tab dmdmartl
svy: proportion dmdmartl
svy: tab dmdmartl, count cellwidth(12) format(%12.2g)

* the order of the options does not determine how they will be displayed
svy: tab dmdmartl, cell count obs cellwidth(12) format(%12.2g) 
svy: tab dmdmartl, count se cellwidth(15) format(%15.2g)
* only five items can be displayed at once, and ci counts as two items 
svy: tab dmdmartl, count deff deft cv cellwidth(12) format(%12.2g) 

* the chi-square test is given by default
* usually want to use the design-based test.
svy: tab dmdmartl female, cell obs count cellwidth(12) format(%12.2g)
svy: proportion dmdmartl, over(female) 
lincom [married]male - [married]female
display .5463038 - .5164898

* graphing single variable
capture drop male
gen male = !female
graph bar (mean) female male [pw = wtint2yr], percentages bargap(7) 
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph6.png", replace

svy: mean hsq496, over(dmdmartl)
graph hbar hsq496 [pw = wtint2yr], over(dmdmartl, gap(*2)) ///
title("During the last 30 days, for about how many days" ///
"have you felt worried, tense or anxious?")
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph7.png", replace

svy: mean pad630, over(dmdeduc2)
graph bar pad630 [pw = wtint2yr], over(dmdeduc2, label(angle(45))) ///
title("How much time do you spend doing" ///
"moderate-intensity activities at work on a typical day?")
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph8.png", replace


* The following analyses are shown only as examples of how to do these analyses
* in Stata.  There was no attempt to create substantively meaningful models.
* Rather, variables were chosen only illustration purposes.
* We do not recommend that researchers create their models this way.

* OLS regression
svy: regress pad630 i.female ridageyr
margins female, vce(unconditional)
* not interesting without an interaction term
* margins , dydx(ridageyr) at(female=(0 1))

svy: regress pad630 i.female##i.hsq571 ridageyr
contrast female#hsq571, effects
* difference in differences
di (165.6268-125.2008)-(123.2404-142.0993)
margins female#hsq571, vce(unconditional)
marginsplot
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph9.png", replace

* regress, coeflegend
margins female#hsq571, vce(unconditional) post
margins, coeflegend
lincom (_b[0bn.female#0bn.hsq571]-_b[0bn.female#1.hsq571]) - (_b[1.female#0bn.hsq571]-_b[1.female#1.hsq571])

* https://www.cscu.cornell.edu/news/statnews/stnews73.pdf
/*
Generally,  when  comparing  two  parameter  estimates,  it  is  
always  true  that  if  the  confidence  intervals  do  not  
overlap, then the statistics will be statistically significantly different. 
However, the converse is not true.
 That is, 
it  is  erroneous  to  determine  the  statistical  signifi
cance  of  the  difference  between  two  statistics  based  on  
overlapping confidence intervals. 
*/
* https://towardsdatascience.com/why-overlapping-confidence-intervals-mean-nothing-about-statistical-significance-48360559900a
* males
lincom _b[0bn.female#0bn.hsq571]-_b[0bn.female#1.hsq571]
* females
lincom _b[1.female#0bn.hsq571]-_b[1.female#1.hsq571]

svy: regress pad630 i.female##c.pad680 
margins female, dydx(pad680) vce(unconditional)
margins female, at(pad680=(0(200)1400)) vsquish vce(unconditional)
marginsplot
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph10.png", replace

* getting the difference between the male and female values
margins, dydx(female) at(pad680=(0(200)1400)) vsquish vce(unconditional)
marginsplot, yline(0)
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph11.png", replace
quietly: margins, dydx(female) at(pad680=(0(200)1400)) vsquish vce(unconditional)
marginsplot, yline(0) recast(line) recastci(rarea) ciopts(color(*.2)) 
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph12.png", replace

* all pairwise comparisons with a categorical predictor variable
svy: regress pad630 i.dmdeduc2 ridageyr
contrast dmdeduc2
pwcompare dmdeduc2, mcompare(sidak) cformat(%3.1f) pveffects

* logistic regression
* paq665:  Do you do any moderate-intesity sports, fitness, or recreational 
* activities that cause a small increase in breathing or heart rate 
* such as brisk walking bicycling, swimming, or golf for at least 
* 10 minutes coninuously?
* hsd010:  General health condition:  3 = Good (the largest category)
* using hsd010 as a categorical predictor variable
svy, subpop(if ridageyr > 20): tab paq665, ///
cell obs count cellwidth(12) format(%12.2g)
svy, subpop(if ridageyr > 20): tab hsd010 paq665, ///
cell obs count cellwidth(12) format(%12.2g)

svy, subpop(if ridageyr > 20): logit paq665 ib3.hsd010 c.ridageyr
contrast hsd010

svy, subpop(if ridageyr > 20): logit paq665 ib3.hsd010##c.ridageyr
contrast hsd010#c.ridageyr
margins hsd010, subpop(if ridageyr > 20) at(ridageyr=(20(10)80)) ///
vsquish vce(unconditional)
marginsplot
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph13.png", replace

svy: logit paq665 i.female##c.pad680 
estat gof

* ordered logistic
svy: ologit dmdeduc2 i.female i.dmdborn4 pad680
ologit, or

* multinomial logistic
svy: mlogit dmdmartl i.female i.dmdborn4 ridageyr
mlogit, rrr
svy: mlogit dmdmartl i.female i.dmdborn4, base(5)
svy: mlogit dmdmartl i.female##i.dmdborn4 ridageyr, base(5)
* notice the test of the overall model
* click on it to see the help file, which explains both the problem
* and how the degrees of freedom are calculated
svy: mlogit dmdmartl i.female##i.dmdborn4, base(5)
contrast female#dmdborn4 // not significant
margins female#dmdborn4, vce(unconditional) // values are pretty similar within outcome category
marginsplot
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph14.png", replace

* poisson
svy: poisson pad675 i.female
svy: mean pad675
estat sd
di (59.20373)^2
svy: mean pad675, over(female)
estat sd

* negative binomial
* pad675 is very right skewed
* notice no LR test of alpha = 0
* no pseudo-R-squared
svy: nbreg pad675 i.female
margins female, vce(unconditional)

svy: nbreg pad675 i.female##c.ridageyr
margins female, at(ridageyr=(20(10)60)) vce(unconditional)
marginsplot // two parallel lines
graph export "D:\Data\Seminars\Applied Survey Stata 15\graph15.png", replace

* list of commands available in Stata 15