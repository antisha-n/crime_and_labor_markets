**********************************************************************
* REGRESSIONS, PREDICTIONS, and SUMMARY VALUES FOR MOPAC PROJECT

/* GUIDE TO THE DO FILE

/PART -1
*-------DATA FILE: "28thJunecadcalls-2019-2022-oas.dta"  = Constructed datasets
*-------DATA FILE: "revised_predictions.dta" = coefficient and se predictions
*-------DATA FILE: "all_predictions.dta" = ub and lb of Confidence intervals included
				 
/PART-2
*-------DATA FILE: "yoy_variations.dta" = year-over-year variations
 
/PART-3   
*-------Excel Sheet no. 1,2,3,4 = Summarize yoy variation in 2023 & 2024 (all London)
           
/PART-4   
*-------DATA FILE: "quarterly_variations.dta" = yoy variation for all(8) quarters
        Excel Sheet 13 = summary values
 
/PART-5   
*-------DATA FILE: semester_variations.dta = yoy variation for all(4) semesters
        Excel Sheet 14 = summary values
 
/PART-6   
*-------DATA FILE: "gc_space-regressions_predictions.dta = predictions based on space-regressions across gc] 
*-------DATA FILE: gc_yoy_variations.dta = yoy_variation based on above predictions over space-regressions
*-------DATA FILE: Summary values
           2023   = "gc2023_yoy_predictions.dta"
                                    (colc_tenure)  : 2023 = Excel Sheet 5
                                     (colc_socio)  : 2023 = Excel Sheet 6             
           2024   = "gc2024_yoy_variations.dta"
                                    (colc_tenure)  : 2023 = Excel Sheet 7
                                     (colc_socio)  : 2023 = Excel Sheet 8          
 
/PART - 7
*-------DATA FILE: "gc_quarterly_variations.dta" = yoy variation for all(8) quarters in each gc
                              Output (colc_tenure) : 2023 = Excel Sheet 9
                                                      2024 = Excel Sheet 10
                              Output (colc_socio)  : 2023 = Excel Sheet 11
                                                      2024 = Excel Sheet 12

/PART - 8
*-------DATA FILE: "gc_semester_variations.dta" = yoy variation for all(4) semesters in each gc
                              Output (colc_tenure)  : 2023 = Excel Sheet 13
                                                       2024 = Excel Sheet 14
                               Output (colc_socio)  : 2023 = Excel Sheet 15
                                                       2024 = Excel Sheet 16         */


 clear all
 
 cd "J:\Met\COL"
 
*Load datasets
 use "J:\Met\COL\28thJunecadcalls-2019-2022-oas.dta"
 sort OutputAreaCode modate
 
 **classifying violent crimes

egen violent=rowtotal(ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery BombThreat AbductionKidnap SexualOffencesRape)

replace violent=. if all==.
 
* Reduces dataset by removing unnecesary variables

drop ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered democraticcpih LocalAuthorityCode RegionCountryCode
					

**First regressions - MOPAC							

**  Test
	reghdfe all colc_tenure, absorb(oas year month) cluster(oas) 

	reghdfe all colc_socio, absorb(oas year month) cluster(oas) // runs baseline regression and checks whether the coefficient, std error, observations, are the same as in the original file

/* Baseline Regressions
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent
local iv colc_tenure colc_socio

	foreach var of local iv {
	foreach v of local dv {

			qui reghdfe `v' `var', absorb(oas year month) cluster(oas)
			outreg2 using firstregs_mopac_22.xls, append excel keep(`var') dec(3) ctitle(`v')
	}
}

*/
		 
encode month, gen(Month)
 
** predictions
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent

	foreach v of local dv {

			qui reghdfe `v' colc_tenure i.year i.Month, absorb(oas) cluster(oas) // year FE and month FE
			predict `v'_pred1_t, xb // fitted value
			predict `v'_se1_t, stdp  // std error
			
			qui reghdfe `v' colc_socio i.year i.Month, absorb(oas) cluster(oas) //  year FE and month FE
			predict `v'_pred2_t, xb // fitted value
			predict `v'_se2_t, stdp	 // std error

	}

			
save "revised_predictions.dta", replace

*****************************************************************************
//CALCULATING UPPER AND LOWER BOUND OF CI of PREDICTED COEFFICIENTS against colc_tenure and colc_socio

use "revised_predictions.dta", clear

//drop variables
drop colc_tenure colc_socio all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc shape_area mergeone violent
	

//COLC_TENURE
*************

//Calculating upper_bound_CI of predicted-coefficients against colc_tenure
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred1_t_ub = `x'_pred1_t + 1.96 * `x'_se1_t, after(`x'_se1_t)
	
}
				
//Calculating lower_bound_CI of predicted-coefficients against colc_tenure	
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred1_t_lb = `x'_pred1_t - 1.96 * `x'_se1_t, after(`x'_se1_t)
	
}
		
		
	
//COLC_SOCIO
************ 


//Calculating upper_bound_CI of predicted-coefficients against colc_tenure
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred2_t_ub = `x'_pred2_t + 1.96 * `x'_se2_t, after(`x'_se2_t)
	
}

				
//Calculating lower_bound_CI of predicted-coefficients against colc_tenure	
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred2_t_lb = `x'_pred2_t - 1.96 * `x'_se2_t, after(`x'_se2_t)
	
}

	
save "all_predictions.dta", replace

*****************************************************************************
// PART -2
//Year-over-year variations for the predictions

use "all_predictions.dta", clear

//drop predicted standard errors
drop all_se1_t all_se2_t crime_se1_t crime_se2_t transport_se1_t transport_se2_t antisocial_se1_t antisocial_se2_t publicsafety_se1_t publicsafety_se2_t admin_se1_t admin_se2_t covid_se1_t covid_se2_t mpsqualifiers_se1_t mpsqualifiers_se2_t systemuse_se1_t systemuse_se2_t misc_se1_t misc_se2_t violent_se1_t violent_se2_t

//Declare Panel data set
 sort oas monthly
 xtset oas monthly
 
//Generate year-over-year variation for crimes against colc_socio and colc_tenure

 local dv all_pred1_t all_pred1_t_lb all_pred1_t_ub all_pred2_t all_pred2_t_lb all_pred2_t_ub crime_pred1_t crime_pred1_t_lb crime_pred1_t_ub crime_pred2_t crime_pred2_t_lb crime_pred2_t_ub transport_pred1_t transport_pred1_t_lb transport_pred1_t_ub transport_pred2_t transport_pred2_t_lb transport_pred2_t_ub antisocial_pred1_t antisocial_pred1_t_lb antisocial_pred1_t_ub antisocial_pred2_t antisocial_pred2_t_lb antisocial_pred2_t_ub publicsafety_pred1_t publicsafety_pred1_t_lb publicsafety_pred1_t_ub publicsafety_pred2_t publicsafety_pred2_t_lb publicsafety_pred2_t_ub admin_pred1_t admin_pred1_t_lb admin_pred1_t_ub admin_pred2_t admin_pred2_t_lb admin_pred2_t_ub covid_pred1_t covid_pred1_t_lb covid_pred1_t_ub covid_pred2_t covid_pred2_t_lb covid_pred2_t_ub mpsqualifiers_pred1_t mpsqualifiers_pred1_t_lb mpsqualifiers_pred1_t_ub mpsqualifiers_pred2_t mpsqualifiers_pred2_t_lb mpsqualifiers_pred2_t_ub systemuse_pred1_t systemuse_pred1_t_lb systemuse_pred1_t_ub systemuse_pred2_t systemuse_pred2_t_lb systemuse_pred2_t_ub misc_pred1_t misc_pred1_t_lb misc_pred1_t_ub misc_pred2_t misc_pred2_t_lb misc_pred2_t_ub violent_pred1_t violent_pred1_t_lb violent_pred1_t_ub violent_pred2_t violent_pred2_t_lb violent_pred2_t_ub

 foreach v of local dv{
 	generate yoy_`v' = ((`v' / L12.`v')-1)*100
 }
 
 
 //keep variables of yoy-variations
 
 keep OutputAreaCode oas modate monthly year month Month Period spgc gc sbgc yoy_all_pred1_t yoy_all_pred1_t_lb yoy_all_pred1_t_ub yoy_all_pred2_t yoy_all_pred2_t_lb yoy_all_pred2_t_ub yoy_crime_pred1_t yoy_crime_pred1_t_lb yoy_crime_pred1_t_ub yoy_crime_pred2_t yoy_crime_pred2_t_lb yoy_crime_pred2_t_ub yoy_transport_pred1_t yoy_transport_pred1_t_lb yoy_transport_pred1_t_ub yoy_transport_pred2_t yoy_transport_pred2_t_lb yoy_transport_pred2_t_ub yoy_antisocial_pred1_t yoy_antisocial_pred1_t_lb yoy_antisocial_pred1_t_ub yoy_antisocial_pred2_t yoy_antisocial_pred2_t_lb yoy_antisocial_pred2_t_ub yoy_publicsafety_pred1_t yoy_publicsafety_pred1_t_lb yoy_publicsafety_pred1_t_ub yoy_publicsafety_pred2_t yoy_publicsafety_pred2_t_lb yoy_publicsafety_pred2_t_ub yoy_admin_pred1_t yoy_admin_pred1_t_lb yoy_admin_pred1_t_ub yoy_admin_pred2_t yoy_admin_pred2_t_lb yoy_admin_pred2_t_ub yoy_covid_pred1_t yoy_covid_pred1_t_lb yoy_covid_pred1_t_ub yoy_covid_pred2_t yoy_covid_pred2_t_lb yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred1_t yoy_mpsqualifiers_pred1_t_lb yoy_mpsqualifiers_pred1_t_ub yoy_mpsqualifiers_pred2_t yoy_mpsqualifiers_pred2_t_lb yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred1_t yoy_systemuse_pred1_t_lb yoy_systemuse_pred1_t_ub yoy_systemuse_pred2_t yoy_systemuse_pred2_t_lb yoy_systemuse_pred2_t_ub yoy_misc_pred1_t yoy_misc_pred1_t_lb yoy_misc_pred1_t_ub yoy_misc_pred2_t yoy_misc_pred2_t_lb yoy_misc_pred2_t_ub yoy_violent_pred1_t yoy_violent_pred1_t_lb yoy_violent_pred1_t_ub yoy_violent_pred2_t yoy_violent_pred2_t_lb yoy_violent_pred2_t_ub
 
 //sort dataset
 sort OutputAreaCode modate
 
 //save the file
 save "yoy_variations.dta", replace


*****************************************************************************
// PART - 3
// 2023 Average year-over-year variation for all London
*******************************************************

 cd "J:\Met\COL"
 
 use "yoy_variations.dta", clear

 sort oas modate year month


//COLC_TENURE
*************
** 2023-London's yoy variation in predicted-crime against forecasted colc_tenure

summarize yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t if year==2023

** 2023-London's yoy variation in predicted_lb_confidence-interval 

summarize yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb if year==2023

** 2023-London's yoy variation in predicted_ub_confidence-interval 

summarize yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub if year==2023

//COLC_SOCIO
************

** 2023-London's yoy variation in predicted-crime against forecasted colc_socio

summarize yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t if year==2023

** 2023-London's yoy variation in predicted_lb_confidence-interval 

summarize yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb if year==2023

** 2023-London's yoy variation in predicted_ub_confidence-interval 

summarize yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub if year==2023


// 2024 Average year-over-year variation for all London
*******************************************************

//COLC_TENURE
*************
** 2024-London's yoy variation in predicted-crime against forecasted colc_tenure

summarize yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t if year==2024

** 2024-London's yoy variation in predicted_lb_confidence-interval 

summarize yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb if year==2024

** 2024-London's yoy variation in predicted_ub_confidence-interval 

summarize yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub if year==2024

//COLC_SOCIO
************

** 2024-London's yoy variation in predicted-crime against forecasted colc_socio

summarize yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t if year==2024

** 2024-London's yoy variation in predicted_lb_confidence-interval 

summarize yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb if year==2024

** 2024-London's yoy variation in predicted_ub_confidence-interval 

summarize yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub if year==2024


****************************************************************************************

//PART -4

// Average year-over-year variation for all quarters (8 quarters) for all London

use "yoy_variations.dta", clear

**keep if year>2022
sort oas year monthly
keep if year>2022

**generate quarter indicators
generate Quarter = "Q1" if month=="Jan" | month=="Feb" | month=="Mar" 
replace Quarter = "Q2" if month=="Apr" | month=="May" | month=="Jun" 
replace Quarter = "Q3" if month=="Jul" | month=="Aug" | month=="Sep" 
replace Quarter = "Q4" if month=="Oct" | month=="Nov" | month=="Dec" 

encode Quarter, gen(quarter)

**Collapsing the dataset by yearly-average

collapse (mean) yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(year quarter)

//sort dataset
sort year quarter

//save file
save "quarterly_variations.dta", replace


****************************************************************************************
//PART-5

// Average year-over-year variation for all semesters (4 semesters) for all London

use "yoy_variations.dta", clear

**keep if year>2022
sort oas year monthly
keep if year>2022

**generate semester indicators
generate Semester= "S1" if month=="Jan" | month=="Feb" | month=="Mar" | month=="Apr" | month=="May" | month=="Jun" 

replace Semester = "S2" if month=="Jul" | month=="Aug" | month=="Sep" | month=="Oct" | month=="Nov" | month=="Dec"

encode Semester, gen(semester)

**Collapsing the dataset by semester-average

collapse (mean) yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(year semester)


*****
//July 10th //Only across colc_tenure
******

** Tabulate yoy-variation in predicted point estimates for all semesters in 2023 and 2024

bysort year: tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(semester) stat(mean)

bysort semester: tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(year) stat(mean)

** Tabulate yoy-variation in predicted lower_bound_CI for all-semesters in 2023 and 2024

bysort year: tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(semester) stat(mean)

bysort semester: tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(year) stat(mean)


** Tabulate yoy-variation in upper_bound_CI for all-semesters in 2023 and 2024 

bysort year: tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(semester) stat(mean)

bysort semester: tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(year) stat(mean)


****

//save file
sort year semester

save "semester_variations.dta", replace

*****************************************************************************************
//PART - 6

//Average year-over-year variation in 2023 for each group-code

//Firstly executing space-regressions and then prediction commmands

 clear all
 
 cd "J:\Met\COL"
 
*Load datasets
 use "J:\Met\COL\28thJunecadcalls-2019-2022-oas.dta"
 sort OutputAreaCode modate
 
 **classifying violent crimes

egen violent=rowtotal(ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery BombThreat AbductionKidnap SexualOffencesRape)

replace violent=. if all==.
 
* Reduces dataset by removing unnecesary variables

drop ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered democraticcpih LocalAuthorityCode RegionCountryCode			

 encode month, gen(Month)
		 
** Run space-regression

local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent

	foreach v of local dv {

			qui reghdfe `v' c.colc_tenure#i.gc i.year i.Month, absorb(oas) cluster(oas) // year FE and month FE
			predict `v'_pred1_t, xb // fitted value
			predict `v'_se1_t, stdp  // std error
			
			qui reghdfe `v' c.colc_socio#i.gc i.year i.Month, absorb(oas) cluster(oas) //  year FE and month FE
			predict `v'_pred2_t, xb // fitted value
			predict `v'_se2_t, stdp	 // std error

	}

//save gc-space-regression-prediction
save "gc_space-regressions_predictions.dta", replace

********************************************

//CALCULATING CONFIDENCE-INTERVALS' UPPER AND LOWER BOUND

use "gc_space-regressions_predictions.dta", clear

//drop variables
drop colc_tenure colc_socio all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc shape_area mergeone violent
		

//COLC_TENURE
*************

//Calculating upper_bound_CI of predicted-coefficients against colc_tenure
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred1_t_ub = `x'_pred1_t + 1.96 * `x'_se1_t, after(`x'_se1_t)
	
}
				
//Calculating lower_bound_CI of predicted-coefficients against colc_tenure	
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred1_t_lb = `x'_pred1_t - 1.96 * `x'_se1_t, after(`x'_se1_t)
	
}
			
	
//COLC_SOCIO
************ 


//Calculating upper_bound_CI of predicted-coefficients against colc_tenure
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred2_t_ub = `x'_pred2_t + 1.96 * `x'_se2_t, after(`x'_se2_t)
	
}

				
//Calculating lower_bound_CI of predicted-coefficients against colc_tenure	
	
	foreach x in all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc violent {
	
	gen `x'_pred2_t_lb = `x'_pred2_t - 1.96 * `x'_se2_t, after(`x'_se2_t)
	
}

	
save "gc_space-regressions_predictions.dta", replace

**********************************************

//year-over-year variations from predicted coefficients across space-regressions

use "gc_space-regressions_predictions.dta", clear

//drop predicted standard errors
drop all_se1_t all_se2_t crime_se1_t crime_se2_t transport_se1_t transport_se2_t antisocial_se1_t antisocial_se2_t publicsafety_se1_t publicsafety_se2_t admin_se1_t admin_se2_t covid_se1_t covid_se2_t mpsqualifiers_se1_t mpsqualifiers_se2_t systemuse_se1_t systemuse_se2_t misc_se1_t misc_se2_t violent_se1_t violent_se2_t

//Declare Panel data set
 sort oas monthly
 xtset oas monthly
 
//Generate year-over-year variation for crimes against colc_socio and colc_tenure

 local dv all_pred1_t all_pred1_t_lb all_pred1_t_ub all_pred2_t all_pred2_t_lb all_pred2_t_ub crime_pred1_t crime_pred1_t_lb crime_pred1_t_ub crime_pred2_t crime_pred2_t_lb crime_pred2_t_ub transport_pred1_t transport_pred1_t_lb transport_pred1_t_ub transport_pred2_t transport_pred2_t_lb transport_pred2_t_ub antisocial_pred1_t antisocial_pred1_t_lb antisocial_pred1_t_ub antisocial_pred2_t antisocial_pred2_t_lb antisocial_pred2_t_ub publicsafety_pred1_t publicsafety_pred1_t_lb publicsafety_pred1_t_ub publicsafety_pred2_t publicsafety_pred2_t_lb publicsafety_pred2_t_ub admin_pred1_t admin_pred1_t_lb admin_pred1_t_ub admin_pred2_t admin_pred2_t_lb admin_pred2_t_ub covid_pred1_t covid_pred1_t_lb covid_pred1_t_ub covid_pred2_t covid_pred2_t_lb covid_pred2_t_ub mpsqualifiers_pred1_t mpsqualifiers_pred1_t_lb mpsqualifiers_pred1_t_ub mpsqualifiers_pred2_t mpsqualifiers_pred2_t_lb mpsqualifiers_pred2_t_ub systemuse_pred1_t systemuse_pred1_t_lb systemuse_pred1_t_ub systemuse_pred2_t systemuse_pred2_t_lb systemuse_pred2_t_ub misc_pred1_t misc_pred1_t_lb misc_pred1_t_ub misc_pred2_t misc_pred2_t_lb misc_pred2_t_ub violent_pred1_t violent_pred1_t_lb violent_pred1_t_ub violent_pred2_t violent_pred2_t_lb violent_pred2_t_ub

 foreach v of local dv{
 	generate yoy_`v' = ((`v' / L12.`v')-1)*100
 }
 
 
 //keep variables of yoy-variations
 
 keep OutputAreaCode oas modate monthly year month Month Period spgc gc sbgc yoy_all_pred1_t yoy_all_pred1_t_lb yoy_all_pred1_t_ub yoy_all_pred2_t yoy_all_pred2_t_lb yoy_all_pred2_t_ub yoy_crime_pred1_t yoy_crime_pred1_t_lb yoy_crime_pred1_t_ub yoy_crime_pred2_t yoy_crime_pred2_t_lb yoy_crime_pred2_t_ub yoy_transport_pred1_t yoy_transport_pred1_t_lb yoy_transport_pred1_t_ub yoy_transport_pred2_t yoy_transport_pred2_t_lb yoy_transport_pred2_t_ub yoy_antisocial_pred1_t yoy_antisocial_pred1_t_lb yoy_antisocial_pred1_t_ub yoy_antisocial_pred2_t yoy_antisocial_pred2_t_lb yoy_antisocial_pred2_t_ub yoy_publicsafety_pred1_t yoy_publicsafety_pred1_t_lb yoy_publicsafety_pred1_t_ub yoy_publicsafety_pred2_t yoy_publicsafety_pred2_t_lb yoy_publicsafety_pred2_t_ub yoy_admin_pred1_t yoy_admin_pred1_t_lb yoy_admin_pred1_t_ub yoy_admin_pred2_t yoy_admin_pred2_t_lb yoy_admin_pred2_t_ub yoy_covid_pred1_t yoy_covid_pred1_t_lb yoy_covid_pred1_t_ub yoy_covid_pred2_t yoy_covid_pred2_t_lb yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred1_t yoy_mpsqualifiers_pred1_t_lb yoy_mpsqualifiers_pred1_t_ub yoy_mpsqualifiers_pred2_t yoy_mpsqualifiers_pred2_t_lb yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred1_t yoy_systemuse_pred1_t_lb yoy_systemuse_pred1_t_ub yoy_systemuse_pred2_t yoy_systemuse_pred2_t_lb yoy_systemuse_pred2_t_ub yoy_misc_pred1_t yoy_misc_pred1_t_lb yoy_misc_pred1_t_ub yoy_misc_pred2_t yoy_misc_pred2_t_lb yoy_misc_pred2_t_ub yoy_violent_pred1_t yoy_violent_pred1_t_lb yoy_violent_pred1_t_ub yoy_violent_pred2_t yoy_violent_pred2_t_lb yoy_violent_pred2_t_ub
 
 //sort dataset
 sort OutputAreaCode modate

//save file
save "gc_yoy_variations.dta", replace

*************************************
use "gc_yoy_variations.dta", clear

// GC 2023 SUMMARY

**keep if year==2023
sort oas year monthly
keep if year==2023

**Collapsing the dataset by gc categories

collapse (mean)  yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(gc)

*SUMMARY

summarize

//COLC_TENURE
************

** tabulate yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(gc) stat(mean)

** tabulate lower-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(gc) stat(mean)

** tabulate upper-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(gc) stat(mean)

//COLC_SOCIO
************

** tabulating yoy-variation in crimes against colc_socio for each gc
tabstat yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t, by(gc) stat(mean)

** tabulate lower-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb, by(gc) stat(mean)

** tabulate upper-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub, by(gc) stat(mean)

save "gc2023_yoy_predictions.dta", replace

******************************************************************************************//PART -6

// GC 2024 SUMMARY

** Average year-over-year variation in 2024 for each group-code

use "gc_yoy_variations.dta", clear

**keep if year==2024
sort oas year monthly
keep if year==2024

**Collapsing the dataset by gc categories

collapse (mean)  yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(gc)

summarize

//COLC_TENURE
*************

** tabulating yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(gc) stat(mean)

** tabulate lower-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(gc) stat(mean)

** tabulate upper-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(gc) stat(mean)

//COLC_SOCIO
************

** tabulating yoy-variation in crimes against colc_socio for each gc
tabstat yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t, by(gc) stat(mean)

** tabulate lower-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb, by(gc) stat(mean)

** tabulate upper-bound_confidence interval yoy-variation in crimes against colc_tenure for each gc
tabstat yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub, by(gc) stat(mean)


save "gc2024_yoy_variations.dta", replace

**************************************************************************************

//PART - 7
// Average year-over-year variation for all quarters (8 quarters) for each group code

use "gc_yoy_variations.dta", clear


**keep if year>2022
sort oas year monthly
keep if year>2022


generate Quarter = "Q1" if month=="Jan" | month=="Feb" | month=="Mar" 
replace Quarter = "Q2" if month=="Apr" | month=="May" | month=="Jun" 
replace Quarter = "Q3" if month=="Jul" | month=="Aug" | month=="Sep" 
replace Quarter = "Q4" if month=="Oct" | month=="Nov" | month=="Dec" 

encode Quarter, gen(quarter)

**Collapsing the dataset by quarterly-gc-average

collapse (mean) yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(gc year quarter)

//SUMMARY

//COLC_TENURE
*************
** Tabulate yoy-variation in predicted-crime in each gc for all-8quarters against colc_tenure

bysort year: tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(gc) stat(mean)

** Tabulate yoy-variation in lower_bound_CI in each gc for all-8quarters 

bysort year: tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(gc) stat(mean)

** Tabulate yoy-variation in upper_bound_CI in each gc for all-8quarters 

bysort year: tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(gc) stat(mean)

//COLC_SOCIO
************

** Tabulate yoy-variation in predicted-crime in each gc for all-8quarters against colc_socio

bysort year: tabstat yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t, by(gc) stat(mean)

** Tabulate yoy-variation in lower_bound_CI in each gc for all-8quarters  

bysort year: tabstat yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb, by(gc) stat(mean)

** Tabulate yoy-variation in upper_bound_CI in each gc for all-8quarters 

bysort year: tabstat yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub, by(gc) stat(mean)


//save file
sort gc year quarter 

save "gc_quarterly_variations.dta", replace

**************************************************************************************

//PART-8

// Average year-over-year variation for all semesters (4 semesters) for each gc

use "gc_yoy_variations.dta", clear

**keep if year>2022
sort oas year monthly
keep if year>2022

generate Semester= "S1" if month=="Jan" | month=="Feb" | month=="Mar" | month=="Apr" | month=="May" | month=="Jun" 

replace Semester = "S2" if month=="Jul" | month=="Aug" | month=="Sep" | month=="Oct" | month=="Nov" | month=="Dec"

encode Semester, gen(semester)

**Collapsing the dataset by semester-average

collapse (mean) yoy_all_pred1_t - yoy_violent_pred2_t_ub, by(gc year semester)

//SUMMARY 2023 and 2024 seperately

//COLC_TENURE
*************
** Tabulate yoy-variation in predicted-crime in each gc for all-4 semsters colc_tenure

bysort year (semester): tabstat yoy_all_pred1_t yoy_crime_pred1_t yoy_transport_pred1_t yoy_antisocial_pred1_t yoy_publicsafety_pred1_t yoy_admin_pred1_t yoy_covid_pred1_t yoy_mpsqualifiers_pred1_t yoy_systemuse_pred1_t yoy_misc_pred1_t yoy_violent_pred1_t, by(gc) stat(mean)

** Tabulate yoy-variation in lower_bound_CI in each gc for all-4 semsters 

bysort year (semester): tabstat yoy_all_pred1_t_lb yoy_crime_pred1_t_lb yoy_transport_pred1_t_lb yoy_antisocial_pred1_t_lb yoy_publicsafety_pred1_t_lb yoy_admin_pred1_t_lb yoy_covid_pred1_t_lb yoy_mpsqualifiers_pred1_t_lb yoy_systemuse_pred1_t_lb yoy_misc_pred1_t_lb yoy_violent_pred1_t_lb, by(gc) stat(mean)

** Tabulate yoy-variation in upper_bound_CI in each gc for all-4 semsters 

bysort year (semester): tabstat yoy_all_pred1_t_ub yoy_crime_pred1_t_ub yoy_transport_pred1_t_ub yoy_antisocial_pred1_t_ub yoy_publicsafety_pred1_t_ub yoy_admin_pred1_t_ub yoy_covid_pred1_t_ub yoy_mpsqualifiers_pred1_t_ub yoy_systemuse_pred1_t_ub yoy_misc_pred1_t_ub yoy_violent_pred1_t_ub, by(gc) stat(mean)


//COLC_SOCIO
************

** Tabulate yoy-variation in predicted-crime in each gc for all-4 semsters against colc_socio

bysort year (semester): tabstat yoy_all_pred2_t yoy_crime_pred2_t yoy_transport_pred2_t yoy_antisocial_pred2_t yoy_publicsafety_pred2_t yoy_admin_pred2_t yoy_covid_pred2_t yoy_mpsqualifiers_pred2_t yoy_systemuse_pred2_t yoy_misc_pred2_t yoy_violent_pred2_t, by(gc) stat(mean)

** Tabulate yoy-variation in lower_bound_CI in each gc for all-4 semsters  

bysort year (semester): tabstat yoy_all_pred2_t_lb yoy_crime_pred2_t_lb yoy_transport_pred2_t_lb yoy_antisocial_pred2_t_lb yoy_publicsafety_pred2_t_lb yoy_admin_pred2_t_lb yoy_covid_pred2_t_lb yoy_mpsqualifiers_pred2_t_lb yoy_systemuse_pred2_t_lb yoy_misc_pred2_t_lb yoy_violent_pred2_t_lb, by(gc) stat(mean)

** Tabulate yoy-variation in upper_bound_CI in each gc for all-4 semsters 

bysort year (semester): tabstat yoy_all_pred2_t_ub yoy_crime_pred2_t_ub yoy_transport_pred2_t_ub yoy_antisocial_pred2_t_ub yoy_publicsafety_pred2_t_ub yoy_admin_pred2_t_ub yoy_covid_pred2_t_ub yoy_mpsqualifiers_pred2_t_ub yoy_systemuse_pred2_t_ub yoy_misc_pred2_t_ub yoy_violent_pred2_t_ub, by(gc) stat(mean)


//save file
sort gc year semester
order gc year semester

save "gc_semester_variations.dta", replace



//end




