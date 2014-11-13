/*set everything to lowercase to avoid case problems*/
data liver;
set class.Liver_cmp;
Med_cmp = lowcase(Med_cmp);
run;

proc freq data=liver;
table Med_cmp;
run;

/*find anitsocial behavior cases*/
data liver;
set liver;
antisocial = 'N';
if index( then  antisocial = 'Y';
run;

proc freq data=liver;
table antisocial;
run;



