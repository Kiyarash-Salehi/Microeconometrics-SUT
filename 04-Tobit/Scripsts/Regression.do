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
global intermed "E:\Economics\Applied Econometrics\Projects\P05\Intermediates\"
global tables "E:\Economics\Applied Econometrics\Projects\P05\Tables\"
cd "$tables"
/*==================================================
              1: 
==================================================*/
use "$intermed\Final.dta",clear
*----------1.1: Model 1
tobit loghexp loginc logins i.cigar i.A65 i.edulevel [pweight=weight] , ll(0) tech(nr)
outreg2 using regression.doc, replace ctitle(Model 1) label addnote(Notes: Healthcare Expenditures in 1401 is the dependent variable in all Models.) addtext(Province FE, NO)
*----------1.2: Model 2
tobit loghexp loginc logins i.cigar i.A65 i.edulevel hhsize i.urban  [pweight=weight] , ll(0) tech(nr)
outreg2 using regression.doc, append ctitle(Model 2) label addtext(Province FE, NO)
*----------1.3: Model 3
tobit loghexp loginc logins i.cigar i.A65 i.edulevel hhsize i.urban i.Province [pweight=weight] , ll(0) tech(nr)
outreg2 using regression.doc, append ctitle(Model 3) label addtext(Province FE, YES) drop(i.Province)
*----------1.4: Margins
asdoc margins, dydx(*) atmeans drop(i.Province) save(margins.doc) replace
/* End of do-file */