*read in patient data;
Data pat;
set final.patient;
run;

data diag;
set final.diagnosis;
run;

data surg;
set final.surgery;
run;

data isl;
set final.islets;
run;

data sf;
set final.sf36;
run;

data amd;
set final.readmin;
run;

*data clean-up;
proc freq data = pat;
table _character_;
run;

proc means data= pat nmiss min max mean;
var _numeric_;
run;

proc freq data = diag;
table _character_;
run;
proc means data= diag nmiss min max mean;
var _numeric_;
run;
*change unable to confirm to unknown;
data diag;
set diag;
if Pancreatitis1 = 'Unable to confirm' then Pancreatitis1 = 'Unknown';
*change 9999 to missing;
if Pancreatitis_yr = 9999 then Pancreatitis_yr = .;
run;
*remove duplicates;
proc sort data=diag;
by PatID;
run;
data diag;
set diag;
by patid;
if first.PatID;
run;

proc means data= isl nmiss min max mean;
var _numeric_;
run;
proc univariate data=isl plot trimmed=(0.05);
var ieq;
run;
*negative value and 1 very high outlier;
data isl;
set isl;
ieqout = 0;
if PatID < 1 then delete;
if ieq > 3000000 then ieq = .;
if ieq > 750000 then ieqout = 1;
run;
*there are still a couple outliers, I labelled them with indicator;
proc sort data=isl;
by patid;
run;
data isl;
set isl;
by patid;
if first.PatID;
run;

proc freq data = surg;
table _character_;
run;
proc means data= surg nmiss min max mean;
var _numeric_;
run;
proc univariate data=surg plot trimmed=0.05;
var ht_pre wt_pre;
histogram;
run;
*a couple high wieght outliers and one low hieght outlier;
*check bivariate outliers;
proc sgplot data=surg;
scatter x=ht_pre y=wt_pre;
run;
*thought I would see a tighter relationship there!;
* I don't think there are any observations extreme enough to merit removal;


proc freq data = amd;
table _character_;
run;
proc means data= amd nmiss min max mean;
var _numeric_;
run;
*consolodate admission reasons;
data amd;
set amd;
if Admission_reason1 = 'Gastrointestinal bleeding' then Admission_reason1 = 'GI Bleeding';
if Admission_reason1 = 'Hypoglyxemia' then Admission_reason1 = 'Hypoglycemia';
if Admission_reason1 = 'Incisonal hernia' then Admission_reason1 = 'Incisional hernia';
if Admission_reason1 = 'Nausea&Vomiting' or Admission_reason1 = 'Vomiting' then Admission_reason1 = 'Nausea/Vomiting';
if Admission_reason1 = 'Pain' then Admission_reason1 = 'Abdominal Pain';*not sure if this is right - I would check with PI;
run;

proc means data= sf nmiss min max mean;
var _numeric_;
run;

*merge data;
proc sort data = pat;
by patid;
run;
proc sort data = diag;
by patid;
run;
data mdat;
merge pat diag;
by patid;
run;

proc sort data=mdat;
by patid;
run;
proc sort data=surg;
by patid;
run;
data mdat;
merge mdat surg;
by patid;
run;

proc sort data=mdat;
by patid;
run;
proc sort data=isl;
by patid;
run;
data mdat;
merge mdat isl;
by patid;
run;

* amd and sf have multiple obs per pat;

*number of pts with panx and also with isl?;
proc freq data=mdat;
table autoislettx;
run;
*92 pts received surgery and 63 also rcvd isl;

*calculate duration of the disease from diag date and surgery date;
data mdat;
set mdat;
dur = year(surgery_dt)-pancreatitis_yr;
*classify as white or other;
race = '';
if (white = 1) and (hispanic ne 1) then race = 'White,Non-hispanic';
if (white = 0) then race = 'Other';
*calculate BMI;
bmi = wt_pre/(ht_pre**2);
*simplify diagnosis;
diagsimp= '';
if pancreatitis1 ne '' then diagsimp = 'Other';
if pancreatitis1 = 'Alcohol' then diagsimp =  'Alcohol';
if pancreatitis1 = 'Idiopathic' then diagsimp = 'Idiopathic';
if pancreatitis1 = 'Pancreas Divisum' then diagsimp = 'Pancreas Divisum';
if pancreatitis1 = 'Familial' then diagsimp = 'Familial';
run;
*Summarize two groups;
proc tabulate data = mdat;
label autoislettx = 'Auto-Islet Treatment';
label dur = 'Duration of Disease (years)';
var age bmi dur;
class autoislettx gender diagsimp race;
table age*(N mean min max) BMI*(N mean min max) dur*(N mean min max) Gender*N, autoislettx;
run;

proc tabulate data = mdat;
label autoislettx = 'Auto-Islet Treatment';
label diagsimp = 'Diagnosis Category';
class autoislettx diagsimp;
table diagsimp*N, autoislettx;
run;

*Thanks for this code!;
data sfz;
set sf;
/*Standardize */
   PF_Z = (PF - 84.52404) / 22.89490 ;
   RP_Z = (RP  - 81.19907) / 33.79729 ;
   BP_Z = (BP  - 75.49196) / 23.55879 ;
   GH_Z = (GH  - 72.21316) / 20.16964 ;
   MH_Z = (MH  - 74.84212) / 18.01189 ;
   RE_Z = (RE  - 81.29467) / 33.02717 ;
   SF_Z = (SF  - 83.59753) / 22.37642 ;
   VT_Z = (VT  - 61.05453) / 20.86942 ;
/*create physical and mental health component score */
   PCS = (PF_Z * 0.42402) + (RP_Z * 0.35119) + (BP_Z * 0.31754) +
         (GH_Z * 0.24954) + (MH_Z * -.22069) + (RE_Z * -.19206) +
         (SF_Z * -.00753) + (VT_Z * 0.02877);
   MCS = (PF_Z * -.22999) + (RP_Z * -.12329) + (BP_Z * -.09731) +
         (GH_Z * -.01571) + (MH_Z * 0.48581) + (RE_Z * 0.43407) +
         (SF_Z * 0.26876) + (VT_Z * 0.23534);

/* create the score */
   PCS = 50 + (PCS * 10);
   MCS = 50 + (MCS * 10);
drop pf--rp_z;
drop gh_z--vt_z;
run;

*create separate data for each visit to retain ptid date, BP_Z, MCS and PCS;
proc sort data=sfz;
by patid;
run;
proc sort data = mdat;
by patid;
run;

*merge into long form;
data longm;
merge mdat sfz;
by patid;
run;

*calculate months since surgery;
data longm;
set longm;
month_since = round( (fu_dt-surgery_dt)/30.5,1);
run;

proc sort data =longm;
by month_since;
run;
proc boxplot data = longm;
label month_since = 'Months since surgery';
label BP_Z = 'Bodily Pain';
where month_since in(0,3,6);
plot BP_Z*month_since;
run;
proc boxplot data = longm;
label month_since = 'Months since surgery';
label mcs = 'Mental Component Score';
where month_since in(0,3,6);
plot mcs*month_since;
run;
proc boxplot data = longm;
label month_since = 'Months since surgery';
label pcs = 'Physical Component Score';
where month_since in(0,3,6);
plot pcs*month_since;
run;
*this trend doesn't look so convincing when you look at all time points

*relationship between ieq and dur or bmi;
proc glm data= mdat;
model ieq = dur bmi ;
run;
*no significant relationship try without outliers;
proc glm data= mdat;
where ieqout = 0;
model ieq = dur bmi ;
run;
*after removing outlying ieq values there is a relationship with BMI;
proc sgplot data = mdat;
label ieq = 'Islet Gain';
label bmi = 'Body Mass Index';
where ieqout = 0;
reg x=bmi y=ieq/ CLM
CLMATTRS=(CLMLINEATTRS= 
   (COLOR=Green PATTERN= ShortDash));
run;
proc sgplot data = mdat;
label ieq = 'Islet Gain';
label dur = 'Duration';
where ieqout = 0;
reg x=dur y=ieq / CLM
CLMATTRS=(CLMLINEATTRS= 
   (COLOR=Green PATTERN= ShortDash)); 
run;

*Test for difference in bodily pain between baseline and 6 months;
data longm;
set longm;
if month_since = 0 then tmp = 'Baseline';
if month_since = 6 then tmp = '6 Months';
run;

proc ttest data= longm;
class tmp;
var BP_Z;
run;
*normality is slightly suspect so check with rank-sum test;
proc npar1way wilcoxon correct=no data=longm;
class tmp;
var BP_Z;
run;
*even more significant;

*readmission rates for the two groups overall, at 1 month and 6months;
*merge mdat and readmit data;
proc sort data=mdat;
by patid;
run;
proc sort data=amd;
by patid;
run;
data ldat2;
merge mdat amd;
by patid;
run;

data ldat2;
set ldat2;
day_since = readm_dt-surgery_dt;
month_since = (day_since)/30.5;
run;

*limit ti just cases with a surgery;
data ldat2;
set ldat2;
if surgery_dt = . then delete;
*remove admission dates before surgery;
if (read_dt ne .) and (readm_dt < surgery_dt) then delete;
run;

*check for any recurrenc by limiting to first recurence;
proc sort data =ldat2;
by patid readm_dt;
run;
data ldat2_first;
set ldat2;
if first.patid;
by patid;
run;

data ldat2_first;
set ldat2_first;
if readm_dt ne . then read = 'Yes';
if readm_dt = . then read = 'No';
run;

proc tabulate data = ldat2_first;
label autoislettx = 'Auto-Islet Status';
label read = 'Readmission Status';
class read autoislettx;
table read, autoislettx*N;
run;

*limit to only readmited patients to compare ER and overall beteen the two groups;
data ldat2_ronly;
set ldat2;
if readm_dt = . then delete;
run;
*limit to only cases where readmits happen in first month;
proc sort data= ldat2_ronly;
by patid;
run;
data ldat2_1month;
set ldat2_ronly;
if month_since > 1 then delete;
*eliminate repeated visits in the first month;
if first.patid;
by patid;
run;

proc format;
value er_fmt
	0 = 'No'
	1 = 'Yes';
run;


proc tabulate data = ldat2_1month;
label autoislettx = 'Auto-Islet Status';
format er er_fmt.;
class er autoislettx;
table er, autoislettx;
run;

*limit to readmits to before 6 months;
data ldat2_6month;
set ldat2_ronly;
if month_since > 6 then delete;
*eliminate repeated visits in the first month;
if first.patid;
by patid;
run;

proc tabulate data = ldat2_6month;
label autoislettx = 'Auto-Islet Status';
format er er_fmt.;
class er autoislettx;
table er, autoislettx;
run;
