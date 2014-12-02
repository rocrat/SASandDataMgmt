/* Program to extract different measurement */
data Height;
set f13.lab1;
if index (measure,"Height") = 0 then delete;
if index (measure,"Pds") > 0 then   value =value /2.2;
if index (measure,"inch") > 0 then  value =value *2.54;

rename value=Height;
keep caseID time value;
run;

proc sgplot data=height;
Histogram height;
xaxis values=( 150 to 220 by 10);
run;
proc sort data=Weight;
by caseID time;
run;
data Height0;
set  Height;
/* Get Baseline  */
if time ne 0 then delete;
rename Height=Height0;
drop time;
run;
