
clear all
* Current Directory
cd "J:\Met\COL"
**********************************************************************

* load price data
* import CPI indices by income quintiles and housing tenure
import excel "J:\Met\COL\3. Forecast\Excel inputs\forecast_income_tenure_july23.xlsx", clear sheet("Sheet3") firstrow
save "28thJunforecast_income_tenure.dta", replace

describe 

* Convert date to numeric

gen Period="20" + substr(period,-2,2) + substr(period,1,3)
generate monthly = monthly(Period, "YM")
format %tm monthly
drop period 

generate modate= monthly

*organise the data
order monthly Period year month
sort monthly

* set as time series

tsset monthly

//saving the data file
save "28thJunforecast_income_tenure.dta", replace

****************************************
**Load OA composition data on housing tenure and income

use "J:\Met\COL\1. Inputs Raw\OA_Combined_april23_2021.dta", clear

*expand the dataset by 240 months and give it a panel structure
expand 240, gen(dupindicator)
sort outputareas 

*Creating a variable similar to monthly date
bysort outputareas: gen modate=_n, after(outputareas)
bysort outputareas: replace modate=(modate + 707)
drop dupindicator

**merge OA structure with Price dataset
merge m:1 modate using "\\rlabf\PDATA$\Met\COL\28thJunforecast_income_tenure.dta", nogen

*sort dataset
sort outputareas modate

*set panel
encode outputareas, gen (oas)
xtset oas modate

save "28thJun_OAcombined_colc.dta", replace


************************************************************************
*COLC Measure for each output area for a time by the three tenure groups

use "28thJun_OAcombined_colc.dta", clear

//calculating socio and tenure shares

foreach x in freqscqui1 freqscqui2 freqscqui3 freqscqui4 freqscqui5{
	gen share_`x'=`x'/total_hh_socio
}

foreach x in observationowneroccupiers observationrenters observationsubsidisedrenters{
	gen s_`x'=`x'/total_hh_tenure
}

foreach x in 1 2 3 4 5 {
	rename share_freqscqui`x' sharescqui`x'
}

rename s_observationowneroccupiers shareowneroccupiers
rename s_observationrenters sharerenters
rename s_observationsubsidisedrenters sharesubsidisedrenters

***colc for subsidisedrenters
bysort outputareas modate: gen colc_subrenter= subsidisedrenters * sharesubsidisedrenters, after(subsidisedrenters)

***ownersoccupied
bysort outputareas modate: gen colc_owner= owneroccupiers * shareowneroccupiers, after(owneroccupiers)

***renters
bysort outputareas modate: gen colc_renter= renters * sharerenters, after(renters)

* aggregated COLC Measure for tenure in each output area at a time
sort outputareas modate
egen colc_tenure=rowtotal(colc_owner colc_renter colc_subrenter)

order outputareas Period modate monthly year month colc_tenure 


*************************************************************************
// COLC Measure for each output area for a time by the income quintiles
*quintile 1
bysort outputareas modate: gen colc_quintile1= quintile1 * sharescqui1, after(quintile1)
*quintile 2
bysort outputareas modate: gen colc_quintile2= quintile2 * sharescqui2, after(quintile2)
*quintile 3
bysort outputareas modate: gen colc_quintile3= quintile3 * sharescqui3, after(quintile3)
*quintile 4
bysort outputareas modate: gen colc_quintile4= quintile4 * sharescqui4, after(quintile4)
*quintile 5
bysort outputareas modate: gen colc_quintile5= quintile5 * sharescqui5, after(quintile5)


*aggregated COLC Measure for socioeconomic groups in each output area at a time
sort outputareas modate
egen colc_socio=rowtotal(colc_quintile1 colc_quintile2 colc_quintile3 colc_quintile4 colc_quintile5)

order outputareas Period modate monthly year month colc_tenure colc_socio

keep outputareas oas Period modate monthly year month colc_tenure colc_socio democraticcpih 

order outputareas oas Period modate monthly year month colc_tenure colc_socio democraticcpih 

* save dataset
save "28thJun_OAcombined_colc.dta", replace


********************************************************************
*Merging forecasted COLC and Crime dataset


*load colc data
use "28thJun_OAcombined_colc.dta", clear

//Keep data from 2019-2024
keep if (modate>=708 & modate<=779)

*sort data
sort outputareas monthly

*Merging the data on outputarea and time... the crime data was already rectangularized 
merge 1:1 outputareas monthly using "\\rlabf\PDATA$\Met\COL\1. Inputs Raw\cadcalls-2019-2022-oas.dta", keep(master match) force

*sort data
sort outputareas monthly
order outputareas oa

*set panel
xtset oa monthly

**Classifying crimes

egen all=rowtotal(code*)

egen crime=rowtotal(code_15 code_12 code_3 code_4 code_10 code_11 code_9 code_14 code_17 code_18 code_5 code_2 code_13 code_7 code_6 code_8 code_16 code_1)

egen transport=rowtotal(code_102 code_104 code_103 code_100 code_105 code_101)

egen antisocial=rowtotal(/*code_206*/ code_212 code_216 /*code_213 code_205 code_211 code_217*/ code_215 code_214 /*code_210 code_204 code_202 code_209 code_207 code_200 code_201*/)

//data missing in the cadcall records for the codes in comments

egen publicsafety=rowtotal(code_300 code_310 code_317 /*code_318*/ code_316 code_319 /*code_656*/ code_307 code_305 code_308 code_309 code_304 code_320 code_325 code_321 code_303 code_315 code_301 code_311 code_302 code_322 code_313 code_314 code_306 code_323 code_312 code_324)

egen admin=rowtotal(code_500 code_507 code_506 code_505 code_501 code_502 code_503 code_504 code_509)

gen covid=code_327

egen mpsqualifiers=rowtotal(code_401 code_400 code_404 code_701)

egen systemuse=rowtotal(code_402 code_665)

egen misc=rowtotal(code_326 code_505 code_508)


**checking if all crimes are classified
egen check=rowtotal(crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc)
gen check2=all-check
ta check2
drop check check2 


** rename crime codes
rename	code_1	 	ViolenceAgainstThePerson
rename	code_2	 	SexualOffences
rename	code_3	 	BurglaryDwelling
rename	code_4	 	BurglaryOtherThanADwelling
rename	code_5	 	Robbery
rename	code_6	 	TheftOfMotorVeh
rename	code_7	 	TheftFromMotorVeh
rename	code_8	 	TheftOther
rename	code_9	 	FraudAndForgery
rename	code_10	 	CriminalDamage
rename	code_11	 	DrugsOffence
rename	code_12	 	BombThreat
rename	code_13	 	TheftShoplifting
rename	code_14	 	HarassmentActOffences
rename	code_15	 	AbductionKidnap
rename	code_16	 	UnlistedCrime
rename	code_17	 	MaliciousCommunications
rename	code_18	 	SexualOffencesRape
rename	code_100	RTCIncidentDamageOnly
rename	code_101	RTCIncidentInjury
rename	code_102	HighwayDisruption
rename	code_103	RoadRelatedOffence
rename	code_104	RailAirMarineIncident
rename	code_105	RTCIncidentDeath
rename	code_212	BeggingVagrancy
rename	code_214	ASBPersonal
rename	code_215	ASBNuisance
rename	code_216	ASBEnvironmental
rename	code_300	AbandonedCall
rename	code_301	Licensing
rename	code_302	NaturalDisasterIncidentWarn
rename	code_303	IndustrialIncidentAccident
rename	code_304	DomesticIncident
rename	code_305	CivilDisputes
rename	code_306	SuspiciousPackageObject
rename	code_307	AnimalsPetsDomesticated
rename	code_308	CollapseIllnessInjTrapped
rename	code_309	ConcernForSafety
rename	code_310	AbscondersAWOL
rename	code_311	MissingPerson
rename	code_312	WantedPolCrtOrderBail
rename	code_313	SuddenDeath
rename	code_314	SuspiciousCircumstances
rename	code_315	InsecurePremisesvehs
rename	code_316	AlarmPoliceInstalled
rename	code_317	AlarmCentralStation
rename	code_319	AlarmPremisesAudibleOnly
rename	code_320	Firearms
rename	code_321	Immigration
rename	code_322	ProtestDemonstration
rename	code_323	Truancy
rename	code_324	Wildlife
rename	code_325	HoaxCallToEmergencyServices
rename	code_326	Absent
rename	code_327	Pandemic
rename	code_400	SuspectsChasedOnFoot
rename	code_401	VehPursuit
rename	code_402	CBuFduplicatedrecord
rename	code_404	UrgentAssistance
rename	code_500	ComplaintsAgainstPolice
rename	code_501	LostFoundPropertyPerson
rename	code_502	Messages
rename	code_503	PoliceGeneratedResourceActivity
rename	code_504	PrePlannedEvents
rename	code_505	Error
rename	code_506	Duplicate
rename	code_507	ContactRecord
rename	code_508	SwitchboardCall
rename	code_509	TestTraining
rename	code_665	AbandonedCallNotToOperator
rename	code_701	AssistanceRequestedRendered



foreach x in ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc {
	
	replace `x'=. if _merge==1
	
}
rename _merge mergeone


sort outputarea oas monthly


**order variables
order outputareas oas modate monthly year month colc_tenure colc_socio all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc , first 


* Join area classification
 rename outputareas OutputAreaCode
 merge m:1 OutputAreaCode using "J:\Met\COL\1. Inputs Raw\2011 OAC Clusters and Names Excel v2.dta", keep(master match) nogen
 drop *Name
 gen spgc=SupergroupCode
 encode GroupCode, gen(gc) 
 encode SubgroupCode, gen(sbgc)
 drop SupergroupCode GroupCode SubgroupCode
 
*save merged data
save "28thJunecadcalls-2019-2022-oas.dta", replace






/*
gen strperiod = string(period)

format %tm period
sort period
format %tm period
drop month

gen month = real(substr(period,1,3))

gen Period = string(period,"%6.0g")

decode period, gen(periodcode)
drop peri
tostring period, generate(periodcode) force
*/
















