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
version 17
clear all

global P05 "E:\Economics\Applied Econometrics\Projects\P05"

do "$P05\Scripsts\Packages"

/*==================================================
              1: cleaning
==================================================*/
do "$P05\Scripsts\CleaningV2"
/*==================================================
              2: Regression
==================================================*/
do "$P05\Scripsts\Regression"
/*==================================================
              3: Figures and Tables
==================================================*/
*----------3.1:
do "$P05\Scripsts\Figures"

*----------3.2:
do "$P05\Scripsts\Tables"

/* End of do-file */


