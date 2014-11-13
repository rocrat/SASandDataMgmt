proc import 
datafile="C:\Classes\SASandDataMgmt\Test_patient.csv"
out=dates replace;
run;

proc freq data=dates;
table ptstatus;
run;

data dates;
set dates;
/*Calculate age at last follow-up*/
age_fu = yrdif(DOB,DT_FU,'AGE');
run;
data dates;
set dates;
/*Calculate age now*/
now = input('07oct13',date7.) ;
if dt_death = . then age_now = yrdif(DOB,now,'AGE');
run;

/*Calculate the age at death*/
data dates;
set dates;
if dt_death ne . then death_age = yrdif(DOB,dt_death,'AGE');
run;

proc means data=dates median min max;
var age_fu age_now death_age;
run;
