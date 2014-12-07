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
if pancreatitis1 = 'Alcohol' then diagsimp =  pancreatitis1;
if pancreatitis1 = 'Idiopathic' then diagsimp = pancreatitis1;
if pancreatitis1 = 'Pancreas Divisum' then diagsimp = pancreatitis1;
if pancreatitis1 = 'Familial' then diagsimp = pancreatitis1;
run;
*Summarize two groups;
proc tabulate data = mdat;
label autoislettx = 'Auto-Islet Treatment';
label dur = 'Duration of Disease (years)';
var age bmi dur;
class autoislettx gender diagsimp race;
table age*(N mean min max) BMI*(N mean min max) dur*(N mean min max), autoislettx*Gender;
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
run;




