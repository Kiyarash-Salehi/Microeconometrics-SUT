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
global intermed "E:\Economics\Applied Econometrics\Projects\P05\Intermediates\"
global tables "E:\Economics\Applied Econometrics\Projects\P05\Tables\"
cd "$tables"
/*==================================================
              1: descriptive data
==================================================*/
*----------1.1:
use "$intermed\Final.dta" ,clear
asdoc summ income Thexp A65 insexp cigar hhsize edulevel ,  save(labss.doc) title(Descriptive statistics) replace
*----------1.2:
asdoc proportion urban, save(proportion.doc) replace 
*----------1.3:
asdoc proportion activitystatus, save(proportion2.doc) replace 

/* End of do-file */