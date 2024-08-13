/*==================================================
project:       Nonlinear Project
Author:        Kiyarash Salehi 
E-email:       kiyarashsalehi79@gmail.com
Student ID:    402205873	          
Dependencies:  
----------------------------------------------------
Creation Date:    16 Apr 2024 - 09:07:02
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 17
drop _all
cd "E:\Economics\Applied Econometrics\Projects\P03"
/*==================================================
              1: cleaning Data
==================================================*/
*----------1.1: billionaires dataset
import delimited using "E:\Economics\Applied Econometrics\Projects\P03\datasets\forbes_billionaires_list", clear
drop if net_worth<0.9
bys citizenship year: egen numbill=count(v1)
collapse numbill , by(citizenship year)
drop in 1
ren citizenship country
replace country="Czech Republic" if country=="Czechia"
save "Billionaires",replace
*----------1.2: Economic Freedom Index 
use "qog_bas_ts", clear
keep cname year fi_index
drop if year<2010 | year>2022
ren cname  country
replace country="Czech Republic" if country=="Czechia"
replace country="Russia" if country=="Russian Federation (the)" 
replace country="South Korea" if country=="Korea (the Republic of)"
replace country="Slovakia" if country=="Slovak Republic"
replace country="Macao" if country=="Macao SAR, China"
replace country="Taiwan" if country=="Taiwan (Province of China)"
replace country="Netherlands" if country=="Netherlands (the)"
replace country="Philippines" if country=="Philippines (the)"
replace country="Tanzania" if country=="Tanzania, the United Republic of"
replace country="United Arab Emirates" if country=="United Arab Emirates (the)"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland (the)"
replace country="United States" if country=="United States of America (the)"
replace country="Vietnam" if country=="Viet Nam"
replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
save freedomIndex, replace
*----------1.3: Tax Rate on Income (% of revenue)
import excel "tax rate.xlsx", sheet("Data") firstrow allstring clear 
ren CountryName country
foreach y of numlist 2009/2023{
	destring YR`y', replace force
}
keep country YR*
drop in 218/271
reshape long YR, i(country) j(year)
ren YR taxrate
drop if year<2010 | year>2022
replace country="Russia" if country=="Russian Federation" 
replace country="Czech Republic" if country=="Czechia"
replace country="South Korea" if country=="Korea, Rep."
replace country="Slovakia" if country=="Slovak Republic"
replace country="Macao" if country=="Macao SAR, China"
replace country="Vietnam" if country=="Viet Nam"
replace country="Venezuela" if country=="Venezuela, RB"
replace country="Hong Kong" if country=="Hong Kong SAR, China" 
save taxrate , replace
*----------1.4:GDP per capita(constant 2015)
import excel "gdppercapita" , sheet("Data") firstrow clear
ren CountryName country
foreach y of numlist 2004/2023{
	destring YR`y', replace force
}
keep country YR* 
drop in 218/271
reshape long YR, i(country) j(year)
ren YR gdpcapita
drop if year<2010 | year>2022
replace country="Russia" if country=="Russian Federation" 
replace country="Czech Republic" if country=="Czechia"
replace country="South Korea" if country=="Korea, Rep."
replace country="Slovakia" if country=="Slovak Republic"
replace country="Macao" if country=="Macao SAR, China"
replace country="Vietnam" if country=="Viet Nam"
replace country="Venezuela" if country=="Venezuela, RB"
replace country="Hong Kong" if country=="Hong Kong SAR, China" 
save gdppercapita , replace
*----------1.5:Population
import excel "Population" , sheet("Data") firstrow clear
ren CountryName country
foreach y of numlist 2008/2022{
	destring YR`y', replace force
}
keep country YR* 
sort country
drop in 1/3
reshape long YR, i(country) j(year)
ren YR pop
drop if year<2010 | year>2022
replace country="Russia" if country=="Russian Federation" 
replace country="Czech Republic" if country=="Czechia"
replace country="South Korea" if country=="Korea, Rep."
replace country="Slovakia" if country=="Slovak Republic"
replace country="Macao" if country=="Macao SAR, China"
replace country="Hong Kong" if country=="Hong Kong SAR, China" 
replace country="Vietnam" if country=="Viet Nam"
replace country="Venezuela" if country=="Venezuela, RB"
save Population,replace
*----------1.6:Real Interest Rate
import excel "real Interest rate" , sheet("Data") firstrow clear
ren CountryName country
foreach y of numlist 2009/2023{
	destring YR`y', replace force
}
keep country YR* 
drop in 218/271
reshape long YR, i(country) j(year)
ren YR realInt
drop if year<2010 | year>2022
replace country="Russia" if country=="Russian Federation" 
replace country="Czech Republic" if country=="Czechia"
replace country="South Korea" if country=="Korea, Rep."
replace country="Slovakia" if country=="Slovak Republic"
replace country="Macao" if country=="Macao SAR, China"
replace country="Vietnam" if country=="Viet Nam"
replace country="Venezuela" if country=="Venezuela, RB"
replace country="Hong Kong" if country=="Hong Kong SAR, China" 
save RealInterest,replace
/*==================================================
              2: merging datasets
==================================================*/
use RealInterest,clear

merge 1:1 country year using freedomIndex
drop if _merge!=3
drop _merge

merge 1:1 country year using taxrate
drop if _merge!=3
drop _merge

merge 1:1 country year using gdppercapita
drop if _merge!=3
drop _merge

merge 1:1 country year using Population
drop if _merge!=3
drop _merge

merge 1:1 country year using Billionaires
drop _merge
save "Finall", replace
/*==================================================
              3: final cleaning  and regression
==================================================*/
*----------3.1: final cleaning
keep if year==2020
gen numbill0=numbill
replace numbill0=0 if numbill0== .
order country year numbill0 
gen lngdp= log(gdpcapita)
gen lnpop=log(pop)
*----------3.1: regression
poisson numbill0 lngdp lnpop if year==2020 , rob
outreg2 using myreg.doc, replace ctitle("Poisson(1)")

poisson numbill0 lngdp lnpop realInt if year==2020, rob
outreg2 using myreg.doc, append ctitle("Poisson(2)")

poisson numbill0 lngdp lnpop realInt fi_index taxrate , rob
outreg2 using myreg.doc, append ctitle("Poisson(3)")

asdoc margins, dydx(*) save(marginss.doc) replace

reg numbill0 lngdp lnpop realInt fi_index taxrate , rob
outreg2 using myreg.doc, append ctitle("OLS")

save "Last", replace
/*==================================================
              4: Statistical Facts 
==================================================*/
*----------4.1: Data Summary
use Finall,clear
outreg2 using Stats.doc, replace sum(log) keep (numbill gdpcapita pop realInt fi_index taxrate) 
*----------4.2: G-7 Billionaires Summary
graph hbar (mean) numbill if country=="Italy"| country=="Japan" | country=="France" | country=="Canada" | country=="Germany" | country=="United Kingdom" | country=="United States" & (year<=2021 & year>= 2012) , over(country, sort (1) descending label(labsize(*0.7))) bargap(80) ytitle(تعداد میلیاردرها) ytitle(, size(small)) title(میانگین تعداد میلیاردرهای گروه جی-7 بین سالهای 2012 تا 2021 ,size(medsmall)) blabel(bar) bar(1, color(black)) scale(0.6)

graph export "E:\Economics\Applied Econometrics\Projects\P03\G7.png", as(png) name("Graph") replace
*----------4.3: 2020 summary scatter
use Last, clear

gen mpop=pop/(10^6)

twoway scatter numbill mpop if year==2020, mcolor(gs0) || lfit numbill mpop if year==2020, lcolor(blue) title("تعداد میلیاردرها بر اساس جمعیت در سال 2020") ///
	xtitle("جمعیت بر حسب میلیون نفر")  ytitle("تعداد میلیاردرها")  	

graph export "E:\Economics\Applied Econometrics\Projects\P03\popnumb.png", as(png) name("Graph") replace

gen billpop= numbill0/mpop		 

graph hbar billpop if billpop>1& billpop!= .,  over(country, sort (1) descending label(labsize(*0.7))) bargap(80) ytitle(تعداد میلیاردرها در هر میلیون نفر) ytitle(, size(small)) title("نسبت میلیاردرها در هر میلیون نفر به در سال 2020" ,size(medsmall)) blabel(bar) bar(1, color(black)) scale(0.6)

graph export "E:\Economics\Applied Econometrics\Projects\P03\billpop.png", as(png) name("Graph") replace
*----------4.4: freedomIndex Statistics
use freedomIndex ,clear
keep if year==2020
gsort -fi_index
keep in 1/20
graph hbar fi_index ,  over(country, sort(1) descending  label(labsize(*0.7)))  bargap(80) ytitle(میزان شاخص آزادی اقتصادی) ytitle(, size(small)) title("بیست کشور برتر از نظر شاخص آزادی اقتصادی" ,size(medsmall)) blabel(bar) bar(1, color(black)) scale(0.6)
graph export "E:\Economics\Applied Econometrics\Projects\P03\FI20.png", as(png) name("Graph") replace

use Last, clear
twoway scatter numbill fi_index if year==2020, mcolor(gs0) || lfit numbill fi_index if year==2020, lcolor(blue) title("تعداد میلیاردرها بر اساس میزان شاخص آزادی اقتصادی در سال 2020") ///
	xtitle("میزان شاخص آزادی اقتصادی")  ytitle("تعداد میلیاردرها")  
	
graph export "E:\Economics\Applied Econometrics\Projects\P03\FIbill.png", as(png) name("Graph") replace	

*----------4.5: taxrate Statistics
use Last, clear
twoway scatter numbill taxrate if year==2020, mcolor(gs0) || lfit numbill taxrate if year==2020, lcolor(blue) title("تعداد میلیاردرها بر اساس نرخ مالیات در سال 2020") ///
	xtitle("نرخ مالیات در سال 2020 (به درصد)")  ytitle("تعداد میلیاردرها")  
	
graph export "E:\Economics\Applied Econometrics\Projects\P03\taxbill.png", as(png) name("Graph") replace	


*----------4.6: GDP per Capita
use Last, clear
	 

twoway scatter numbill0 gdpcapita if year==2020, mcolor(gs0) || lfit numbill0 gdpcapita if year==2020, lcolor(blue) title("تعداد میلیاردرها بر اساس درآمد سرانه در سال 2020") ///
	xtitle("درآمد سرانه (دلار)")  ytitle("تعداد میلیاردرها")

graph export "E:\Economics\Applied Econometrics\Projects\P03\gdpbill.png", as(png) name("Graph") replace

use gdppercapita , clear

twoway (connected gdpcapita year if country=="United States", msymbol(circle)) ///
 (connected gdpcapita year if country=="Russia", msymbol(diamond)) ///
 (connected gdpcapita year if country=="China", msymbol(square)) ///
 (connected gdpcapita year if country=="United Kingdom", msymbol(T)) ///
 (connected gdpcapita year if country=="France", msymbol(+)) ///
 (connected gdpcapita year if country=="Japan", msymbol(X)) ///
 (connected gdpcapita year if country=="Canada", msymbol(A)) /// 
 (connected gdpcapita year if country=="Germany", msymbol(pipe)) ///
 (connected gdpcapita year if country=="Italy", msymbol(V) ///
title("درآمدسرانه برخی کشورها طی سال های 2010 تا 2022") ///
legend(label(1 "United States") label(2 "Russia") label(3 "China") label(4 "United Kingdom") label(5 "France") label(6 "Japan") label(7 "Canada") label(8 "Germany") label(9 "Italy") ) ///
 ytitle("دلار"))
 
 graph export "E:\Economics\Applied Econometrics\Projects\P03\gdp9C.png", as(png) name("Graph") replace
 
/* End of do-file */
