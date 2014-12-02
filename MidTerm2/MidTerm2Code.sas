data tr;
set class.test_pta_reg;
run;

data tf;
set class.test_pta_fu;
run;

data tc;
set class.test_pta_cdr;
run;

proc sort data=tf;
by  px_id px_stat_dt;
run;
*Identify last follow-up;
data ttf;
set tf;
by px_id;
latest = last.px_id;
run;
*remove all other cases;
data ltf;
set ttf;
if latest = 0 then delete;
run;
*Some cases are missing date and status but these are also missing for previous observations in the full data;
*Check for missing identifiers;
proc means data=ltf nmiss;
var px_id;
run;
proc means data=tr nmiss;
var px_id;
run;
*rename vars in Ltf so as not to overwrite vars in tr;
data Ltf;
set ltf;
tx_dtl= tx_dt;
px_stat_dtl= px_stat_dt;
px_statl= px_stat;
drop tx_dt px_stat_dt px_stat latest;
run;

*Sort fu and reg data for merging;
proc sort data = ltf;
by px_id;
run;
proc sort data = tr;
by px_id;
run;
*1:many merge;
data new;
merge tr ltf;
by px_id;
run;
*Find Last follow-up;
data new;
set new;
*find the most recent followup;
lfup = max(px_stat_dt, px_stat_dtl);
format lfup date7.;
*define status based on which was most recent;
if lfup=px_stat_dt then lstat=px_stat;
if lfup=px_stat_dtl then lstat = px_statl;
run;

*limit to only cases with Donor ID;
data new2;
set new;
if px_d_idn = "" then delete;
run;

*Sort by donor_id for merge with CDR data;
proc sort data = new2;
by px_d_idn;
run;
proc sort data = tc;
by dnr_idn;
run;
data all;
merge new2 tc (Rename=(dnr_idn=px_d_idn));
by px_d_idn;
run;
*limit to cases with both donor and px info;
data all2;
set all;
if px_id = . then delete;
run;
*compute donor and recpient age;
data all2;
set all2;
d_age = yrdif(d_dob,referral_dt,'actual');
r_age = yrdif(r_dob,tx_dt,'actual');
run;
*descibe different ages;
proc means data=all2 mean max min std nmiss;
var d_age r_age;
run;
proc univariate data= all2 ;
label d_age = "Donor Age in Years";
label r_age = "Recipient Age in Years";
var d_age r_age;
histogram;
run;
proc ttest data=all2;
var d_age r_age;
run;
*Correlation between recipient and donor age;
proc corr data = all2;
var d_age r_age;
run;

*Calculate time till death;
data all2;
set all2;
*years to last follow-up;
ttlfup = int(yrdif(tx_dt,lfup));
*remove case where last follow-up comes before tx date;
if ttlfup < 0 then delete;
*categorize survival into 1, 2, and 3 years;
if (ttlfup >=1) and (lstat = 'A') then surv1 = 1;
if (ttlfup >=2) and (lstat = 'A') then surv2 = 1;
if (ttlfup >=3) and (lstat = 'A') then surv3 = 1;
*find number of missing follow-ups in each time period;
if (ttlfup =1) and (lstat ne 'A' or lstat ne 'D') then miss1 = 1;
if (ttlfup =2) and (lstat ne 'A' or lstat ne 'D') then miss2 = 1;
if (ttlfup >=3) and (lstat ne 'A' or lstat ne 'D') then miss3 = 1;
run;

*Tabulate by survival years and fup status;
proc tabulate data=all2;
label surv1 = "Survived at least 1 year";
label surv2 = "Survived at least 2 years";
label surv3 = "Survived at least 3 years";
var surv1 surv2 surv3;
table surv1*sum surv2*sum surv3*sum;
run;

proc tabulate data=all2;
label miss1 = "Missing by 1 year";
label miss2 = "Missing by 2 years";
label miss3 = "Missing on or after 3 years";
var miss1 miss2 miss3;
table miss1*sum miss2*sum miss3*sum;
run;












