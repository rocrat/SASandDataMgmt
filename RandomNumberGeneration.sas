data rand;
do i=1 to 100;
	sex=ranbin(0,1,.4);
	if sex = 1 then weight1 = 400 + 30*rannor(0);
	if sex = 1 then	weight2 = 340 + 30*rannor(0);
	if sex = 0 then weight1 = 300 + 20*rannor(0);
	if sex = 0 then weight2 = 220 + 20*rannor(0);
	diff = weight1 - weight2;
	output;
end;
drop i;
run;

proc freq data=rand;
table sex;
run;

proc means data=rand;
var weight1 weight2 diff;
class sex;
run;
