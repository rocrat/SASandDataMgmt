/*Problem 1 9-4-14 CPH576D_LaRoche*/
data class.risk;
infile 'C:\Classes\SASandDataMgmt\Risk_data.csv' dsd dlm=',' firstobs=2 missover;
input Case_ID DIAGNOSIS $ los DialAtTx $ LipidDis $ CbV_DS $ PVD $ Neurpthy $ RespProb $ CancrPre $ CBYPASS $ MI $;
run;
/* For each variable included in the CCI score creatre a numeric variable with the appropriate weight*/
data class.risk1;
set class.risk;
if los < 0 then delete;
if MI='Y' then MI_c=2;
	Else if MI='N' then MI_c=0;
if CBYPASS='Y' then CBYPASS_c=1;
	Else if CBYPASS='N' then CBYPASS_c=0;
if DIAGNOSIS='TYPE1_DM' then DIAG_c=1;
	else if DIAGNOSIS='TYPE2_DM' then DIAG_c=0;
if CbV_DS='Y' then CbV_DS_c=1;
	Else if CbV_DS='N' then CbV_DS_c=0;
if PVD='Y' then PVD_c=1;
	else  if PVD='N' then PVD_c=0;
if Neurpthy='Y' then neur_c=1;
	else if Neurpthy='N' then neur_c=0;
if RespProb='Y' then resp_c=1;
	else if RespProb='N' then resp_c=0;
if LipidDis='Y' then lipid_c=2;
	else if LipidDis='N' then lipid_c=0;
if DialAtTx='Y' then dial_c=3;
	else if DialAtTx='N' then dial_c=0;
if CancrPre='Y' then canc_c=3;
	else if CancrPre='N' then canc_c=0;
run;
/*calculate the CCI from the numeric variables just created*/
data class.risk3;
set class.risk1;
CCI= MI_c + CBYPASS_c + DIAG_c + CbV_DS_c + PVD_c + neur_c + resp_c + lipid_c + dial_c + canc_c;
run;
/*Correlate CCI with length of stay*/
proc corr data=class.risk3;
var CCI los;
run;

/*There is a significant correlation with P-value=0.0003/*




