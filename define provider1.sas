data provider;
set  my.provider;
length ProviderName $ 15.;

provider=upcase(provider);
/* Provider Name  only blank and comma are valid separators*/
ProviderName =scan(provider,1," ,");
ProviderType =scan(provider,2," ,");
/*...............................................................*/
if ProviderType="DO" then ProviderType="MD";
if ProviderType="MD, MPH" then ProviderType="MD";
if substr(ProviderType,1,2)="PA" then ProviderTYpe="PA";
if index(ProviderType,"NP") > 0 then Providertype="NP";
if index (ProviderTYpe ,'Un') > 0  then ProviderType='Unknown';
/*...............................................................*/
run;
proc freq;
table ProviderName ProviderType;
run;
