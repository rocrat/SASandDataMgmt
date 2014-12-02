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
data Weight4;
set  Weight;
diff=abs(time - 122);
run;
proc sort data=Weight.4;
by caseID diff;
run;
data Weight4;
set  Weight4;
by caseID;
if diff > 9 then delete;
if first.CaseID;
rename Weight=Weigh4;
drop diff time;
run;
proc print;
run;
