/*==================================================
project:       RD Project 
Author:        Kiyarash Salehi 
E-email:       kiyarashsalehi79@gmail.com
url:           402205873
Dependencies:  
----------------------------------------------------
Creation Date:    18 Jul 2024 - 12:15:53
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
clear all
cd "E:\Economics\Applied Econometrics\Projects\P06"
*----------0.1:install some packages
ssc install spmap
ssc install shp2dta
ssc install mif2dta
ssc install blindschemes
net install schemepack, from("https://raw.githubusercontent.com/asjadnaqvi/stata-schemepack/main/installation/") replace
ssc install colrspace
ssc install palettes
*----------0.2: set font
graph set window fontface "XB Niloofar"
/*==================================================
              1: cleaning data
==================================================*/
set scheme gg_tableau
*----------1.1:HIES
foreach x of numlist 92/99 1400 1401{
	odbc load, table(R`x'P1) dsn(HIES`x') lowercase allstring clear 
	ren (dycol01 dycol03 dycol04 dycol05 dycol06  dycol09 dycol10) (radif relationship gender age edustat  activitystatus marriagestatus)  
	keep radif relationship gender age edustat dycol08 activitystatus marriagestatus address
	destring dycol08,replace force
	gen edulevel=0
	replace edulevel=1 if dycol08==1
	replace edulevel=2 if (dycol08==2 | dycol08==3)
	replace edulevel=3 if (dycol08==4)
	replace edulevel=4 if (dycol08==5 | dycol08==6)
	replace edulevel=5 if (dycol08==7 | dycol08==8)
	drop if dycol08==9
	drop dycol08
	destring age, replace force
	gen childU6=0
	replace childU6=1 if (relationship=="3" & age <= 6 )
	gen childA6=0 
	replace  childA6=1 if (relationship=="3" & age > 6 & age< 19 )
	bys address: egen kidU6=total(childU6)
	bys address: egen kidA6=total(childA6)
	gen urban=0
	save "R`x'P1.dta",replace
	odbc load, table(U`x'P1) dsn(HIES`x') lowercase allstring clear
	ren (dycol01 dycol03 dycol04 dycol05 dycol06  dycol09 dycol10) (radif relationship gender age edustat  activitystatus marriagestatus)  
	keep radif relationship gender age edustat dycol08 activitystatus marriagestatus address
	destring dycol08,replace force
	gen edulevel=0
	replace edulevel=1 if dycol08==1
	replace edulevel=2 if (dycol08==2 | dycol08==3)
	replace edulevel=3 if (dycol08==4)
	replace edulevel=4 if (dycol08==5 | dycol08==6)
	replace edulevel=5 if (dycol08==7 | dycol08==8)
	drop if dycol08==9
	drop dycol08
	destring age, replace force
	gen childU6=0
	replace childU6=1 if (relationship=="3" & age <= 6 )
	gen childA6=0 
	replace  childA6=1 if (relationship=="3" & age > 6 & age< 19 )
	bys address: egen kidU6=total(childU6)
	bys address: egen kidA6=total(childA6)
	gen urban=1
	append using R`x'P1.dta
	drop childU6 childA6
	save "UR`x'P1.dta",replace
	// wage
	odbc load, table(R`x'P4S01) dsn(HIES`x') lowercase allstring clear 
	ren (dycol01 dycol15) (radif wage)  
	keep address radif wage 
	gen urban=0
	save wageR`x',replace
	odbc load, table(U`x'P4S01) dsn(HIES`x') lowercase allstring clear
	ren (dycol01 dycol15) (radif wage)  
	keep address radif wage 
	gen urban=1
	append using wageR`x'
	destring wage,replace
	save wage`x',replace
	//self income
	odbc load, table(R`x'P4S02) dsn(HIES`x') lowercase allstring clear 
	ren (dycol01 dycol15) (radif selfincome)  
	keep address radif selfincome 
	gen urban=0
	save selfincomeR`x',replace
	odbc load, table(U`x'P4S02) dsn(HIES`x') lowercase allstring clear
	ren (dycol01 dycol15) (radif selfincome)  
	keep address radif selfincome 
	gen urban=1
	append using selfincomeR`x'
	destring selfincome, replace
	save selfincome`x',replace
	// other incomes
	odbc load, table(R`x'P4S03) dsn(HIES`x') lowercase allstring clear 
	destring dycol04 dycol03 dycol05 dycol06 dycol07 dycol08 , replace
	ren dycol01 radif 
	egen otherinc=rowtotal(dycol*)
	keep address otherinc radif
	gen urban=0
	save otherincR`x',replace
	odbc load, table(U`x'P4S03) dsn(HIES`x') lowercase allstring clear
	destring dycol04 dycol03 dycol05 dycol06 dycol07 dycol08 , replace
	ren dycol01 radif 
	egen otherinc=rowtotal(dycol*)
	keep address otherinc radif
	gen urban=1
	append using otherincR`x'
	save otherinc`x',replace
}

*----------1.2: summaries
foreach y of numlist 92/99 1400 1401 {
    if `y'<1400{
	    odbc load, table("SumR`y'$") dsn("SUMR`y'")  lowercase allstring  clear
		keep address weight
		format address %11s
		recast str11 address, force
		save "SumR`y'",replace
		odbc load, table("SumU`y'$") dsn("SUMU`y'")  lowercase allstring  clear
		keep address weight
		append using SumR`y'
		save "weight`y'",replace
	}
	else {
	    odbc load, table("Sum_R`y'_New_HK$") dsn("SUMR`y'") lowercase allstring  clear
		keep address weight
		save SumR`y',replace
		odbc load, table("Sum_U`y'_New_HK$") dsn("SUMU`y'") lowercase allstring  clear
		keep address weight
		append using SumR`y'
		save weight`y',replace
	    
	}
}
*----------1.3: final cleaning
use UR1401P1,clear
merge m:1 address using weight1401
destring weight, replace force
drop _merge
drop if age<15
gen active=1 
replace active=0 if (activitystatus!="1"  & activitystatus!="2")
drop if gender=="1"
gen cutoff= age-33
bys age: egen tweight = total(weight)
bys age: egen tActive = total(weight) if active == 1
gen Particip = tActive / tweight


save Final1401,replace
/*==================================================
              2: Model
==================================================*/
use Final1401,clear
rdrobust Particip age, c(33) covs(kidU6 edulevel urban) p(1) h(10) 
outreg2 using RD.doc, replace ctitle(RD Regression ) label 
rdplot Particip age, c(33) covs(kidU6 edulevel urban) masspoints(adjust) p(1) h(10) 
graph export "E:\Economics\Applied Econometrics\Projects\P06\RDplot.png", as(png) name("Graph") replace
/*==================================================
              3: Descriptive Statistics and Graphs
==================================================*/
*----------3.1: Women vs Men Participation rate
use weight94, clear
format address %11s
recast str11 address, force
save weight94,replace
foreach x of numlist 92/99 1400 1401{
	use UR`x'P1, clear 
	merge m:1 address using weight`x'
	destring weight, replace
	drop if age <15
	replace activitystatus="3" if (activitystatus!="1" & activitystatus!="2") 
	gen female=0 
	replace female=1 if gender=="2"
	gen male=0
	replace male=1 if gender=="1"
	gen Province=substr(address,2,2)
	gen workage=1
	gen Active= .
	replace Active=1 if activitystatus=="1" | activitystatus=="2"
	replace Active=0 if activitystatus=="3"
	*---------------------------------------------------------------*
	/* femal labor participationrate*/
	*---------------------------------------------------------------*
	gen FemActive=0
	replace FemActive=1 if (female==1 & activitystatus!="3")
	egen Tfemale=total(female*weight)
	egen TfemActive=total(FemActive*weight)
	gen ParticipationrateFemale`x'=(TfemActive/Tfemale)*100
	label var ParticipationrateFemale`x' "Women Participation Rate `x'"
	*---------------------------------------------------------------*
	/* All labor participationrate*/
	*---------------------------------------------------------------*
	egen Weightedworkage=total(workage*weight)
	egen WeightedActive=total(Active*weight)
	gen ParticipationrateAll`x'=(WeightedActive/Weightedworkage)*100
	label var ParticipationrateAll`x' "All Gender Participation Rate `x'"
	*---------------------------------------------------------------*
	/*male participation rate*/
	*---------------------------------------------------------------*
	gen MalActive= .
	replace MalActive=1 if male==1 & activitystatus!="3"
	replace MalActive=0 if male==0 | activitystatus=="3"
	egen TmaleActive=total(MalActive*weight)
	egen Tmale=total(male*weight)
	gen ParticipationrateMale`x'=(TmaleActive/Tmale)*100
	label var ParticipationrateMale`x' "Men Participation Rate `x'"
	collapse ParticipationrateMale`x' ParticipationrateAll`x' ParticipationrateFemale`x'
	save Table1`x', replace
	}
foreach hh of numlist 92/99 1400{
	append using Table1`hh'
}	
collapse _all
xpose, clear varname
gen year=substr(_varname,-2,. )
foreach ll of numlist 92/99 00 01{
	replace year="13`ll'" if substr(year,-2,.)=="`ll'"
}
replace year="1400" if substr(year,-2,.)=="00"
replace year="1401" if substr(year,-2,.)=="01"
destring year, replace
gen type=""
replace type="Women" if substr(_varname, 18, 2)=="Fe"
replace type="Men" if substr(_varname, 18, 2)=="Ma"
replace type="Both" if substr(_varname, 18, 2)=="Al"
rename v1 participationrate
drop _varname
sort year
twoway (line participationrate year if type=="Both") (line participationrate year if type=="Men") (line participationrate year if type=="Women") , legend(label (1 "همه") label (2 "مردان") label (3 "زنان")) xtitle("سال") ytitle("نرخ مشارکت (به درصد)") title("نرخ مشارکت کشور در ده سال1392تا1401") 
graph export "E:\Economics\Applied Econometrics\Projects\P06\Particip10y.png", as(png) name("Graph") replace
*----------3.2: Participation rate 1401
use UR1401P1, clear
merge m:1 address using weight1401
destring weight, replace
drop if age <15
replace activitystatus="3" if (activitystatus!="1" & activitystatus!="2") 
gen female=0 
replace female=1 if gender=="2"
gen male=0
replace male=1 if gender=="1"
gen Province=substr(address,2,2)
gen workage=1
gen Active= .
replace Active=1 if activitystatus=="1" | activitystatus=="2"
replace Active=0 if activitystatus!="3"
*---------------------------------------------------------------*
	/* All labor Participation rate*/
	*---------------------------------------------------------------*
	bys Province:egen Weightedworkage=total(workage*weight)
	bys Province:egen WeightedActive=total(Active*weight)
	gen ParticipationrateAll=(WeightedActive/Weightedworkage)*100
	*---------------------------------------------------------------*
	/* female labor participationrate*/
	*---------------------------------------------------------------*
	gen FemActive= .
	replace FemActive=1 if female==1 & activitystatus!="3"
	replace FemActive=0 if female!=1 | activitystatus=="3"
	bys Province: egen Tfemale=total(female*weight)
	bys Province: egen TfemActive=total(FemActive*weight)
	gen ParticipationrateFemale=(TfemActive/Tfemale)*100
	*---------------------------------------------------------------*
	/*male participation rate*/
	*---------------------------------------------------------------*
	gen MalActive= .
	replace MalActive=1 if male==1 & activitystatus!="3"
	replace MalActive=0 if male==0 | activitystatus=="3"
	bys Province:egen TmaleActive=total(MalActive*weight)
	bys Province:egen Tmale=total(male*weight)
	gen ParticipationrateMale=(TmaleActive/Tmale)*100
	collapse (mean) ParticipationrateFemale  ParticipationrateAll ParticipationrateMale, by(Province)
	gen provinc=1
	replace provinc=2 if Province=="03"
	replace provinc=3 if Province=="24"
	replace provinc=4 if Province=="01"
	replace provinc=5 if Province=="12"
	replace provinc=6 if Province=="05"
	replace provinc=7 if Province=="16"
	replace provinc=8 if Province=="06"
	replace provinc=9 if Province=="28"
	replace provinc=10 if Province=="27"
	replace provinc=11 if Province=="09"
	replace provinc=12 if Province=="29"
	replace provinc=13 if Province=="11"
	replace provinc=14 if Province=="18"
	replace provinc=15 if Province=="22"
	replace provinc=16 if Province=="02"
	replace provinc=17 if Province=="20"
	replace provinc=18 if Province=="19"
	replace provinc=19 if Province=="26"
	replace provinc=20 if Province=="00"
	replace provinc=21 if Province=="10"
	replace provinc=22 if Province=="14"
	replace provinc=23 if Province=="17"
	replace provinc=24 if Province=="07"
	replace provinc=25 if Province=="08"
	replace provinc=26 if Province=="13"
	replace provinc=27 if Province=="15"
	replace provinc=28 if Province=="21"
	replace provinc=29 if Province=="25"
	replace provinc=30 if Province=="23"
	replace provinc=31 if Province=="30"
	save "1401map", replace
spshape2dta ir, replace
use ir , clear
rename _ID provinc
merge 1:1 provinc using 1401map.dta
drop _merge
spmap ParticipationrateFemale using ir_shp , id(provinc) fcolor(PuBuGn) title("نرخ مشارکت زنان در سال 1401 به تفکیک استان",margin(medium)) legtitle("نرخ مشارکت")
graph export "E:\Economics\Applied Econometrics\Projects\P06\Particip1401Fem.png", as(png) name("Graph") replace
spmap ParticipationrateMale using ir_shp , id(provinc) fcolor(PuBuGn) title("نرخ مشارکت مردان در سال 1401 به تفکیک استان",margin(medium)) legtitle("نرخ مشارکت")
graph export "E:\Economics\Applied Econometrics\Projects\P06\Particip1401MEn.png", as(png) name("Graph") replace
*----------3.3: education level
use UR1401P1, clear
label def educ 0 "بی سواد" 1 "ابتدایی" 2 "متوسطه اول و دوم" 3 "دیپلم" 4 "کارشناسی" 5 "کارشناسی ارشد و دکتری"
label val edulevel educ
graph pie , over (edulevel) plabel(_all percent , color(white)) title(" درصد زنان به تفکیک هر سطح تحصیلی در سال 1401")
graph export "E:\Economics\Applied Econometrics\Projects\P06\edulevelPie.png", as(png) name("Graph") replace
*----------3.4:  Kids
preserve 
collapse (mean) kidA6 kidU6, by(address)
graph bar , over(kidA6) title("نسبت خانوارهایی با فرزندان بالای 6 سال") b1title("تعداد فرزندان بالای 6 سال در خانواده") ytitle("درصد") bar(1, fcolor(gs7) lcolor(gs7)) blabel(bar)
graph export "E:\Economics\Applied Econometrics\Projects\P06\kidA6.png", as(png) name("Graph") replace
graph bar , over(kidU6) title("نسبت خانوارهایی با فرزندان 6 سال و یا کمتر") b1title("تعداد فرزندان 6 سال و یا کمتر در خانواده") ytitle("درصد") bar(1, fcolor(gs7) lcolor(gs7)) blabel(bar)
graph export "E:\Economics\Applied Econometrics\Projects\P06\kidU6.png", as(png) name("Graph") replace
restore
*----------3.5: rural urban
use UR1401P1, clear
merge m:m address using weight1401
gen Active=0
replace Active=1 if (activitystatus=="1" | activitystatus=="2")
drop if age< 15
drop if _merge==2
destring weight,replace force
drop if gender == "1"
label def urb 0 "Rural" 1 "Urban"
lab val urban urb
label def act 0 "Inactive" 1 "Active"
label val Active act
 asdoc proportion Active [pweight=weight] ,over(urban) percent replace 

*----------3.7:Women Unemployment rate and Participation rate
set scheme s1mono
use UR1401P1, clear
merge m:1 address using weight1401
destring weight, replace force
drop _merge
gen Active=0
replace Active=1 if (activitystatus=="1" | activitystatus=="2")
gen unemployed=0
replace unemployed=1 if activitystatus=="2"
drop if age< 15
gen Province=substr(address,2,2)
destring Province, replace
drop if gender=="1"
gen female=1
*---------------------------------------------------------------*
/* female labor participationrate*/
*---------------------------------------------------------------*
gen FemActive= .
replace FemActive=1 if female==1 & Active==1
replace FemActive=0 if female!=1 | Active!=1
bys Province: egen Tfemale=total(female*weight)
bys Province: egen TfemActive=total(FemActive*weight)
gen ParticipationrateFemale=(TfemActive/Tfemale)*100
*---------------------------------------------------------------*
/* female unemploymentrate*/
*---------------------------------------------------------------*
gen FUnemployer=0
replace FUnemployer=1 if female==1 & unemployed==1
bys Province:egen TFUnemp=total(FUnemployer*weight)
gen UnemploymentrateFemale=(TFUnemp/TfemActive)*100
collapse (mean) ParticipationrateFemale  UnemploymentrateFemale , by(Province)
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
save "11401map", replace
spshape2dta "ir.shp", replace saving(iran_map)
use iran_map, clear
merge 1:1 _ID using 11401map.dta
drop _merge
cap drop cut*
egen cut_FemUnemp = cut(UnemploymentrateFemale), at(0,33,66,100) icodes
egen cut_FemPart = cut(ParticipationrateFemale), at(0,33,66,100) icodes
// group the categories
sort cut_FemUnemp cut_FemPart
egen grp_cut = group(cut_FemUnemp cut_FemPart)

cap drop xtile*
xtile xtile_FemUnemp = UnemploymentrateFemale, n(3)
xtile xtile_Fempart = ParticipationrateFemale, n(3)

// group the categories
sort xtile_FemUnemp xtile_Fempart
egen grp_xtile = group(xtile_FemUnemp xtile_Fempart)

colorpalette #e8e8e8 #dfb0d6 #be64ac #ace4e4 #a5add3 #8c62aa #5ac8c8 #5698b9 #3b4994, nograph 
local colors `r(p)'
spmap grp_xtile using iran_map_shp,id(_ID) clm(unique)   fcolor("`colors'") ///
ocolor(white ..) osize(0.02 ..) /// 
ndfcolor(gs14) ndocolor(gs6 ..) ndsize(0.03 ..) ndlabel("No data") ///
polygon(data("iran_map_shp") ocolor(white) osize(0.15) ) ///
legend(pos(5) size(2.5))  legstyle(2) ///
legend(off)  ///
name(bivar_map2, replace)
// legend
clear
set obs 9 
 egen y = seq(), b(3)  
 egen x = seq(), t(3)
cap drop spike*
 
gen spike1_x1  = 0.2 in 1
gen spike1_x2  = 3.6 in 1 
gen spike1_y1  = 0.2 in 1 
gen spike1_y2  = 0.2 in 1 
gen spike1_m   = "نرخ بیکاری"   
 
gen spike2_y1  = 0.2 in 1
gen spike2_y2  = 3.2 in 1 
gen spike2_x1  = 0.2 in 1  
gen spike2_x2  = 0.2 in 1  
gen spike2_m   = "نرخ مشارکت"
colorpalette ///
#e8e8e8 #dfb0d6 #be64ac ///
#ace4e4 #a5add3 #8c62aa ///
#5ac8c8 #5698b9 #3b4994 ///
, nograph
local color11 `r(p1)'
local color12 `r(p2)'
local color13 `r(p3)'
local color21 `r(p4)'
local color22 `r(p5)'
local color23 `r(p6)'
local color31 `r(p7)'
local color32 `r(p8)'
local color33 `r(p9)' 
  
levelsof x, local(xlvl) 
levelsof y, local(ylvl)
local boxes
foreach x of local xlvl {
 foreach y of local ylvl {
 
  local boxes `boxes' (scatter y x if x==`x' & y==`y', msymbol(square) msize(5) mc("`color`x'`y''")) ///

 }
}

 twoway ///
`boxes' ///
(pcarrow spike1_y1 spike1_x1 spike1_y2 spike1_x2, lw(thin) lcolor(gs12) mcolor(gs12) mlabel(spike1_m) mlabpos(7 ) msize(0.8) headlabel mlabsize(2)) ///
(pcarrow spike2_y1 spike2_x1 spike2_y2 spike2_x2, lw(thin) lcolor(gs12) mcolor(gs12) mlabel(spike2_m) mlabpos(10) msize(0.8) headlabel mlabangle(90) mlabgap(1.8) mlabsize(2)) ///
, ///
xlabel(0 4, nogrid) ylabel(0 4, nogrid) ///
aspectratio(1) ///
xsize(1) ysize(1) ///
fxsize(20) fysize(100) ///
legend(off)  ///
ytitle("")  xtitle("") ///
xscale(off) yscale(off) ///
name(bivar_legend2, replace)
//combine
graph combine bivar_map2 bivar_legend2, ///
imargin(zero) ///
title("{fontface XB Niloofar:نرخ بیکاری و مشارکت زنان به تفکیک استان در سال 1401}", size(4.5))

graph export "E:\Economics\Applied Econometrics\Projects\P06\UnempPart1401.png", as(png) name("Graph") replace

/* End of do-file */
/* End of do-file */