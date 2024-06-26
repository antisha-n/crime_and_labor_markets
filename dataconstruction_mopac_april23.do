									
**********************************************************************
* Creates datasets for MOPAC-COLC project *
* Shubhangi Agrawal <shubhangiagrawal8@gmail.com>
* Magdalena Dominguez <m.dominguez2@lse.ac.uk>
**********************************************************************

* Current Directory
cd "/Users/shubhangiagrawal/Dropbox/MOPAC_COLC"
cd "C:\Users\DOMING28\Dropbox\2022 Dominguez LSE\MOPAC_COLC"


**********************************************************************
*** Load price data ***

* load data
clear

* import CPI indices by income quintiles and housing tenure
import excel "CPI_Indices.xls", sheet("Sheet1") firstrow       /* from ONS */
save "CPI_Indices_0423.dta", replace

* convert date to numeric
gen Period="20" + substr(period,-2,2) + substr(period,1,3)
generate monthly = monthly(Period, "YM")
format %tm monthly
drop period

gen modate=monthly

* organise the data
order monthly Period
sort monthly

* set as time series
tsset monthly

save "CPI_Indices_0423.dta", replace



**********************************************************************
*** Load OA composition data on housing tenure and income ***

** OA socioeconomic status data

import delimited "socio2011.csv", clear

// socioeconomiccode	socioeconomiccat
// -8(drop)					Does not apply
// 1 (Q5)					L1, L2 and L3: Higher managerial, administrative and professional occupations
// 2 (Q5)					L4, L5 and L6: Lower managerial, administrative and professional occupations
// 3 (Q4)					L7: Intermediate occupations
// 4 (Q3)					L8 and L9: Small employers and own account workers
// 5 (Q2)					L10 and L11: Lower supervisory and technical occupations
// 6 (Q1)					L12: Semi-routine occupations
// 7 (Q1)					L13: Routine occupations
// 8 (Q1)					L14.1 and L14.2: Never worked and long-term unemployed
// 9 (drop)					L15: Full-time students

rename v5 highermanagerialshare
rename v7 lowermanagerialshare
rename v11 smallemployersshare
rename v13 lowersupervisoryshare
rename v19 neverworkedshare

egen freqscqui1=rowtotal(neverworkedandlongtermunemployed routineoccupationsfreq semiroutineoccupationsfreq)
egen sharescqui1=rowtotal(neverworkedshare routineoccupationsshare semiroutineoccupationsshare)
gen freqscqui2=lowersupervisoryandtechnicaloccu
gen sharescqui2=lowersupervisoryshare
gen freqscqui3=smallemployersandownaccountworke
gen sharescqui3=smallemployersshare
gen freqscqui4=intermediateoccupationsfreq 
gen sharescqui4=intermediateoccupationsshare
egen freqscqui5=rowtotal(highermanagerialadministrativean  lowermanagerialadministrativeand )
egen sharescqui5=rowtotal( highermanagerialshare lowermanagerialshare)

rename oa outputareas
encode outputareas, gen(oa)
rename all_freq freqallsocio
keep outputareas oa freqallsocio freqscqui1 sharescqui1 freqscqui2 sharescqui2 freqscqui3 sharescqui3 freqscqui4 sharescqui4 freqscqui5 sharescqui5
duplicates drop outputareas, force

* save data
save "OA_Socio_april23.dta", replace


** OA tenure staus data

import delimited "tenure2011.csv", clear 

egen freqowneroccupiers=rowtotal(ownedfreq shareownerfreq)
egen shareowneroccupiers=rowtotal(ownedshare shareownershare)
egen freqrenters=rowtotal(privaterentedfreq)
egen sharerenters=rowtotal(privaterentershare)
egen freqsubsidisedrenters=rowtotal(rentfreefreq socialrentedfreq)
egen sharesubsidisedrenters=rowtotal(rentfreeshare socialrentedshare)

rename oa outputareas
encode outputareas, gen(oa)
rename allfreq freqalltenure
keep outputareas oa freqalltenure freqowneroccupiers shareowneroccupiers freqrenters sharerenters freqsubsidisedrenters sharesubsidisedrenters
duplicates drop outputareas, force

* save data
save "OA_Tenure_april23.dta", replace

				
** Append Income and Tenure composition

use "OA_Tenure_april23.dta", replace

* merge
merge 1:1 outputareas using "OA_Socio_april23.dta", nogen

* total households
sort outputareas
duplicates r outputareas

* by tenure status
egen total_tenure=rowtotal(freqowneroccupiers freqrenters freqsubsidisedrenters)

* by socioeconomic status- income quintiles
egen total_socio=rowtotal(freqscqui1 freqscqui2 freqscqui3 freqscqui4 freqscqui5)

drop if outputareas==""
destring freqalltenure freqallsocio, replace

* save
save "OA_Combined_april23.dta", replace


*** Results for 2021 census

use "OA_2021_22_Combined.dta" clear
save "OA_Combined_april23_2021.dta", replace

****

**********************************************************************
*** Construction of Cost of Living Crisis indicator ***

use "OA_Combined_april23_2021.dta", clear // for 2021 census data and OAs

* expand the dataset by 213 + the original observation since we have 216 months - gives panel structure
expand 216, gen(dupindicator)
sort outputareas
* to create a variable similar to monthly date
bysort outputareas: gen modate=_n, after(outputareas)
bysort outputareas: replace modate=(modate + 539)
drop dupindicator
* merge OA structure with Price data
merge m:1 modate using "CPI_Indices_april23.dta", nogen
* sort dataset
sort outputareas modate
* set panel
encode outputareas, gen(oas) 
xtset oas modate 

** COLC Measure for each output area for a time by the three tenure groups
* owners
bysort outputareas modate: gen colc_owner= owneroccupiers * (shareowneroccupiers/100), after(owneroccupiers)
* renters
bysort outputareas modate: gen colc_renter= renters * (sharerenters/100), after(renters)
* subsidised renters
bysort outputareas modate: gen colc_subrenter= subsidisedrenters * (sharesubsidisedrenters/100), after(subsidisedrenters)
* aggregated COLC Measure for tenure in each output area at a time
sort outputareas modate
egen colc_tenure=rowtotal(colc_owner colc_renter colc_subrenter)
order outputareas modate monthly Period colc_tenure 

** COLC Measure for each output area for a time by the income quintiles
* quintile 1
bysort outputareas modate: gen colc_qui1= quintile1 * (sharescqui1/100), after(quintile1)
* quintile 2
bysort outputareas modate: gen colc_qui2= quintile2 * (sharescqui2/100), after(quintile2)
* quintile 3
bysort outputareas modate: gen colc_qui3= quintile3 * (sharescqui3/100), after(quintile3)
* quintile 4
bysort outputareas modate: gen colc_qui4= quintile4 * (sharescqui4/100), after(quintile4)
* quintile 5
bysort outputareas modate: gen colc_qui5= quintile5 * (sharescqui5/100), after(quintile5)
* aggregated COLC Measure for socioeconomic groups in each output area at a time
sort outputareas modate
egen colc_socio=rowtotal(colc_qui1 colc_qui2 colc_qui3 colc_qui4 colc_qui5)
order outputareas modate monthly Period colc_tenure colc_socio

keep outputareas oas modate monthly Period colc_tenure colc_socio freqalltenure freqallsocio

* save dataset
save "colc_measure_april23.dta", replace // for 2011 census data and OAs


*** Results for 2021 census

use "colc_measure.dta", clear
rename (OA colc_it_tenure colc_it_socio total_hh_tenure total_hh_socio) (oas colc_tenure colc_socio freqalltenure freqallsocio)
keep outputareas oas modate monthly Period colc_tenure colc_socio freqalltenure freqallsocio
save "colc_measure_april23_2021.dta", replace // for 2021 census data and OAs

****

**********************************************************************
* To structure the crime data 

* load the crime data
use "COLC-2019-2022-oa-gis2021-categories.dta", replace

* for merging on time and output area
gen monthly= ym(year,month)
format %tm monthly

rename oa21cd outputareas
order outputareas monthly

encode outputareas, gen(oas)
sort oas monthly

* rectangularize the data
fillin outputareas monthly

* replace missing values with zero
foreach v of varlist code_1-code_701{
	replace `v'=0 if `v'==.
}

drop _fillin

* sort and merge with inflation data
sort outputareas monthly
save "cadcalls-2019-2022-oas.dta", replace


**********************************************************************
** Merging COLC and Crime data
									
* load data
use "colc_measure_april23_2021.dta", clear

* we keep data from 2019 to 2022.. since colc measure data is from 2005m1
keep if modate>=708

* sort 
sort outputareas monthly

* we merge the data on outputarea and time... the crime data was already rectangularized 
*merge 1:1 outputareas monthly using "COLC-2019-2022-OAs.dta", keep(master match) nogen
merge 1:1 outputareas monthly using "cadcalls-2019-2022-oas.dta", keep(master match)

* merge=2 (no inflation data) --> geographically outside of London region --> drop
* merge=1 (no crime data) --> still needs fixing

* sort data
sort outputareas monthly
order outputareas oa

* set panel
xtset oa monthly

merge m:1 outputareas using "census2021.dta", nogen

** crime categories

egen all=rowtotal(code*)
egen crime=rowtotal(code_15 code_12 code_3 code_4 code_10 code_11 code_9 code_14 code_17 code_18 code_5 code_2 code_13 code_7 code_6 code_8 code_16 code_1)
egen transport=rowtotal(code_102 code_104 code_103 code_100 code_105 code_101)
egen antisocial=rowtotal(/*code_206*/ code_212 code_216 /*code_213 code_205 code_211 code_217*/ code_215 code_214 /*code_210 code_204 code_202 code_209 code_207 code_200 code_201*/)
egen publicsafety=rowtotal(code_300 code_310 code_317 /*code_318*/ code_316 code_319 /*code_656*/ code_307 code_305 code_308 code_309 code_304 code_320 code_325 code_321 code_303 code_315 code_301 code_311 code_302 code_322 code_313 code_314 code_306 code_323 code_312 code_324)
egen admin=rowtotal(code_500 code_507 code_506 code_501 code_502 code_503 code_504 code_509)
gen covid=code_327
egen mpsqualifiers=rowtotal(code_401 code_400 code_404 code_701)
egen systemuse=rowtotal(code_402 code_665)
egen misc=rowtotal(code_326 code_505 code_508)

** checks all are classified

egen check=rowtotal(crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc)
gen check2=all-check
ta check2
drop check check2 year month

** housekeeping
bysort oas: egen oa_area=min(shape_area)
gen year=substr( Period,1,4)
destring year, replace
gen monthraw=substr(Period,5,3)
encode monthraw, gen(month)
drop monthraw shape_area Period

** rename codes

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
rename	code_100	 	RTCIncidentDamageOnly
rename	code_101	 	RTCIncidentInjury
rename	code_102	 	HighwayDisruption
rename	code_103	 	RoadRelatedOffence
rename	code_104	 	RailAirMarineIncident
rename	code_105	 	RTCIncidentDeath
rename	code_212	 	BeggingVagrancy
rename	code_214	 	ASBPersonal
rename	code_215	 	ASBNuisance
rename	code_216	 	ASBEnvironmental
rename	code_300	 	AbandonedCall
rename	code_301	 	Licensing
rename	code_302	 	NaturalDisasterIncidentWarn
rename	code_303	 	IndustrialIncidentAccident
rename	code_304	 	DomesticIncident
rename	code_305	 	CivilDisputes
rename	code_306	 	SuspiciousPackageObject
rename	code_307	 	AnimalsPetsDomesticated
rename	code_308	 	CollapseIllnessInjTrapped
rename	code_309	 	ConcernForSafety
rename	code_310	 	AbscondersAWOL
rename	code_311	 	MissingPerson
rename	code_312	 	WantedPolCrtOrderBail
rename	code_313	 	SuddenDeath
rename	code_314	 	SuspiciousCircumstances
rename	code_315	 	InsecurePremisesvehs
rename	code_316	 	AlarmPoliceInstalled
rename	code_317	 	AlarmCentralStation
rename	code_319	 	AlarmPremisesAudibleOnly
rename	code_320	 	Firearms
rename	code_321	 	Immigration
rename	code_322	 	ProtestDemonstration
rename	code_323	 	Truancy
rename	code_324	 	Wildlife
rename	code_325	 	HoaxCallToEmergencyServices
rename	code_326	 	Absent
rename	code_327	 	Pandemic
rename	code_400	 	SuspectsChasedOnFoot
rename	code_401	 	VehPursuit
rename	code_402	 	CBuFduplicatedrecord
rename	code_404	 	UrgentAssistance
rename	code_500	 	ComplaintsAgainstPolice
rename	code_501	 	LostFoundPropertyPerson
rename	code_502	 	Messages
rename	code_503	 	PoliceGeneratedResourceActivity
rename	code_504	 	PrePlannedEvents
rename	code_505	 	Error
rename	code_506	 	Duplicate
rename	code_507	 	ContactRecord
rename	code_508	 	SwitchboardCall
rename	code_509	 	TestTraining
rename	code_665	 	AbandonedCallNotToOperator
rename	code_701	 	AssistanceRequestedRendered


foreach x in ViolenceAgainstThePerson SexualOffences BurglaryDwelling BurglaryOtherThanADwelling Robbery TheftOfMotorVeh TheftFromMotorVeh TheftOther FraudAndForgery CriminalDamage DrugsOffence BombThreat TheftShoplifting HarassmentActOffences AbductionKidnap UnlistedCrime MaliciousCommunications SexualOffencesRape RTCIncidentDamageOnly RTCIncidentInjury HighwayDisruption RoadRelatedOffence RailAirMarineIncident RTCIncidentDeath BeggingVagrancy ASBPersonal ASBNuisance ASBEnvironmental AbandonedCall Licensing NaturalDisasterIncidentWarn IndustrialIncidentAccident DomesticIncident CivilDisputes SuspiciousPackageObject AnimalsPetsDomesticated CollapseIllnessInjTrapped ConcernForSafety AbscondersAWOL MissingPerson WantedPolCrtOrderBail SuddenDeath SuspiciousCircumstances InsecurePremisesvehs AlarmPoliceInstalled AlarmCentralStation AlarmPremisesAudibleOnly Firearms Immigration ProtestDemonstration Truancy Wildlife HoaxCallToEmergencyServices Absent Pandemic SuspectsChasedOnFoot VehPursuit CBuFduplicatedrecord UrgentAssistance ComplaintsAgainstPolice LostFoundPropertyPerson Messages PoliceGeneratedResourceActivity PrePlannedEvents Error Duplicate ContactRecord SwitchboardCall TestTraining AbandonedCallNotToOperator AssistanceRequestedRendered all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc {
	
	replace `x'=. if _merge==1
	
}

order outputareas oas year month modate monthly colc_tenure colc_socio all crime transport antisocial publicsafety admin covid mpsqualifiers systemuse misc , first 

rename _merge mergeone

* save merged data
save "mopac_merged_april23.dta", replace

************************************************************************************************				

/*
015	Abduction / Kidnap	Crime
012	Bomb Threat	Crime
003	Burglary Dwelling	Crime
004	Burglary Other Than A Dwelling	Crime
010	Criminal Damage	Crime
011	Drugs Offence	Crime
009	Fraud And Forgery	Crime
014	Harassment Act Offences	Crime
017	Malicious Communication	Crime
018	Rape	Crime
005	Robbery	Crime
002	Sexual Offences	Crime
013	Theft - Shoplifting	Crime
007	Theft From Motor Vehicle	Crime
006	Theft Of Motor Vehicle	Crime
008	Thefts - Other	Crime
016	Unlisted Crime	Crime
001	Violence Against The Person	Crime

102	Highway Disruption	Transport
104	Rail / Air / Marine Incident	Transport
103	Road Related Offence	Transport
100	RTC / Incident - Damage Only	Transport
105	RTC / Incident - Death	Transport
101	RTC / Incident - Injury	Transport

206	Animal Problems	Anti Social Behaviour
212	Begging / Vagrancy	Anti Social Behaviour
216	Environmental - Opening Code	Anti Social Behaviour
213	Fireworks	Anti Social Behaviour
205	Littering / Drugs Paraphernalia	Anti Social Behaviour
211	Noise	Anti Social Behaviour
217	Nuisance Calls	Anti Social Behaviour
215	Nuisance - Opening Code	Anti Social Behaviour
214	Personal - Opening Code	Anti Social Behaviour
210	Prostitution Related Activity	Anti Social Behaviour
204	Rowdy / Nuisance Neighbours	Anti Social Behaviour
202	Rowdy Or Inconsiderate Behaviour	Anti Social Behaviour
209	Street Drinking	Anti Social Behaviour
207	Trespass	Anti Social Behaviour
200	Vehicle Abandoned - Not Stolen	Anti Social Behaviour
201	Vehicle Nuisance / Inappropriate Use	Anti Social Behaviour

300	Abandoned Call	Public Safety and Welfare
310	Absconders / AWOL	Public Safety and Welfare
317	Alarm: Central Station	Public Safety and Welfare
318	Alarm: Central Station False	Public Safety and Welfare
316	Alarm: Police Installed	Public Safety and Welfare
319	Alarm: Premises Audible Only	Public Safety and Welfare
656	Alarm: Withdrawn / Banned	Public Safety and Welfare
307	Animals - Pets / Domesticated	Public Safety and Welfare
305	Civil Disputes	Public Safety and Welfare
308	Collapse / Illness / Injury Trap	Public Safety and Welfare
309	Concern For Safety	Public Safety and Welfare
304	Domestic Incident	Public Safety and Welfare
320	Firearms	Public Safety and Welfare
325	Hoax Call To Emergency Service	Public Safety and Welfare
321	Immigration	Public Safety and Welfare
303	Industrial Incident / Accident	Public Safety and Welfare
315	Insecure Premises / Vehicles	Public Safety and Welfare
301	Licensing	Public Safety and Welfare
311	Missing Person	Public Safety and Welfare
302	Natural Disaster / Incident / Warn	Public Safety and Welfare
322	Protest / Demonstration	Public Safety and Welfare
313	Sudden Death	Public Safety and Welfare
314	Suspicious Circumstances	Public Safety and Welfare
306	Suspicious Package / Object	Public Safety and Welfare
323	Truancy	Public Safety and Welfare
312	Wanted - Police / Crt Order / Bail	Public Safety and Welfare
324	Wildlife	Public Safety and Welfare

500	Complaints Against Police	Administration
507	Contact Record	Administration
506	Duplicate	Administration
05 	Error 	Administration
501	Lost / Found Property / Person	Administration
502	Messages	Administration
503	Police Generated Resource Activity	Administration
504	Pre-Planned Events	Administration
509	Test / Training	Administration

645	Abnormal Load	MPS Qualifiers Opening/Closing descriptor   
623	Approach With Caution	MPS Qualifiers Opening/Closing descriptor   
701	Assistance Requested / Rendered	MPS Qualifiers Opening/Closing descriptor   
611	Assistance To Other Public Agency	MPS Qualifiers Opening/Closing descriptor   
624	Attempted	MPS Qualifiers Opening/Closing descriptor   
625	Believed	MPS Qualifiers Opening/Closing descriptor   
653	CA - Confirmed Audible	MPS Qualifiers Opening/Closing descriptor   
602	Call Made With Good Intent	MPS Qualifiers Opening/Closing descriptor   
655	CCTV - Confirmed via CCTV	MPS Qualifiers Opening/Closing descriptor   
666	Chemical / Radiation	MPS Qualifiers Opening/Closing descriptor   
609	Child / Young Person At Risk	MPS Qualifiers Opening/Closing descriptor   
603	Cold Calling	MPS Qualifiers Opening/Closing descriptor   
678	Covid	MPS Qualifiers Opening/Closing descriptor   
604	Critical Incident	MPS Qualifiers Opening/Closing descriptor   
652	CS - Confirmed Sequentially	MPS Qualifiers Opening/Closing descriptor   
641	CS Spray Used	MPS Qualifiers Opening/Closing descriptor   
654	CV - Confirmed Visual	MPS Qualifiers Opening/Closing descriptor   
700	Detain / Detained	MPS Qualifiers Opening/Closing descriptor   
606	Domestic Crime	MPS Qualifiers Opening/Closing descriptor   
671	Explosion	MPS Qualifiers Opening/Closing descriptor   
657	False Alarm - Set Off In Error	MPS Qualifiers Opening/Closing descriptor   
643	Fire / Gas / Electricity	MPS Qualifiers Opening/Closing descriptor   
658	Firearm Discharged	MPS Qualifiers Opening/Closing descriptor   
659	Firearm Imitation	MPS Qualifiers Opening/Closing descriptor   
660	Firearm Injury	MPS Qualifiers Opening/Closing descriptor   
661	Firearm No Injury	MPS Qualifiers Opening/Closing descriptor   
662	Firearm Seen	MPS Qualifiers Opening/Closing descriptor   
663	Firearm Not Seen	MPS Qualifiers Opening/Closing descriptor   
674	Go To Meet / Contact / Enquire	MPS Qualifiers Opening/Closing descriptor   
631	Honour Based Incident	MPS Qualifiers Opening/Closing descriptor   
649	IA - Intruder Alarm	MPS Qualifiers Opening/Closing descriptor   
704	Inform / Informed	MPS Qualifiers Opening/Closing descriptor   
636	Intimidation	MPS Qualifiers Opening/Closing descriptor   
642	Intoxicants Other	MPS Qualifiers Opening/Closing descriptor   
633	Knife / Bladed Article	MPS Qualifiers Opening/Closing descriptor   
651	LF - Line Fault	MPS Qualifiers Opening/Closing descriptor   
637	Local Priority	MPS Qualifiers Opening/Closing descriptor   
605	Major Incident	MPS Qualifiers Opening/Closing descriptor   
675	Missing Persons Safe & Well check	MPS Qualifiers Opening/Closing descriptor   
644	Motorway Incident	MPS Qualifiers Opening/Closing descriptor   
650	PA - Personal Attack	MPS Qualifiers Opening/Closing descriptor   
638	Quality Of Life	MPS Qualifiers Opening/Closing descriptor   
673	Quality Of Police Service	MPS Qualifiers Opening/Closing descriptor   
640	Repeat Call - Missed Appointment	MPS Qualifiers Opening/Closing descriptor   
639	Repeat Call - PNYA	MPS Qualifiers Opening/Closing descriptor   
610	Repeat Caller And / Or Victim	MPS Qualifiers Opening/Closing descriptor   
676	Resolved by LRT	MPS Qualifiers Opening/Closing descriptor   
664	River / Lake / Canal	MPS Qualifiers Opening/Closing descriptor   
646	Road / Sign Defect	MPS Qualifiers Opening/Closing descriptor   
626	Serious	MPS Qualifiers Opening/Closing descriptor   
672	Stop / Search	MPS Qualifiers Opening/Closing descriptor   
621	Strategic Network	MPS Qualifiers Opening/Closing descriptor   
670	Suspect Armed	MPS Qualifiers Opening/Closing descriptor   
407	Suspect Spoken To	MPS Qualifiers Opening/Closing descriptor   
400	Suspects Chased On Foot	MPS Qualifiers Opening/Closing descriptor   
668	Suspects Disturbed	MPS Qualifiers Opening/Closing descriptor   
667	Suspects On Premises	MPS Qualifiers Opening/Closing descriptor   
619	Terrorist Related	MPS Qualifiers Opening/Closing descriptor   
647	Traffic Hazard	MPS Qualifiers Opening/Closing descriptor   
404	Urgent Assistance	MPS Qualifiers Opening/Closing descriptor   
620	Vehicle Clamp / Removal	MPS Qualifiers Opening/Closing descriptor   
669	Vehicle Locator System	MPS Qualifiers Opening/Closing descriptor   
401	Vehicle Pursuit	MPS Qualifiers Opening/Closing descriptor   
635	Vulnerable	MPS Qualifiers Opening/Closing descriptor   
607	Weapon - Not Knife / Blade Or Firearm	MPS Qualifiers Opening/Closing descriptor   
677	Welfare Check Request - Partner Agency	MPS Qualifiers Opening/Closing descriptor   
		
402	C- Buf - Duplicate Record	System Use
714	Switchboard Call Transferred	System Use
665	Abandoned Call Not To Operator	System Use
*/
