/*==================================================
project:       
Author:        	Kiyarash Salehi 
E-email:       	Kiyarashsalehi79@gmail.com
Student ID:  	402205873
----------------------------------------------------
Creation Date:    13 Jul 2024 - 00:17:23
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
clear all
global intermed "E:\Economics\Applied Econometrics\Projects\P05\Intermediates\"
global raw "E:\Economics\Applied Econometrics\Projects\P05\Raw\"
cd "$intermed"
/*==================================================
              1: cleaning for regression
==================================================*/
*----------1.1: healthcare expenditures
foreach x in R U {
	odbc load, table(`x'1401P3S06) dsn(HIES1401) lowercase clear
	drop dycol01 dycol02
	ren dycol03 hexp
	destring hexp, replace force
	bys address: egen Thexp=total(hexp)
	drop hexp
	gen loghexp=log(Thexp+1)
	duplicates drop address,force
	save "$intermed\`x'healthexp.dta",replace
}
use "$intermed\Uhealthexp.dta",clear
append using "$intermed\Rhealthexp"
save "$intermed\healthexp.dta" , replace
*----------1.2: Household Data
foreach x in R U {
	odbc load, table(`x'1401P1) dsn(HIES1401) lowercase allstring clear
	ren dycol05 age
	keep address age
	destring age, replace force
	gen ag65=0 
	replace ag65=1 if age>=65
	collapse (mean) ag65,by(address) 
	save "$intermed\`x'P1.dta",replace
	
}
append using "$intermed\RP1.dta"
gen A65=0 
replace A65=1 if ag65>0
save "$intermed\age.dta",replace
*----------1.3: Health Insurance Expenditures
foreach x in R U {
	odbc load, table(`x'1401P3S13) dsn(HIES1401) lowercase allstring clear
	ren (dycol01 dycol05) (code insexp) 
	keep address code insexp 
	destring insexp, replace force
	drop if substr(code,1,4)!= "1253"
	collapse (sum) insexp , by(address)
	gen logins= log(insexp+1)
	save "$intermed\`x'insuranceexp.dta",replace
	
}
append using "$intermed\Rinsuranceexp.dta"
save "$intermed\insuranceexp.dta",replace
*----------1.5: Fruit & Vegetable & Milk expenditure 
foreach x in R U {
	odbc load, table(`x'1401P3S01) dsn(HIES1401) lowercase allstring clear
	ren (dycol01 dycol06) (code Fruitexp)
 	keep if (substr(code,1,4)=="0114" | substr(code,1,4)=="0116" | substr(code,1,4)== "0117")
	destring Fruitexp , replace force
	collapse (sum) Fruitexp , by(address)
	gen logfruit=log(Fruitexp+1)
	save "$intermed\ `x'Fruitexp.dta", replace
}
append using "$intermed\ RFruitexp.dta"
save "$intermed\ Fruitexp.dta", replace
*----------1.6: Cigarette
foreach x in R U {
	odbc load, table(`x'1401P3S02) dsn(HIES1401) lowercase allstring clear
	ren (dycol01 dycol06) (code cost)
 	keep if (substr(code,1,3)=="022")
	destring cost , replace force
	gen cigar=0 
	replace cigar=1 if cost>0
	collapse (sum) cigar , by(address)
	replace cigar=1 if cigar>0
	save "$intermed\ `x'cigar.dta", replace
}
append using "$intermed\ Rcigar.dta"
save "$intermed\ cigar.dta", replace
*----------1.7: summary files
foreach x in R U{
	odbc load, table("Sum_`x'1401_New_HK$") dsn("SUM`x'1401") lowercase allstring  clear
	ren (daramad a01 a05new a06 c01) (income headgender edulevel activitystatus hhsize)
	
	keep address weight income edulevel headgender activitystatus hhsize
	order address weight income edulevel headgender activitystatus hhsize
	destring weight-hhsize ,replace force
	replace edulevel=4 if edulevel==5
	replace edulevel=5 if edulevel==6
	replace edulevel=6 if (edulevel==7 | edulevel==8)
	drop if edulevel==9
	gen loginc=log(income+1)
	save "$intermed\ Sum`x'1401.dta",replace
}
append using "$intermed\ SumR1401.dta"
save "$intermed\ sum1401.dta",replace
*----------1.8: merge
use "$intermed\ healthexp.dta" , clear
merge 1:1 address using "$intermed\ sum1401.dta"
replace loghexp=0 if loghexp==.
drop _merge
merge 1:1 address using "$intermed\ age.dta"
drop if _merge==2
drop ag65
drop _merge
merge 1:1 address using "$intermed\ insuranceexp.dta"
replace logins=0 if logins==.
drop _merge
merge 1:1 address using "$intermed\ Fruitexp.dta"
replace logfruit=0 if logfruit==.
drop _merge
merge 1:1 address using "$intermed\ cigar.dta"
replace cigar=0 if cigar==. 
drop _merge
gen Province=substr(address,2,2)
destring Province ,replace force
gen urban=0 
replace urban=1 if substr(address,1,1)=="1"
label drop _all
label def province 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzarbaijanSharghi" 4 "AzarbaijanGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Shomali" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province province 
label def agee 0 "No one is above 65" 1 "At least one is above 65"
label val A65 agee
label def educ 0 "Illiterate" 1 "Elementry School" 2 "Secondry School" 3 "Third School" 4 "Diploma" 5 "Bachelor" 6 "Master and PHD"
label val edulevel educ
label def urb 0 "Rural" 1 "Urban"
label val urban urb
drop if headgender==. | headgender==0
label def gender 1 "Male" 2 "Female"
label val headgender gender
save "$intermed\ Final.dta",replace
/*==================================================
              2: clean for graphs
==================================================*/
*----------2.1: bimap cigar health care expenditure
spshape2dta "$raw\ir.shp", replace saving("iran_map")
use "$intermed\ Final.dta", clear
collapse (mean) cigar Thexp, by(Province)
gen _ID=1
replace _ID=2 if Province==3
replace _ID=3 if Province==24
replace _ID=4 if Province==1		
replace _ID=5 if Province==12	
replace _ID=6 if Province==5	
replace _ID=7 if Province==16	
replace _ID=8 if Province==6
replace _ID=9 if Province==28	
replace _ID=10 if Province==27	
replace _ID=11 if Province==9	
replace _ID=12 if Province==29
replace _ID=13 if Province==11
replace _ID=14 if Province==18
replace _ID=15 if Province==22
replace _ID=16 if Province==02
replace _ID=17 if Province==20
replace _ID=18 if Province==19
replace _ID=19 if Province==26
replace _ID=20 if Province==0
replace _ID=21 if Province==10
replace _ID=22 if Province==14
replace _ID=23 if Province==17
replace _ID=24 if Province==7
replace _ID=25 if Province==8
replace _ID=26 if Province==13
replace _ID=27 if Province==15
replace _ID=28 if Province==21
replace _ID=29 if Province==25
replace _ID=30 if Province==23
replace _ID=31 if Province==30
save "cigarhealthmap",replace
*----------2.2: 10 years health expenditure
foreach y of numlist 92/99 1400 1401{
	foreach x in R U{
		
		odbc load, table(`x'`y'P3S06) dsn(HIES`y') lowercase clear
		drop dycol01 dycol02
		ren dycol03 hexp
		destring hexp, replace force
		egen Totalhealthexp`y'=total(hexp) 
		drop hexp
		save "$intermed\ `x'`y'healthexp.dta",replace
	}
	append using "$intermed\ R`y'healthexp.dta", force
	duplicates drop Totalhealthexp`y',force
	egen Thealthexp`y'=total(Totalhealthexp`y')
	keep Thealthexp`y'
	drop in 1
	save "$intermed\ health`y'",replace
}
foreach yy of numlist 92/99 1400{
	append using "$intermed\ health`yy'"
}
collapse (sum) _all
reshape long Thealthexp,i(Thealthexp*) j(year)
keep Thealthexp year
sort year
replace year=1392 if year==92
replace year=1393 if year==93
replace year=1394 if year==94
replace year=1395 if year==95
replace year=1396 if year==96
replace year=1397 if year==97
replace year=1398 if year==98
replace year=1399 if year==99
save "$intermed\ healthexpend",replace
*----------2.3: Age



*----------2.4:


*----------2.5:


*----------2.6:


/*==================================================
              3:  clean for tables
==================================================*/
*----------3.1:


*----------3.2:


*----------3.3:


*----------3.4:


*----------3.5:


*----------3.6:


/*==================================================
              4: 
==================================================*/


*----------4.1:


*----------4.2:


*----------4.3:


*----------4.4:


*----------4.5:


*----------4.6:


/*==================================================
              5: 
==================================================*/


*----------5.1:


*----------5.2:


*----------5.3:


*----------5.4:


*----------5.5:


*----------5.6:


/*==================================================
              6: 
==================================================*/


*----------6.1:


*----------6.2:


*----------6.3:


*----------6.4:


*----------6.5:


*----------6.6:






/* End of do-file */