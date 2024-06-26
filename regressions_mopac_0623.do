									
**********************************************************************
* Runs regressions for MOPAC-COLC project *
* Shubhangi Agrawal <shubhangiagrawal8@gmail.com>
* Magdalena Dominguez <m.dominguez2@lse.ac.uk>
**********************************************************************

* Current Directory
*cd "/Users/shubhangiagrawal/Dropbox/MOPAC_COLC"
cd "C:\Users\DOMING28\Dropbox\2022 Dominguez LSE\MOPAC_COLC"
*cd "C:\Users\mdomi\Dropbox\2022 Dominguez LSE\MOPAC_COLC"
**********************************************************************


** First regressions - MOPAC
								
use "mopac_merged_april23.dta", replace								

local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
local iv colc_tenure colc_socio

	foreach var of local iv {
	foreach v of local dv {

			qui reghdfe `v' `var', absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623.xls, append excel keep(`var') dec(3) ctitle(`v')
	}
}

local dv ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered
local iv colc_tenure colc_socio

	foreach var of local iv {
foreach v of local dv {

			qui reghdfe `v' `var', absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_detailed.xls, append excel keep(`var') dec(3) ctitle(`v')
	}
}





** Time regressions - MOPAC

use "mopac_merged_april23.dta", replace								

local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
local iv colc_tenure colc_socio

foreach var of local iv {
foreach v of local dv {

			qui reghdfe `v' c.`var'#i.modate, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_time.xls, append excel drop(_cons) dec(3)  ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.modate, absorb(oas year month) cluster(oas)
			est store est_`v'
			coefplot (est_`v', drop(_cons) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "2019m1" 2 "2019m2" 3 "2019m3" 4 "2019m4" 5 "2019m5" 6 "2019m6" 7 "2019m7" 8 "2019m8" 9 "2019m9" 10 "2019m10" 11 "2019m11" 12 "2019m12" 13 "2020m1" 14 "2020m2" 15 "2020m3" 16 "2020m4" 17 "2020m5" 18 "2020m6" 19 "2020m7" 20 "2020m8" 21 "2020m9" 22 "2020m10" 23 "2020m11" 24 "2020m12" 25 "2021m1" 26 "2021m2" 27 "2021m3" 28 "2021m4" 29 "2021m5" 30 "2021m6" 31 "2021m7" 32 "2021m8" 33 "2021m9" 34 "2021m10" 35 "2021m11" 36 "2021m12" 37 "2022m1" 38 "2022m2" 39 "2022m3" 40 "2022m4" 41 "2022m5" 42 "2022m6" 43 "2022m7" 44 "2022m8" 45 "2022m9" 46 "2022m10" 47 "2022m11",labsize(tiny) angle(45))  ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("calls:`v', measure:`var'", size(small))
	graph export "`v'_`var'_0623_time.png", replace
}
}


local dv ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered
local iv colc_tenure colc_socio

	foreach var of local iv {
foreach v of local dv {

			qui reghdfe `v' c.`var'#i.modate, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_time_detailed.xls, append excel drop(_cons) dec(3) ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.modate, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "2019m1" 2 "2019m2" 3 "2019m3" 4 "2019m4" 5 "2019m5" 6 "2019m6" 7 "2019m7" 8 "2019m8" 9 "2019m9" 10 "2019m10" 11 "2019m11" 12 "2019m12" 13 "2020m1" 14 "2020m2" 15 "2020m3" 16 "2020m4" 17 "2020m5" 18 "2020m6" 19 "2020m7" 20 "2020m8" 21 "2020m9" 22 "2020m10" 23 "2020m11" 24 "2020m12" 25 "2021m1" 26 "2021m2" 27 "2021m3" 28 "2021m4" 29 "2021m5" 30 "2021m6" 31 "2021m7" 32 "2021m8" 33 "2021m9" 34 "2021m10" 35 "2021m11" 36 "2021m12" 37 "2022m1" 38 "2022m2" 39 "2022m3" 40 "2022m4" 41 "2022m5" 42 "2022m6" 43 "2022m7" 44 "2022m8" 45 "2022m9" 46 "2022m10" 47 "2022m11",labsize(tiny) angle(45))  ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("calls:`v', measure:`var'", size(small))
	graph export "`v'_`var'_0623_time_detailed.png", replace
	}
}




egen violent=rowtotal(ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery BombThreat AbductionKidnap SexualOffencesRape)

	qui reghdfe violent colc_tenure, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_violent.xls, append excel keep(colc_tenure) dec(3) ctitle(violent)
	qui reghdfe violent c.colc_tenure#i.modate, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_violent.xls, append excel keep(colc_tenure) dec(3) ctitle(violent)
			
	qui reghdfe violent c.colc_tenure#i.modate, absorb(oas year month) cluster(oas)
				est store detail
			coefplot (detail, drop(_cons) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "2019m1" 2 "2019m2" 3 "2019m3" 4 "2019m4" 5 "2019m5" 6 "2019m6" 7 "2019m7" 8 "2019m8" 9 "2019m9" 10 "2019m10" 11 "2019m11" 12 "2019m12" 13 "2020m1" 14 "2020m2" 15 "2020m3" 16 "2020m4" 17 "2020m5" 18 "2020m6" 19 "2020m7" 20 "2020m8" 21 "2020m9" 22 "2020m10" 23 "2020m11" 24 "2020m12" 25 "2021m1" 26 "2021m2" 27 "2021m3" 28 "2021m4" 29 "2021m5" 30 "2021m6" 31 "2021m7" 32 "2021m8" 33 "2021m9" 34 "2021m10" 35 "2021m11" 36 "2021m12" 37 "2022m1" 38 "2022m2" 39 "2022m3" 40 "2022m4" 41 "2022m5" 42 "2022m6" 43 "2022m7" 44 "2022m8" 45 "2022m9" 46 "2022m10" 47 "2022m11",labsize(tiny) angle(45))  ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("calls:violent, measure:colc_tenure", size(small))
	graph export "violent_colc_tenure_0623_time_detailed.png", replace

			


** Space regressions - MOPAC

/* import location identifier data						
import excel "2011 OAC Clusters and Names Excel v2.xlsx", sheet("2011 OAC Clusters") firstrow clear 						
rename OutputAreaCode outputareas

* merge data
merge 1:m outputareas using "mopac_merged_april23.dta"
keep if _merge==3
drop _merge

* save as separate data file
save "mopac_merged_may23.dta", replace		
clear
*/

use "mopac_merged_may23.dta", clear

local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
local iv colc_tenure colc_socio

foreach var of local iv {
foreach v of local dv {

			qui reghdfe `v' c.`var'#i.supergc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space.xls, append excel drop(_cons) dec(3) ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.gc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space.xls, append excel drop(_cons) dec(3) ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.subgc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space.xls, append excel drop(_cons) dec(3) ctitle(`v')
}
}		

local dv ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered
local iv colc_tenure colc_socio

foreach var of local iv {
foreach v of local dv {

			qui reghdfe `v' c.`var'#i.supergc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space_detailed.xls, append excel drop(_cons) dec(3) ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.gc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space_detailed.xls, append excel drop(_cons) dec(3) ctitle(`v')
			
			qui reghdfe `v' c.`var'#i.subgc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_space_detailed.xls, append excel drop(_cons) dec(3) ctitle(`v')
}
}				



			
			
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
local iv colc_tenure colc_socio	
	foreach var of local iv {
foreach v of local dv {
			
			qui reghdfe `v' c.`var'#i.supergc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.supergc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash))  xlabel(1 "Cosmopolitans" 2 "Ethnicity Central" 3 "Multicultural Metropolitans" 4 "Urbanites" 5 "Suburbanites" 6 "Constrained City Dwellers" 7 "Hard-pressed Living", labsize(tiny) angle(45))	ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_0623_space1.png", replace
	
			qui reghdfe `v' c.`var'#i.gc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Students around campus" 2 "Inner city students" 3 "Comfortable cosmopolitan" 4 "Aspiring and affluent" 5 "Ethnic family life" 6 "Endeavouring Ethnic Mix" 7 "Ethnic dynamics" 8 "Aspirational techies" 9 "Rented family living" 10 "Challenged Asian terraces" 11 "Asian traits" 12 "Urban professionals and families" 13 "Ageing urban living" 14 "Suburban achievers" 15 "Semi-detached suburbia" 16 "Challenged diversity" 17 "Constrained flat dwellers" 18 "White communities" 19 "Ageing city dwellers" 20 "Industrious communities" 21 "Challenged terraced workers" 22 "Hard pressed ageing workers" 23 "Migration and churn", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_0623_space2.png", replace
		
			qui reghdfe `v' c.`var'#i.subgc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure 4.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Student communal living" 2 "Student digs" 3 "Students and Professionals" 4 "Students and Commuters" 5 "Multicultural student neighbourhoods" 6 "Migrant families" 7 "Migrant commuters" 8 "Professional service cosmopolitans" 9 "Urban cultural mix" 10 "Highly-qualified quaternary workers" 11 "EU white-collar workers" 12 "Established renting families" 13 "Young families and students" 14 "Striving service workers" 15 "Bangladeshi mixed employment" 16 "Multi-ethnic professional service workers" 17 "Constrained neighbourhoods" 18 "Constrained commuters" 19 "New EU tech workers" 20 "Established tech workers" 21 "Old EU tech workers" 22 "Social renting young families" 23 "Private renting new arrivals" 24 "Commuters with young families" 25 "Asian terraces and flats" 26 "Pakistani communities" 27 "Achieving minorities" 28 "Multicultural new arrivals" 29 "Inner city ethnic mix" 30 "White professionals" 31 "Multi-ethnic professionals with families" 32 "Families in terraces and flats" 33 "Delayed retirement" 34 "Communal retirement" 35 "Self-sufficient retirement" 36 "Indian tech achievers" 37 "Comfortable suburbia" 38 "Detached retirement living" 39 "Ageing in suburbia" 40 "Multi-ethnic suburbia" 41 "White suburban communities" 42 "Semi-detached ageing" 43 "Older workers and retirement" 44 "Transitional Eastern European neighbourhoods" 45 "Hampered aspiration" 46 "Multi-ethnic hardship" 47 "Eastern European communities" 48 "Deprived neighbourhoods" 49 "Endeavouring flat dwellers" 50 "Challenged transitionaries" 51 "Constrained young families" 52 "Outer city hardship" 53 "Ageing communities and families" 54 "Retired independent city dwellers" 55 "Retired communal city dwellers" 56 "Retired city hardship" 57 "Industrious transitions" 58 "Industrious hardship" 59 "Deprived blue-collar terraces" 60 "Hard pressed rented terraces" 61 "Ageing industrious workers" 62 "Ageing rural industry workers" 63 "Renting hard-pressed workers" 64 "Young hard-pressed families" 65 "Hard-pressed ethnic mix" 66 "Hard-Pressed European Settlers", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_0623_space3.png", replace
	
	
}
}

local dv ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered
local iv colc_tenure colc_socio	
	foreach var of local iv {
foreach v of local dv {
			
			qui reghdfe `v' c.`var'#i.supergc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.supergc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash))  xlabel(1 "Cosmopolitans" 2 "Ethnicity Central" 3 "Multicultural Metropolitans" 4 "Urbanites" 5 "Suburbanites" 6 "Constrained City Dwellers" 7 "Hard-pressed Living", labsize(tiny) angle(45))	ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_0623_space1_detailed.png", replace
	
			qui reghdfe `v' c.`var'#i.gc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Students around campus" 2 "Inner city students" 3 "Comfortable cosmopolitan" 4 "Aspiring and affluent" 5 "Ethnic family life" 6 "Endeavouring Ethnic Mix" 7 "Ethnic dynamics" 8 "Aspirational techies" 9 "Rented family living" 10 "Challenged Asian terraces" 11 "Asian traits" 12 "Urban professionals and families" 13 "Ageing urban living" 14 "Suburban achievers" 15 "Semi-detached suburbia" 16 "Challenged diversity" 17 "Constrained flat dwellers" 18 "White communities" 19 "Ageing city dwellers" 20 "Industrious communities" 21 "Challenged terraced workers" 22 "Hard pressed ageing workers" 23 "Migration and churn", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_may23_space2_detailed.png", replace
		
			qui reghdfe `v' c.`var'#i.subgc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure 4.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Student communal living" 2 "Student digs" 3 "Students and Professionals" 4 "Students and Commuters" 5 "Multicultural student neighbourhoods" 6 "Migrant families" 7 "Migrant commuters" 8 "Professional service cosmopolitans" 9 "Urban cultural mix" 10 "Highly-qualified quaternary workers" 11 "EU white-collar workers" 12 "Established renting families" 13 "Young families and students" 14 "Striving service workers" 15 "Bangladeshi mixed employment" 16 "Multi-ethnic professional service workers" 17 "Constrained neighbourhoods" 18 "Constrained commuters" 19 "New EU tech workers" 20 "Established tech workers" 21 "Old EU tech workers" 22 "Social renting young families" 23 "Private renting new arrivals" 24 "Commuters with young families" 25 "Asian terraces and flats" 26 "Pakistani communities" 27 "Achieving minorities" 28 "Multicultural new arrivals" 29 "Inner city ethnic mix" 30 "White professionals" 31 "Multi-ethnic professionals with families" 32 "Families in terraces and flats" 33 "Delayed retirement" 34 "Communal retirement" 35 "Self-sufficient retirement" 36 "Indian tech achievers" 37 "Comfortable suburbia" 38 "Detached retirement living" 39 "Ageing in suburbia" 40 "Multi-ethnic suburbia" 41 "White suburban communities" 42 "Semi-detached ageing" 43 "Older workers and retirement" 44 "Transitional Eastern European neighbourhoods" 45 "Hampered aspiration" 46 "Multi-ethnic hardship" 47 "Eastern European communities" 48 "Deprived neighbourhoods" 49 "Endeavouring flat dwellers" 50 "Challenged transitionaries" 51 "Constrained young families" 52 "Outer city hardship" 53 "Ageing communities and families" 54 "Retired independent city dwellers" 55 "Retired communal city dwellers" 56 "Retired city hardship" 57 "Industrious transitions" 58 "Industrious hardship" 59 "Deprived blue-collar terraces" 60 "Hard pressed rented terraces" 61 "Ageing industrious workers" 62 "Ageing rural industry workers" 63 "Renting hard-pressed workers" 64 "Young hard-pressed families" 65 "Hard-pressed ethnic mix" 66 "Hard-Pressed European Settlers", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "`v'_`var'_may23_space3_detailed.png", replace
	
	
	
}
}

egen violent=rowtotal(ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery BombThreat AbductionKidnap SexualOffencesRape)


			qui reghdfe violent c.colc_tenure#i.supergc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_violent.xls, append excel drop(_cons) dec(3) ctitle(violent)
			
			qui reghdfe violent c.colc_tenure#i.gc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_violent.xls, append excel drop(_cons) dec(3) ctitle(violent)
			
			qui reghdfe violent c.colc_tenure#i.subgc, absorb(oas year month) cluster(oas)
			outreg2 using regs_mopac_0623_violent.xls, append excel drop(_cons) dec(3) ctitle(violent)
		

			
			qui reghdfe violent c.colc_tenure#i.supergc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.supergc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash))  xlabel(1 "Cosmopolitans" 2 "Ethnicity Central" 3 "Multicultural Metropolitans" 4 "Urbanites" 5 "Suburbanites" 6 "Constrained City Dwellers" 7 "Hard-pressed Living", labsize(tiny) angle(45))	ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "violent_colc_tenure_0623_space1_detailed.png", replace
	
			qui reghdfe violent c.colc_tenure#i.gc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Students around campus" 2 "Inner city students" 3 "Comfortable cosmopolitan" 4 "Aspiring and affluent" 5 "Ethnic family life" 6 "Endeavouring Ethnic Mix" 7 "Ethnic dynamics" 8 "Aspirational techies" 9 "Rented family living" 10 "Challenged Asian terraces" 11 "Asian traits" 12 "Urban professionals and families" 13 "Ageing urban living" 14 "Suburban achievers" 15 "Semi-detached suburbia" 16 "Challenged diversity" 17 "Constrained flat dwellers" 18 "White communities" 19 "Ageing city dwellers" 20 "Industrious communities" 21 "Challenged terraced workers" 22 "Hard pressed ageing workers" 23 "Migration and churn", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "violent_colc_tenure_may23_space2_detailed.png", replace
		
			qui reghdfe violent c.colc_tenure#i.subgc, absorb(oas year month) cluster(oas)
			est store detail
			coefplot (detail, drop(_cons 1b.gc#c.colc_tenure 2.gc#c.colc_tenure 3.gc#c.colc_tenure 4.gc#c.colc_tenure) ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "Student communal living" 2 "Student digs" 3 "Students and Professionals" 4 "Students and Commuters" 5 "Multicultural student neighbourhoods" 6 "Migrant families" 7 "Migrant commuters" 8 "Professional service cosmopolitans" 9 "Urban cultural mix" 10 "Highly-qualified quaternary workers" 11 "EU white-collar workers" 12 "Established renting families" 13 "Young families and students" 14 "Striving service workers" 15 "Bangladeshi mixed employment" 16 "Multi-ethnic professional service workers" 17 "Constrained neighbourhoods" 18 "Constrained commuters" 19 "New EU tech workers" 20 "Established tech workers" 21 "Old EU tech workers" 22 "Social renting young families" 23 "Private renting new arrivals" 24 "Commuters with young families" 25 "Asian terraces and flats" 26 "Pakistani communities" 27 "Achieving minorities" 28 "Multicultural new arrivals" 29 "Inner city ethnic mix" 30 "White professionals" 31 "Multi-ethnic professionals with families" 32 "Families in terraces and flats" 33 "Delayed retirement" 34 "Communal retirement" 35 "Self-sufficient retirement" 36 "Indian tech achievers" 37 "Comfortable suburbia" 38 "Detached retirement living" 39 "Ageing in suburbia" 40 "Multi-ethnic suburbia" 41 "White suburban communities" 42 "Semi-detached ageing" 43 "Older workers and retirement" 44 "Transitional Eastern European neighbourhoods" 45 "Hampered aspiration" 46 "Multi-ethnic hardship" 47 "Eastern European communities" 48 "Deprived neighbourhoods" 49 "Endeavouring flat dwellers" 50 "Challenged transitionaries" 51 "Constrained young families" 52 "Outer city hardship" 53 "Ageing communities and families" 54 "Retired independent city dwellers" 55 "Retired communal city dwellers" 56 "Retired city hardship" 57 "Industrious transitions" 58 "Industrious hardship" 59 "Deprived blue-collar terraces" 60 "Hard pressed rented terraces" 61 "Ageing industrious workers" 62 "Ageing rural industry workers" 63 "Renting hard-pressed workers" 64 "Young hard-pressed families" 65 "Hard-pressed ethnic mix" 66 "Hard-Pressed European Settlers", labsize(tiny) angle(45)) ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:`var'", size(small))
	graph export "violent_colc_tenure_may23_space3_detailed.png", replace
	
	


/*
*******************************************************************


								* regression for temporal variation
								
use "mopac_merged_april23.dta", replace	

* interaction term
forvalues j=708(1)755 {
                gen  colc_tenure`j' = (modate==(`j'))*colc_tenure
                gen  colc_socio`j' = (modate==(`j'))*colc_socio
}

* regression
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
foreach v of local dv {
		reghdfe `v' colc_tenure* colc_socio*, absorb(oas) cluster(oas)
		estimates store est_`v'
}

* coefplot for tenure
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc 
foreach v of local dv {
coefplot (est_`v', ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical keep(colc_tenure*) drop(_cons colc_tenure) yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "2019m1" 2 "2019m2" 3 "2019m3" 4 "2019m4" 5 "2019m5" 6 "2019m6" 7 "2019m7" 8 "2019m8" 9 "2019m9" 10 "2019m10" 11 "2019m11" 12 "2019m12" 13 "2020m1" 14 "2020m2" 15 "2020m3" 16 "2020m4" 17 "2020m5" 18 "2020m6" 19 "2020m7" 20 "2020m8" 21 "2020m9" 22 "2020m10" 23 "2020m11" 24 "2020m12" 25 "2021m1" 26 "2021m2" 27 "2021m3" 28 "2021m4" 29 "2021m5" 30 "2021m6" 31 "2021m7" 32 "2021m8" 33 "2021m9" 34 "2021m10" 35 "2021m11" 36 "2021m12" 37 "2022m1" 38 "2022m2" 39 "2022m3" 40 "2022m4" 41 "2022m5" 42 "2022m6" 43 "2022m7" 44 "2022m8" 45 "2022m9" 46 "2022m10" 47 "2022m11",labsize(tiny) angle(45))  ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:tenure", size(small))
	graph save "`v'_tenure_may23.gph"
	graph export "`v'_tenure_may23.png"
}

* coefplot for socio
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
foreach v of local dv {
coefplot (est_`v', ciopts(recast(rcap) lcolor(black)) mcolor(black) msize(small)), vertical keep(colc_socio*) drop(_cons colc_socio) yline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(1 "2019m1" 2 "2019m2" 3 "2019m3" 4 "2019m4" 5 "2019m5" 6 "2019m6" 7 "2019m7" 8 "2019m8" 9 "2019m9" 10 "2019m10" 11 "2019m11" 12 "2019m12" 13 "2020m1" 14 "2020m2" 15 "2020m3" 16 "2020m4" 17 "2020m5" 18 "2020m6" 19 "2020m7" 20 "2020m8" 21 "2020m9" 22 "2020m10" 23 "2020m11" 24 "2020m12" 25 "2021m1" 26 "2021m2" 27 "2021m3" 28 "2021m4" 29 "2021m5" 30 "2021m6" 31 "2021m7" 32 "2021m8" 33 "2021m9" 34 "2021m10" 35 "2021m11" 36 "2021m12" 37 "2022m1" 38 "2022m2" 39 "2022m3" 40 "2022m4" 41 "2022m5" 42 "2022m6" 43 "2022m7" 44 "2022m8" 45 "2022m9" 46 "2022m10" 47 "2022m11",labsize(tiny) angle(45))  ylabel(, labsize(vsmall) angle(horizontal)) graphregion(fcolor(white)) title("Crime:`v', Measure:socio", size(small))
	graph save "`v'_socio_may23.gph"
	graph export "`v'_socio_may23.png"
}
clear




						* regression for spatial variation
						
* import location identifier data						
import excel "2011 OAC Clusters and Names Excel v2.xlsx", sheet("2011 OAC Clusters") firstrow clear 						
rename OutputAreaCode outputareas

* merge data
merge 1:m outputareas using "mopac_merged_april23.dta"
keep if _merge==3
drop _merge

* save as separate data file
save "mopac_merged_may23.dta", replace		
clear

* use the merged data
use "mopac_merged_may23.dta", replace	
sort outputareas modate					
							
* interaction term for supergroup code
forvalues j=1(1)8 {
                gen  colc_tenure`j' = (SupergroupCode==(`j'))*colc_tenure
                gen  colc_socio`j' = (SupergroupCode==(`j'))*colc_socio
}							
							
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
foreach v of local dv {
		reghdfe `v' colc_tenure* colc_socio*, absorb(year month) cluster(oas)
		outreg2 using regs_mopac_may23_supergroup.xls, append excel keep(colc_tenure* colc_socio*) dec(3)
}	

* interaction term for group code
encode GroupCode, gen(groupcode)
sum groupcode

forvalues j=1(1)26 {
                gen  colc_tenure_group`j' = (groupcode==(`j'))*colc_tenure
                gen  colc_socio_group`j' = (groupcode==(`j'))*colc_socio
}							
							
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
foreach v of local dv {
		reghdfe `v' colc_tenure_group* colc_socio_group*, absorb(year month) cluster(oas)
		outreg2 using regs_mopac_may23_group.xls, append excel keep(colc_tenure_group* colc_socio_group*) dec(3)
}	

* interaction term for 	subgroup code
encode SubgroupCode, gen(subgroupcode)
sum subgroupcode

forvalues j=1(1)67 {
                gen  colc_tenure_subgroup`j' = (subgroupcode==(`j'))*colc_tenure
                gen  colc_socio_subgroup`j' = (subgroupcode==(`j'))*colc_socio
}							
							
local dv all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
foreach v of local dv {
		reghdfe `v' colc_tenure_subgroup* colc_socio_subgroup*, absorb(year month) cluster(oas)
		outreg2 using regs_mopac_may23_subgroup.xls, append excel keep(colc_tenure_subgroup* colc_socio_subgroup*) dec(3)
}


* for transferring files to gis

	* supergroup
import excel "regs_mopac_may23_supergroup.xls", sheet("Sheet2") firstrow
* merge data
merge m:m supergroupcode using "2011OAsClusterGroups_may23.dta"	
br if _merge==2
keep if _merge==3
drop _merge
* order data
order supergroupcode supergroupname outputareacode DV all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
sort supergroupcode outputareacode DV	
* destring
destring all-misc, replace	
drop subgroupcode-groupname									
* export.. I split the data further in excel for socio and tenure
export delimited using "gis_mopac_supergroup_may23.csv", replace
clear

	* group
import excel "regs_mopac_may23_group.xls", sheet("Sheet2") firstrow
* merge data
merge m:m groupcode using "2011OAsClusterGroups_may23.dta"	
br if _merge==2
keep if _merge==3
drop _merge
* order data
order groupcode groupname outputareacode DV all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
sort groupcode outputareacode DV	
* drop
drop localauthoritycode-subgroupcode								
* export.. I split the data further in excel for socio and tenure
export delimited using "gis_mopac_group_may23.csv", replace
clear


	* group
import excel "regs_mopac_may23_subgroup.xls", sheet("Sheet2") firstrow
* merge data
merge m:m subgroupcode using "2011OAsClusterGroups_may23.dta"	
br if _merge==2
keep if _merge==3
drop _merge
* order data
order subgroupcode outputareacode DV all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc
sort subgroupcode outputareacode DV	
* drop
drop localauthoritycode-groupname								
* export.. I split the data further in excel for socio and tenure
export delimited using "gis_mopac_subgroup_may23.csv", replace
clear






/*

* Regression 1								
* panel regression with area fixed effects and standard errors clustered at OA and month level
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe `v' `var', absorb(outputareas) vce(cluster OA)
			outreg2 using reg1.xls, append excel keep(`var') dec(3) addtext(Controls, No, Area FE, Yes)
	}
}

* Regression 2
* panel regression with area fixed effects and robut standard errors
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe `v' `var', absorb(outputareas) vce(robust)
			outreg2 using reg2.xls, append excel keep(`var') dec(3) addtext(Controls, No, Area FE, Yes)
	}
}


								* Regression for variations from 2019 to 2022 
clear
use "merged_colc_crime.dta", replace	


* relevant variables
keep outputareas modate monthly colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson

* year
gen year= year(dofm(monthly))


* drop year 2021
drop if year==2021 | year==2020

* month
gen month= month(dofm(monthly))

* order 
order outputareas year month modate monthly
sort outputareas month year

* for variation from jan2019 to jan2022 and so on..
foreach x in colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson{
	sort outputareas month year
	bysort outputareas month: gen delta_`x'=(`x'-`x'[_n-1])/`x'[_n-1] * 100
}

* keep the delta values for year 2022
keep if year==2022
drop year colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson

* encode
encode outputareas, gen(OA)

* Regression 3
* ols regression with standard errors clustered at OA
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe delta_`v' delta_`var',absorb(outputareas) vce(cluster OA)
			outreg2 using reg3.xls, append excel keep(delta_`var') dec(3) 
	}
}

* Regression 4
* ols regression with robut standard errors
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe delta_`v' delta_`var',absorb(outputareas) vce(robust)
			outreg2 using reg4.xls, append excel keep(delta_`var') dec(3) 
	}
}



								* Regression for year-to-year variation
					
clear					
use "merged_colc_crime.dta", replace	


* relevant variables
keep outputareas modate monthly colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson

* year
gen year= year(dofm(monthly))

* month
gen month= month(dofm(monthly))

* order 
order outputareas year month modate monthly
sort outputareas month year


* for variation from jan2019 to jan2022 and so on..
foreach x in colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson{
	sort outputareas month year
	bysort outputareas month: gen delta_`x'=(`x'-`x'[_n-1])/`x'[_n-1] * 100
}

* keep the delta values for year 2020,2021 and 2022
drop if year==2019
drop year colc_it_tenure colc_it_socio all crime asb theft ViolenceAgainstThePerson

* to confirm for 36 obsv per OA
bysort outputareas: gen id=_N, after(outputareas)
br if id!=36
drop id

* encode
encode outputareas, gen(OA)

* Regression 5
* ols regression with standard errors clustered at OA
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe delta_`v' delta_`var',absorb(outputareas) vce(cluster OA)
			outreg2 using reg5.xls, append excel keep(delta_`var') dec(3) 
	}
}

* Regression 6
* ols regression with robut standard errors
local dv all crime asb theft ViolenceAgainstThePerson
local iv colc_it_tenure colc_it_socio
foreach v of local dv{
	foreach var of local iv{
			reghdfe delta_`v' delta_`var',absorb(outputareas) vce(robust)
			outreg2 using reg6.xls, append excel keep(delta_`var') dec(3) 
	}
}


*/
*/
