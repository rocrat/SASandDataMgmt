/* Program to extract different measurement */
data Weight;
set f13.lab1;
if index (measure,"Weight") = 0 then delete;
if index (measure,"Pds") > 0 then   value =value /2.2;
if index (measure,"inch") > 0 then  value =value *2.54;

rename value=Weight;
keep caseID time value;
run;
proc freq data=Weight;
table time;
run;
proc sgplot;
Histogram time;
xaxis values=( 0 to 180 by 6);
run;
proc sort data=Weight;
by caseID time;
run;
data Weight0;
set  Weight;
/* Get Baseline  */
if time ne 0 then delete;
rename Weight=Weight0;
drop time;
run;
