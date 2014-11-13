proc freq data=class.test_sample_3b;
tables diabetes_type r_gender r_race;
run;


data gfr;
set class.test_sample_3b;/*create dummy variables for race and female*/
if (r_gender = 'U' or r_gender = '') then r_gender = .; /*set U or blank to missing in gender*/
if r_gender = . then fem = .;
if r_gender = 'F' then fem = 1;
if r_gender = 'M' then fem = 0; 
if r_race = 'AfrAmeri' then blk = 1;
	else blk = 0;
run;

data egfr;
set gfr;
array cr{4} CR_1M--CR_3Y;
array eg{4} egfr_1M egfr_6M egfr_1Y egfr_3Y;
do i=1 to 4;
	egfr_base = 186*(cr{i}**-1.154)*(r_age**-0.203);
	if (fem = 1 and blk = 1) then eg{i} = egfr_base*1.21*0.742;
	if (fem = 1 and blk = 0) then eg{i} = egfr_base*0.742;
	if (fem = 0 and blk = 1) then eg{i} = egfr_base*1.21;
	if (fem = 0 and blk = 0) then eg{i} = egfr_base;
	end;
drop i egfr_base;
run;

proc univariate data=egfr ;
var egfr;
histogram;
run;
/* ceate ckd stages- care must be taken since the range of egfr is outside the values for ckd stage.  
I will create a stage 0 which indicates healthy kidney function. Also missing values are considered very 
small numbers so I will have to be careful of those*/
data ckd;
set egfr;
if (egfr_1M > 100) then ckdstg = 0;
if (90 le egfr_1M le 100) then ckdstg = 1;
if (60 le egfr_1M lt 90) then ckdstg = 2;
if (30 le egfr_1M lt 60) then ckdstg = 3;
if (15 le egfr_1M lt 30) then ckdstg = 4;
if (0 le egfr_1M lt 15) then ckdstg = 5;
run;

proc freq data=ckd;
tables ckdstg;
run;

data ckd;
set ckd;
array eg{4} egfr_1M -- egfr_3Y;
array kf{4} kfunc_1M kfunc_6M kfunc_1Y kfunc_3Y;
do i=1 to 4;
	
	if (fem = 1) and (1 < eg{i} < 70) then kf{i} = 0;
	if (fem = 1) and (70 < eg{i} >= 70) then kf{i} = 1;
	if (fem = 0) and (1< eg{i} < 68) then kf{i} = 0;
	if (fem = 0) and (68 < eg{i} >= 68) then kf{i} = 1;
end;
drop i;
run;

proc freq data=ckd;
tables kfunc_1M*kfunc_3Y;
run;

data ckd;
set ckd;
array cr{4} CR_1M--CR_3Y;
meas = 0;
do i=1 to 4;
	if cr{i} ne . then meas = meas+1;
end;
drop i;
run;

proc freq data=ckd;
tables meas;
run;

data ckd;
set ckd;
cr_mean = mean(of CR_1M--CR_3Y);
cr_std = std(of CR_1M--CR_3Y);
cr_med = median(of CR_1M--CR_3Y);
cr_min = min(of CR_1M--CR_3Y);
cr_max = max(of CR_1M--CR_3Y);
run;

data ckd1;
set ckd;
if group = 'N Cont' then delete;
run; 


proc ttest data=ckd1;
class group;
var cr_mean;
run;
