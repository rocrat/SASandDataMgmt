data lag;
set class.test_sample_6;
run;
/*Sort the data*/
proc sort data=lag out=first;
by patid;
run;
/*Get the unique patids*/
data first;
set first;
by patid;
if first.patid;
run;
/*292 obervations on unique patient ids*/
/*mark patients with postive test before tx date*/
proc sort data=lag out = byidlab;
by patid lab_dt;
run;

data byidlab;
set byidlab;
by patid;	
retain cc
/*cc defines the number of records per patients */
if first.Patid then do;
cc=0;
end;
cc=cc+1;
if last.patid then output;
keep cc;
run;
 proc freq 
 table cc;
 run;

 /* how many positive before transplant*/
 data cocci_pos;
 set byidlab;
 by patid;
 if lab_dt > tx_dt then delete;
 retain positive;
 if first.patid then positive=0;
 if cocci1=1 then positive=0;
 if last.patid then output;
 keep patid positive;
 run;

 proc freq;
 table positive;
 run;
