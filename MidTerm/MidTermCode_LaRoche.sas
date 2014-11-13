proc freq data=class.meld;
tables Dial_Tx;
run;

/*set the minimum value of the three variables to 1*/
data meld;
set class.meld;
/*Remove cases with missing values in the three variables*/
if missing(TBil) or missing(INR) or missing(Scr) then delete;
array x{3} TBil--Scr;
do i=1 to 3;
	if 0 <= x{i} < 1 then x{i}= 1;
	end;
/*Set the max for serum cr. to 4 */
if Scr > 4 then Scr = 4;
/*Set the serum cr to 4 if on chronic dialysis*/
if Dial_Tx = 'Y' then Scr = 4;
run;
/*Check computed variables conform*/
proc univariate data= meld;
var TBil--Scr;
run;

/*Compute Meld score*/
data meld;
set meld;
meld = 10*(0.957*log(Scr) + 0.378*log(Tbil) + 1.12*log(INR) + .643);
run;

proc univariate data=meld;
var meld;
run;

/* set max meld to 40 */
data meld;
set meld;
if meld > 40 then meld = 40;
run;

proc means data= meld mean max min median mean std ;
var meld;
run;

/*Calulate ISS score*/
data ais;
set class.AIS_ISS_Test;
ISS = sum( largest(1,of HeadAIS--ExternalAIS)**2, 
			largest(2, of HeadAIS--ExternalAIS)**2, 
			largest(3, of HeadAIS--ExternalAIS)**2);
if max(of HeadAIS--ExternalAIS)=6 then ISS = 75;
run;

/*Calculate number of body parts injured*/
data ais;
set ais;
array x{6} HeadAIS--ExternalAIS;
array y{6} in1-in6;
do i=1 to 6;
	if x{i} > 0 then y{i} = 1;
	end;
drop i;
numinj = sum(of in1-in6);
if numinj > 4 then over4= 1;
run;
/*get the total number of over 4 cases */
proc print data= ais;
sum over4;
run;
/*can also add up the numij =5 and 6 in the freq table*/
proc freq data = ais;
table numinj;
Run;

/* caluclate the number of only head injury cases*/
data ais;
set ais;
if HeadAIS >0 and missing(FaceAIS) 
	and missing(ThoraxAIS) 
	and missing(AbdAIS) 
	and missing(ExtAIS) 
	and missing(ExternalAIS) then onlyhead = 1;
run;

proc freq data=ais;
table onlyhead;
run;

proc univariate data = ais;
var ISS;
histogram;
run;

