option nocenter;
title1 '-- direct SAS data input - BMI data --';
data BMI1;
/* data input of blank separated data  */                                     
input px_id  gender $ age   hgt_cm  wgt_kg ;
Label 	px_id  = 'Patient identifier'
	    age    = 'Patient age'
	    hgt_cm = 'Patient height[cm]'
	    wgt_kg = 'Patient weight [kg]';
/*......... compute BMI..................... */
bmi=wgt_kg/(hgt_cm/100)**2;
datalines;
1	F	54	162	88
2	F	66	163	56
3	M	37	.	89
4	F	58	159	56
5	M	51	193	89
6	M	.	178	.
7	M	63	199	102
8	f	59	154	63
9	M	49	.	88
10	F	39	149	61
;

run;
proc print data=BMI1;
run;
/* import BMI data from csv file */
Data class.BMI2;
INFILE 'C:\Classes\SASandDataMgmt\BMI1.csv' dsd dlm=',' firstobs=2 missover;
input px_id r_age r_gender $ hgt_cm wgt_kg;
run;

data class.BMI2;
set class.BMI2;
bmi= wgt_kg/(hgt_cm/100)**2;
run;

TITLE1 '– Basic Characteristics of BMI data--';
proc means data=class.bmi2 N min median max maxdec=1;
VAR bmi;
class r_gender;
run;
/*  show as box-plots  */
proc sgplot;
vbox bmi/category=r_gender;
run;


