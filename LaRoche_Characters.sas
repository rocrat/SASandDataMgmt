data test;
set class.Test_sample_5;
run;

proc freq data=test;
table complication;
run;

data test;
set test;
comp = lowcase(complication);
if index(comp,"hernia") > 0 then hern = 1;
if index(comp,"absess") > 0 or index(comp,"abscess") > 0 or index(comp,"abcess") > 0 then ab = 1;
/*included one case of "peritoneal signs" not sure if this is peritonitis or not*/
if index(comp,"perit") > 0 then peri = 1;
num = sum(of hern--peri);
run; 

proc freq data = test;
table hern ab peri num;
run;
