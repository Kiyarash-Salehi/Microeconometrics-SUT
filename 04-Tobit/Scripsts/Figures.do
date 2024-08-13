/*==================================================
project:       
Author:        Kiyarash Salehi 
E-email:       Kiyarashsalehi79@gmail.com
Student ID:  402205873
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
set scheme white_tableau   
graph set window fontface "XB Niloofar"
global intermed "E:\Economics\Applied Econometrics\Projects\P05\Intermediates\"
global raw "E:\Economics\Applied Econometrics\Projects\P05\Raw\"
global figure "E:\Economics\Applied Econometrics\Projects\P05\Figures\"
cd "$intermed"
/*==================================================
              1: Graphs
==================================================*/
*----------1.1: Bimap
use "$intermed\cigarhealthmap",clear
label var cigar "متوسط خانوارهای سیگاری"
label var Thexp "متوسط هزینه های خدمات درمانی'"
bimap Thexp cigar using iran_map_shp, cut(pctile) palette(bluered) percent values title("رابطه‌ی متوسط هزینه خدمات درمانی و متوسط خانوارهای سیگاری به تفکیک استان در سال 1401", size(3.5)) textx("متوسط خانوارهای سیگاری") texty("متوسط هزینه های درمانی")  textlabs(1.5) texts(3.5)
graph export "$figure\bimap.png", as(png) name("Graph") replace
*----------1.2: line map
use "$intermed\healthexpend" , clear
twoway (line Thealthexp year), title("مجموع هزینه‌های سالیانه روی خدمات درمانی در کل کشور طی سال‌های 1392 تا 1401", size(3)) ytitle("مجموع هزینه های درمانی (ریال)") xtitle("سال")
graph export "$figure\healthexpenditure.png", as(png) name("Graph") replace
*----------1.3: boxplot health care expenditure over education level 
use "$intermed\graphss", clear
graph hbox Thexp, nooutsides over(edulevel) asyvars title("نمودار جعبه‌ای هزینه‌های درمانی به تفکیک سطح تحصیلات سرپرست") ytitle("هزینه های درمانی (ریال)") note("")
graph export "$figure\boxtexpedu.png", as(png) name("Graph") replace 
*----------1.4: boxplot health care expenditure over Householdheads Gender 
graph hbox Thexp, nooutsides over(headgender) asyvars title("نمودار جعبه‌ای هزینه‌های درمانی به تفکیک جنسیت سرپرست") ytitle("هزینه های درمانی (ریال)") note("")
graph export "$figure\boxtexpgender.png", as(png) name("Graph") replace
*----------1.5: boxplot health care expenditure over Householdheads Gender and Education level
graph hbox Thexp, nooutsides over(headgender) over(edulevel) asyvars title("نمودار جعبه‌ای هزینه‌های درمانی به تفکیک جنسیت سرپرست و سطح تحصیلات سرپرست", size(3.5)) ytitle("هزینه های درمانی (ریال)") note("")
graph export "$figure\boxtexpedugen.png", as(png) name("Graph") replace
*----------1.6: boxplot health care expenditure over Urban and Rural Households 
graph hbox Thexp, nooutsides over(urban) title("نمودار جعبه‌ای هزینه‌های درمانی به تفکیک شهر و روستا") ytitle("هزینه های درمانی (ریال)") asyvars note("")
graph export "$figure\boxgenderurb.png", as(png) name("Graph") replace
*----------1.7: bar graph health care expenditure over Age
graph hbar Thexp [pweight=weight], over(A65) title("میانگین هزینه‌های درمانی به تفکیک خانوارهای با عضو بالای 65 سال و بدون عضو بالای 65 سال", size(3)) ytitle("میانگین هزینه‌های درمانی(ریال)") bar(1, bcolor(navy))
graph export "$figure\barage.png", as(png) name("Graph") replace
*----------1.8: bar graph health care expenditure over Cigar
graph hbar Thexp [pweight=weight], over(cigar) title("میانگین هزینه‌های درمانی به تفکیک خانوارهای با هزینه دخانی و بدون هزینه دخانی", size(3)) ytitle("میانگین هزینه‌های درمانی(ریال)") bar(1, bcolor(navy))
graph export "$figure\barcigar.png", as(png) name("Graph") replace
*----------1.9: Pie Chart over Education level
graph pie [pweight=weight], over(edulevel) title("درصد سطح تحصیلات سرپرستان خانوار") plabel(_all percent)
graph export "$figure\pieedul.png", as(png) name("Graph") replace
*----------1.10: boxplot health care expenditure over income quantiles
graph hbox Thexp, nooutsides over(incomeq10)  asyvars note("") title("نمودار جعبه‌ای هزینه‌های درمانی به تفکیک دهک‌های درآمدی") ytitle("هزینه های درمانی (ریال)")
graph export "$figure\boxincome.png", as(png) name("Graph") replace
*----------1.11: boxplot Insurance expenditure over income quantiles
graph hbox insexp, nooutsides over(incomeq10)  asyvars note("") title("نمودار جعبه‌ای هزینه‌ روی بیمه‌ به تفکیک دهک‌های درآمدی") ytitle("هزینه روی بیمه (ریال)")
graph export "$figure\boxinsinc.png", as(png) name("Graph") replace
/* End of do-file */