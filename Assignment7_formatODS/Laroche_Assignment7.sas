proc format;
value mnth_fmt
	01 = 'January'
	02 = 'February'
	03 = 'March'
	04 = 'April'
	05 = 'May'
	06 = 'June'
	07 = 'July'
	08 = 'August'
	09 = 'September'
	10 = 'October'
	11 = 'November'
	12 = 'December';
value day_fmt
	1='Sunday'
	2='Monday'
	3='Tuesday'
	4='Wednesday'
	5='Thursday'
	6='Friday'
	7='Saturday';
value wait_fmt
	999 ='Unknown';
value lov_fmt
	9999='Unknown';
value by_fmt
	0 = 'Blank'
	1 = 'Yes'
	2 = 'No'
	3 = 'Unknown';
value sex_fmt
	1 = 'Female'
	2 = 'Male';
value eth_fmt
	0 = 'Blank'
	1 = 'Hispanic or Latino'
	2 = 'Not Hispanic or Latino';
value arrive_fmt
	0 = 'Blank'
	1 = 'Ambulance'
	2 ='Public service'
    3 ='Walk-in'
    4 ='Unknown';
value race_fmt
	1 ='White only'
	2 ='Black/African American only'
	3 ='Asian only'
	4 ='Native Hawaiian/Oth Pac Isl only'
	5 ='American Indian/Alaska Native only'
	6 ='More than one race reported';
value pay_fmt
	0 ='Blank'
	1 ='Private insurance'
	2 ='Medicare'
	3 ='Medicaid'
	4 ="Worker's compensation"
	5 ='Self-pay'
	6 ='No charge'
	7 ='Other'
	8 ='Unknown';
value pain_fmt
	0 ='No box is marked' 
	1 ='Unknown'
	2 ='None'
	3 ='Mild'
	4 ='Moderate'
	5 ='Severe';
value atime_fmt
	9999 = ''
	1800 - < 2400 = '6pm to midnight'
	0000 - < 600 = 'midnight to 6am'
	600 - < 1200 = '6am to midnight'
	1200 - < 1800 = 'noon to 6pm';
run;

data er;
set class.test_er;
label vmonth = 'Month of Visit'
	VYEAR ='Year of Visit' 
	vdayr = 'Day of Week of Visit - recoded'
	age = 'Patient age in years'
	arrtime = 'Arrival time (military time)'
	waittime = 'Waiting time to see physician (minutes)'
	lov = 'Length of visit (minutes)'
	reside = 'Does patient reside in nursing home?'
	sex = 'Patient Sex'
	ethnic = 'Patient Ethnicity'
	arrive = 'Mode of Arrival'
	race = 'Patient Race'
	paytype = 'Expected source of payment for this visit'
	tempf = 'Initial temperature (F)'
	pulse = 'Pulse (beats/min)'
	pain = 'Pain at admission';
format vmonth mnth_fmt.
	vdayr day_fmt.
	waittime wait_fmt.
	lov lov_fmt.
	reside by_fmt.
	sex sex_fmt.
	ethnic eth_fmt.
	arrive arrive_fmt.
	race race_fmt.
	paytype pay_fmt.
	pain pain_fmt.;
run;

data er;
set er;
if vyear ne 2004 then delete; 
if vmonth in(1, 2, 3) then quarter = 1;
if vmonth in(4, 5, 6) then quarter = 2;
if vmonth in(7, 8, 9) then quarter = 3;
if vmonth in(10, 11, 12) then quarter = 4;
run;

proc freq data = er;
table vmonth quarter /nocum chisq;
run;
proc freq data = er;
table  vdayr/ nocum chisq;
run;

proc sgplot data = er;
vbar vmonth ;
run;
proc sgplot data = er;
vbar quarter;
run;
/* there does not appear to be a difference in visits by month or quarter*/

proc sgplot data = er;
vbar vdayr;
run;

/* check distribution of waiting times */
proc univariate data =er;
var waittime;
histogram;
run;
/* Strong right skew so make new transformed variable */
data er;
set er;
/*change arrival time to numeric*/
arr2 = input(arrtime,4.);
/*set up 10-6 variable*/
ten_to_six = 0;
if waittime ne 999 then lwait = log(waittime+1);
if paytype in(2,3) then medic = 1;
if paytype in(1,4,5,6,7) then medic = 0; 
if (2159 < arr2 <= 2400)or(0 <= arr2 < 601) then ten_to_six = 1;
run;

/*Check transformation*/
proc univariate data =er;
var lwait;
histogram;
run;
/*Looks OK but not perfect*/
proc ttest data =er;
var lwait;
class sex;
run;
/* QQplots not great but we can rely on CLT for test validity*/
proc format;
value race2_fmt
	1 = 'White'
	2-6 = 'Non-White';
run;
/*Test white vs Non-white*/
proc ttest data =er;
label lwait = 'Log Waiting Time';
label race = 'White vs Non-White';
format race race2_fmt.;
var lwait;
class race;
run;

proc format;
value paytype2_fmt
	0 - 1 = 'Other'
	2 - 3 = 'Medicare/Medicaid'
	4 - 7 = 'Other';
run;

data ernew;
set er;
if paytype = 8 then delete;
run;
/*Test medicare/medicaid vs other */
proc ttest data =ernew;
label lwait = 'Log Waiting Time';
label paytype = 'Medicare/Medicare vs Other Pay Types';
format paytype paytype2_fmt.;
var lwait;
class paytype;
run; 

proc format;
value atime2_fmt
	600 - <2200 = 'Other Times'
	2200 - 2400 = '10pm to 6am'
	0 - <600 = '10pm to 6am'
	9999 = 'Missing';
run;

proc freq data = er;
label arr2 = '10pm to 6am';
format arr2 atime2_fmt.;
table arr2;
run;

/*Use format included above for continuous arrival time variable*/
proc freq data=er;
label arr2 = 'Arrival Time';
format arr2  atime_fmt.;
table arr2*arrive;
run;

proc univariate data=er;
var pain;
histogram;
run;

proc sgplot data=er;
vbar pain;
run;

proc format;
value atime3_fmt
	600 - <1800 = 'Day'
	1800 - 2400 = 'Night'
	0 - <600 = 'Night'
	9999 = '';
run;
/*Remove missing arrival time records for Wilcoxon test*/
data erpain;
set er;
if arr2 = 9999 then delete;
run;

/*Since the pain variable is ordinal I will use a wilcoxon test for the difference*/
proc npar1way wilcoxon data=erpain;
where pain > 1;
label arr2 = 'Night vs Day';
label pain = 'Reported Pain';
format arr2 atime3_fmt.;
class arr2;
var pain;
run;


/*Distribution of temperature for patients entering ER*/
proc univariate data = er;
var tempf;
histogram;
run;

/*Outlier needs to be removed and temp needs to be divided by 10*/
data er;
set er;
/*set 0 to missing and remove outlier*/
if tempf > 100 then newtemp = tempf/10;
run;

proc univariate data = er;
label newtemp = 'Patient Temperatures';
var newtemp;
histogram;
run;


proc means data = er;
format race race2_fmt.;
where waittime ne 999;
var  waittime;
class race;
run;

proc means data = er;
where waittime ne 999;
var  waittime;
class sex;
run;

proc means data =ernew;
where waittime ne 999;
label lwait = 'Log Waiting Time';
label paytype = 'Medicare/Medicare vs Other Pay Types';
format paytype paytype2_fmt.;
var waittime;
class paytype;
run; 
