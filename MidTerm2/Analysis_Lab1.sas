proc sort data=f13.Final_r1;
by caseID;
run;

proc sort data=f13.Final_lab;
by caseID;
run;

data f13.lab1;
merge f13.final_lab (in=lab) f13.final_r1 (keep =CAseID init_dt);
by caseID;
if lab;
time=lab_dt - Init_dt;
drop init_dt lab_dt;
run;


proc freq data=f13.lab1;
table measure;
run;

proc print data = f13.lab1 (obs=200);
run;
