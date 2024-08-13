/*==================================================
project:       	Panel Project
Author:        	Kiyarash Salehi 
E-email:       	kiyarashsalehi79@gmail.com
Student ID:		402205873 	           
Dependencies:  
----------------------------------------------------
Creation Date:    25 Mar 2024 - 15:16:46
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 17
cd "E:\Economics\Applied Econometrics\Projects\P02"
drop _all
set linesize 80
/*==================================================
              1: exporting from raw datas
==================================================*/
*----------1.1: LFS
foreach y of numlist 95/99 {
	if `y'==96 | `y'==97{
		odbc load,table("LFS_RawData13`y'") dsn("LFS`y'") clear
		rename IW_Yearly weight
		save "LFS`y'",replace
	}
	else if `y'==95 {
		odbc load,table("LFS_RawData") dsn("LFS`y'") clear
		rename IW10_Yearly weight
		save "LFS`y'",replace
	}
	else {
		odbc load,table("LFS_RawData") dsn("LFS`y'") clear
		rename IW_Yearly weight
		save "LFS`y'",replace
	}
}
*----------1.2: HIES
foreach y of numlist 95/99{
	odbc load, table("R`y'P1") lowercase dsn("HIES`y'") clear
	save "R`y'P1",replace
	odbc load, table("U`y'P1") lowercase dsn("HIES`y'") clear
	save "U`y'P1",replace
	append using R`y'P1, force
	save `y'P1,replace
}
*----------1.3: HIES Summaries
foreach y of numlist 95/99 {
	odbc load, table("SumR`y'$") lowercase dsn("SUMR`y'") clear
	rename c01 HouseHoldSize 
	save "SumR`y'",replace
	odbc load, table("SumU`y'$") lowercase dsn("SUMU`y'") clear
	rename c01 HouseHoldSize
	save "SumU`y'",replace
}
*----------1.4: Birth Rate
import excel "Mizan_Kham_Mavalid_1400.xlsx", sheet("Sheet1") allstring clear
save BirthRate, replace
*----------1.5: CPI
import excel "CPI.xlsx", sheet("Sheet1") allstring clear
save CPI, replace
/*==================================================
              2: cleaning and generating new variables
==================================================*/
*----------2.1: LFS
foreach y of numlist 95/99 {
	use "LFS`y'",clear
	rename F2_D04 Gender
	rename F2_D07 Age
	keep pkey Gender Age ActivityStatus weight 
	gen workage=0
	destring Age, replace force
	destring Gender, replace force
	replace workage=1 if Age >= 15
	gen Province=substr(pkey,3,2)
	gen female= .
	replace female=1 if Gender==2
	replace female=0 if Gender==1
	gen male= .
	replace male=1 if Gender==1
	replace male=0 if Gender==2
	gen Active= .
	replace Active=1 if ActivityStatus=="1" | ActivityStatus=="2"
	replace Active=0 if ActivityStatus=="3"
	drop if Age<15
	*---------------------------------------------------------------*
	/* All labor unemploymentrate*/
	*---------------------------------------------------------------*
	gen employers= .
	replace employers=1 if ActivityStatus=="1"
	replace employers=0 if ActivityStatus!="1"
	gen Unemployers= .
	replace Unemployers=1 if ActivityStatus=="2"
	replace Unemployers=0 if ActivityStatus!="2"
	bys Province: egen TotalEmployers=total(employers*weight)
	bys Province: egen TotalUnemployers=total(Unemployers*weight)
	gen UnemploymentrateAll`y'=(TotalUnemployers/(TotalUnemployers+TotalEmployers))*100
	*---------------------------------------------------------------*
	/* female labor participationrate*/
	*---------------------------------------------------------------*
	gen FemActive= .
	replace FemActive=1 if female==1 & ActivityStatus!="3"
	replace FemActive=0 if female!=1 | ActivityStatus=="3"
	bys Province: egen Tfemale=total(female*weight)
	bys Province: egen TfemActive=total(FemActive*weight)
	gen ParticipationrateFemale`y'=(TfemActive/Tfemale)*100
	collapse (mean) ParticipationrateFemale`y' UnemploymentrateAll`y', by(Province)
	save "LFSFinal`y'", replace
}
merge 1:1 Province using LFSFinal95 
drop _merge 
merge 1:1 Province using LFSFinal96 
drop _merge 
merge 1:1 Province using LFSFinal97 
drop _merge 
merge 1:1 Province using LFSFinal98 
drop _merge 
save FinalLFS, replace
*----------2.2: CPI
use CPI, clear
keep B BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DD DE DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS
rename (BL BM BN BO BP BQ BR BS BT BU BV BW) (Farv95 Ord95 Khord95 Tir95 Mord95 Shahr95 Mehr95 Aban95 Azar95 Dey95 Bahm95 Esf95)
rename (BX BY BZ CA CB CC CD CE CF CG CH CI) (Farv96 Ord96 Khord96 Tir96 Mord96 Shahr96 Mehr96 Aban96 Azar96 Dey96 Bahm96 Esf96)
rename (CJ CK CL CM CN CO CP CQ CR CS CT CU) (Farv97 Ord97 Khord97 Tir97 Mord97 Shahr97 Mehr97 Aban97 Azar97 Dey97 Bahm97 Esf97)
rename (CV CW CX CY CZ DA DB DC DD DE DF DG) (Farv98 Ord98 Khord98 Tir98 Mord98 Shahr98 Mehr98 Aban98 Azar98 Dey98 Bahm98 Esf98)
rename (DH DI DJ DK DL DM DN DO DP DQ DR DS) (Farv99 Ord99 Khord99 Tir99 Mord99 Shahr99 Mehr99 Aban99 Azar99 Dey99 Bahm99 Esf99)
rename B Province
drop in 1/4
destring Farv* Ord* Khord* Tir* Mord* Shahr* Mehr* Aban* Azar* Dey* Bahm* Esf* , replace
foreach y of numlist 95/99{
	gen CPI`y'=(Farv`y' + Ord`y' + Khord`y' + Tir`y'+ Mord`y' + Shahr`y' + Mehr`y' + Aban`y' + Azar`y' + Dey`y' + Bahm`y' + Esf`y')/12 
}
keep Province CPI*
save CPI, replace

*----------2.3: Summaries
foreach y of numlist 95/99{
	use SumR`y',clear
	append using SumU`y', force
	gen Province=substr(address,2,2)
	keep address daramad Province HouseHoldSize weight
	*---------------------------------------------------------------*
	/* mean HouseHoldSize per Province */
	*---------------------------------------------------------------*
	bys Province: egen weightedSize=total(weight*HouseHoldSize)
	bys Province: egen Tweight=total(weight)
	gen meanHSize`y'= weightedSize/Tweight
	*---------------------------------------------------------------*
	/*real income per capita in each province */
	*---------------------------------------------------------------*
	bys Province: egen totalweightedIncome=total(daramad*weight)
	bys Province: egen totalweightedHSize=total(HouseHoldSize*weight)
	gen IncomePerCapita`y'=totalweightedIncome/totalweightedHSize
	collapse meanHSize`y' IncomePerCapita`y' , by(Province)
	merge 1:1 Province using CPI 
	gen realInc`y'=(IncomePerCapita`y'/CPI`y')*100
	keep Province realInc`y' meanHSize`y'
	save Sum`y' ,replace
}
merge 1:1 Province using Sum98
drop _merge
merge 1:1 Province using Sum97
drop _merge
merge 1:1 Province using Sum96
drop _merge
merge 1:1 Province using Sum95
drop _merge
save Sum,replace
*----------2.4: HIES
 
foreach y of numlist 95/99 {
	
	use SumR`y' , clear 
	append using SumU`y',force
	keep address weight
	save weight`y' , replace
	use `y'P1 , clear
	rename (dycol04 dycol06 dycol08) (Gender literacy Edustatus)
	drop if Gender=="1"
 	gen Province= substr(address,2,2)
	merge m:m address using weight`y'
	drop if _merge!=3
	gen Eduyears=0 
	if `y'<97{
		replace Eduyears=5 if Edustatus=="11"
	replace Eduyears=8 if Edustatus=="21" | Edustatus=="31"
	replace Eduyears=12 if Edustatus=="41"
	replace Eduyears=14 if Edustatus=="51"
	replace Eduyears=16 if Edustatus=="52"	
	replace Eduyears=20 if Edustatus=="53"
	replace Eduyears=22 if Edustatus=="61"	
	*---------------------------------------------------------------*
	/* Women average Education */
	*---------------------------------------------------------------*
	bys Province: egen EduYWeight=total(Eduyears * weight)
	bys Province: egen Tweight=total(weight)
	gen EduYAvg`y'= EduYWeight/Tweight
	keep EduYAvg`y' Province
	collapse EduYAvg`y' , by(Province)
	save EduYAvg`y',replace
		
	}
	else{
	replace Eduyears=5 if Edustatus=="1"
	replace Eduyears=8 if Edustatus=="2" | Edustatus=="3"
	replace Eduyears=12 if Edustatus=="4"
	replace Eduyears=14 if Edustatus=="5"
	replace Eduyears=16 if Edustatus=="6"	
	replace Eduyears=20 if Edustatus=="7"
	replace Eduyears=22 if Edustatus=="8"	
	*---------------------------------------------------------------*
	/* Women average Education */
	*---------------------------------------------------------------*
	bys Province: egen EduYWeight=total(Eduyears * weight)
	bys Province: egen Tweight=total(weight)
	gen EduYAvg`y'= EduYWeight/Tweight
	keep EduYAvg`y' Province
	collapse EduYAvg`y' , by(Province)
	save EduYAvg`y',replace	
	}
	
}
merge 1:1 Province using EduYAvg98
drop _merge
merge 1:1 Province using EduYAvg97
drop _merge
merge 1:1 Province using EduYAvg96
drop _merge
merge 1:1 Province using EduYAvg95
drop _merge
save EduYAvg, replace
*----------2.5: birth rate for each province
use BirthRate ,clear
drop C E G I K L M
drop in 1/4
rename B birthrate95
rename D birthrate96
rename F birthrate97
rename H birthrate98
rename J birthrate99
rename A Province
replace Province= "00" if Province == "مرکزی"
replace Province= "01" if Province == "گیلان"
replace Province= "02" if Province == "مازندران"
replace Province= "03" if Province == "آذربایجان شرقی"
replace Province= "04" if Province == "آذربایجان غربی"
replace Province= "05" if Province == "کرمانشاه"
replace Province= "06" if Province == "خوزستان"
replace Province= "07" if Province == "فارس"
replace Province= "08" if Province == "کرمان"
replace Province= "09" if Province == "خراسان رضوی"
replace Province= "10" if Province == "اصفهان"
replace Province= "11" if Province == "سیستان و بلوچستان"
replace Province= "12" if Province == "کردستان"
replace Province= "13" if Province == "همدان"
replace Province= "14" if Province == "چهارمحال و بختیاری"
replace Province= "15" if Province == "لرستان"
replace Province= "16" if Province == "ایلام"
replace Province= "17" if Province == "کهگیلویه و بویراحمد"
replace Province= "18" if Province == "بوشهر"
replace Province= "19" if Province == "زنجان"
replace Province= "20" if Province == "سمنان"
replace Province= "21" if Province == "یزد"
replace Province= "22" if Province == "هرمزگان"
replace Province= "23" if Province == "تهران"
replace Province= "24" if Province == "اردبیل"
replace Province= "25" if Province == "قم"
replace Province= "26" if Province == "قزوین"
replace Province= "27" if Province == "گلستان"
replace Province= "28" if Province == "خراسان شمالی"
replace Province= "29" if Province == "خراسان جنوبی"
replace Province= "30" if Province == "البرز"
sort Province
destring birthrate95 , replace 
destring birthrate96 ,  replace 
destring birthrate97 ,  replace 
destring birthrate98 ,  replace 
destring birthrate99 ,  replace 
save BirthRate , replace

/*==================================================
              3: merging all datasets  
==================================================*/
*----------3.1: building final dataset
use BirthRate, clear
merge 1:1 Province using EduYAvg
drop _merge
merge 1:1 Province using Sum
drop _merge
merge 1:1 Province using FinalLFS
drop _merge
reshape long birthrate EduYAvg meanHSize realInc ParticipationrateFemale UnemploymentrateAll, i(Province) j(year)
gen lnBirth=log(birthrate)
gen lnrealInc=log(realInc)
destring Province,replace force
label def prov 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzSharghi" 4 "AZGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Sh" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province prov 
/*==================================================
              4: run the regression
==================================================*/
*----------4.1: Fixed Effects
xtset Province year
xtreg lnBirth EduYAvg meanHSize lnrealInc ParticipationrateFemale , fe 
estimates store Fixed
outreg2 using "P2-PanelData.doc", replace ctitle(Fixed Effect ) addtext(Province FE, YES)
*----------4.2:random effect
xtset Province year
xtreg lnBirth EduYAvg meanHSize lnrealInc ParticipationrateFemale, re 
estimates store Random
 outreg2 using "P2-PanelData.doc", append ctitle(Random Effect ) 
/*==================================================
              5: Hausman Test
==================================================*/
asdoc hausman Fixed Random , save(Hausman.doc) replace
/*==================================================
              6: Datas and Statistics 
==================================================*/
*----------6.1: birth rate
import excel "Mizan_Kham_Mavalid_1400.xlsx", sheet("Sheet1") allstring clear
drop C E G I K L M
drop in 1/4
rename B birthrate95
rename D birthrate96
rename F birthrate97
rename H birthrate98
rename J birthrate99
rename A Province
replace Province= "00" if Province == "مرکزی"
replace Province= "01" if Province == "گیلان"
replace Province= "02" if Province == "مازندران"
replace Province= "03" if Province == "آذربایجان شرقی"
replace Province= "04" if Province == "آذربایجان غربی"
replace Province= "05" if Province == "کرمانشاه"
replace Province= "06" if Province == "خوزستان"
replace Province= "07" if Province == "فارس"
replace Province= "08" if Province == "کرمان"
replace Province= "09" if Province == "خراسان رضوی"
replace Province= "10" if Province == "اصفهان"
replace Province= "11" if Province == "سیستان و بلوچستان"
replace Province= "12" if Province == "کردستان"
replace Province= "13" if Province == "همدان"
replace Province= "14" if Province == "چهارمحال و بختیاری"
replace Province= "15" if Province == "لرستان"
replace Province= "16" if Province == "ایلام"
replace Province= "17" if Province == "کهگیلویه و بویراحمد"
replace Province= "18" if Province == "بوشهر"
replace Province= "19" if Province == "زنجان"
replace Province= "20" if Province == "سمنان"
replace Province= "21" if Province == "یزد"
replace Province= "22" if Province == "هرمزگان"
replace Province= "23" if Province == "تهران"
replace Province= "24" if Province == "اردبیل"
replace Province= "25" if Province == "قم"
replace Province= "26" if Province == "قزوین"
replace Province= "27" if Province == "گلستان"
replace Province= "28" if Province == "خراسان شمالی"
replace Province= "29" if Province == "خراسان جنوبی"
replace Province= "30" if Province == "البرز"
sort Province
destring birthrate95 , replace 
destring birthrate96 ,  replace 
destring birthrate97 ,  replace 
destring birthrate98 ,  replace 
destring birthrate99 ,  replace 
destring Province,replace force
label def prov 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzSharghi" 4 "AZGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Sh" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province prov
decode Province, gen(Provinces)
graph bar (mean) birthrate95 , over(Provinces, label(angle(90) labsize(small))) bargap(80) ytitle(میزان خام موالید) ytitle(, size(small)) title(میزان موالید سال 1395, size(medsmall))
graph export "E:\Economics\Applied Econometrics\Projects\P02\BirthRate95.png", as(png) name("Graph") replace
graph bar (mean) birthrate96 , over(Provinces, label(angle(90) labsize(small))) bargap(80) ytitle(میزان خام موالید) ytitle(, size(small)) title(میزان موالید سال 1396, size(medsmall))
graph export "E:\Economics\Applied Econometrics\Projects\P02\BirthRate96.png", as(png) name("Graph") replace
graph bar (mean) birthrate97 , over(Provinces, label(angle(90) labsize(small))) bargap(80) ytitle(میزان خام موالید) ytitle(, size(small)) title(میزان موالید سال 1397, size(medsmall))
graph export "E:\Economics\Applied Econometrics\Projects\P02\BirthRate97.png", as(png) name("Graph") replace
graph bar (mean) birthrate98 , over(Provinces, label(angle(90) labsize(small))) bargap(80) ytitle(میزان خام موالید) ytitle(, size(small)) title(میزان موالید سال 1398, size(medsmall))
graph export "E:\Economics\Applied Econometrics\Projects\P02\BirthRate98.png", as(png) name("Graph") replace
graph bar (mean) birthrate99 , over(Provinces, label(angle(90) labsize(small))) bargap(80) ytitle(میزان خام موالید) ytitle(, size(small)) title(میزان موالید سال 1399, size(medsmall))
graph export "E:\Economics\Applied Econometrics\Projects\P02\BirthRate99.png", as(png) name("Graph") replace
*----------6.2: Real Income
use Sum,replace
keep realInc* Province
reshape long realInc, i(Province) j(year)
graph bar (sum) realInc, over(year) exclude0 scale(0.5) title(درآمد واقعی طی سالهای 95الی99) ytitle(ریال)
graph export "E:\Economics\Applied Econometrics\Projects\P02\RealInc.png", as(png) name("Graph") replace
use Sum,replace
destring Province,replace force
label def prov 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzSharghi" 4 "AZGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Sh" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province prov
decode Province, gen(Provinces)
asdoc list Provinces realInc95 realInc96 realInc97 realInc98 realInc99, save(RealInc.doc) title(Real Households Income 1395 to 1399) replace
*----------6.3:Labor
use FinalLFS, clear
keep Province ParticipationrateFemale*
destring Province,replace force
label def prov 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzSharghi" 4 "AZGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Sh" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province prov
decode Province, gen(Provinces)
rename (ParticipationrateFemale95 ParticipationrateFemale96 ParticipationrateFemale97 ParticipationrateFemale98 ParticipationrateFemale99) (WomenPrate95 WomenPrate96 WomenPrate97 WomenPrate98 WomenPrate99)
asdoc list Provinces WomenPrate95 WomenPrate96 WomenPrate97 WomenPrate98 WomenPrate99, save(Prate.doc) title(Women Participation Rate 1395 to 1399) replace

use FinalLFS, clear
keep Province UnemploymentrateAll*
destring Province,replace force
label def prov 0 "Markazi" 1 "Guilan" 2 "Mazandaran" 3 "AzSharghi" 4 "AZGharbi" 5 "Kermanshah" 6 "Khouzestan" 7 "Fars" 8 "Kerman" 9 "Khorasan Razavi" 10 "Esfehan" 11 "Sistan" 12 "Kurdistan" 13 "Hamedan" 14 "Chaharmahal" 15 "Lorestan" 16 "Ilam" 17 "Koguiloye" 18 "Boushehr" 19 "Zanjan" 20 "Semnan" 21 "Yazd" 22 "Hormozgan" 23 "Tehran" 24 "Ardebil" 25 "Qom" 26 "Qazvin" 27 "Golestan" 28 "Khorasan Sh" 29 "Khorasan Jonoobi" 30 "Alborz"
lab val Province prov
decode Province, gen(Provinces)
rename (UnemploymentrateAll*) (Unemploymentrate*)
asdoc list Provinces Unemploymentrate*, save(UErate.doc) title(Country Unemployment Rate 1395 to 1399) replace

/* End of do-file */
