data ret;
set class.test_trauma;
run;
/*2)-4) separating out the score from the text */
data ret;
set ret;
AIS_score= .;
if AIS ne "" then AIS_score = substr(AIS,1,6);
if AIS ne "" then AIS_txt = substrn(AIS,8);
drop AIS;
run;

data retc;
set ret;
retain xmrn xage xsex xrace xiss;
if AIS_score = . then delete;
/*Create retained variables*/
if age ne . then do;
	xmrn = mrn;
	xage = age;
	xsex = sex;
	xrace = race;
	xiss = iss;
	end;
/*Fill in missing information from retained variables*/
if mrn = . then mrn = xmrn;
if age = . then age = xage;
if sex = "" then sex = xsex;
if race = "" then race = xrace;
if iss = . then iss = xiss;
drop xmrn xage xsex xrace xiss;
run;

/*need to use only the first value of iss to avoid excess density at multiple obs*/
data retfirst;
set retc;
by mrn;
if first.mrn;
run;


proc univariate data = retfirst;
var iss;
histogram;
run;

proc univariate data = retc;
var ais_score;
histogram;
run;

/*For the sgplot we must also use the first record data set*/
proc sgplot data = retfirst;
scatter x=age y=iss;
run;
