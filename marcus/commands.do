gen dcode = date(date, "DMY")
gen time = dofd(dcode)
format %td time
bcal create sp500, from(time)
drop time
gen time = bofd("sp500", dcode)
tsset time

*first prepare the variables
foreach x of varlist adjclose_* {
	gen `x'_delta = 100*(log(`x') - log(L.`x'))
		} 


label variable adjclose_pharm_delta pharm
label variable adjclose_semicon_delta semicon
label variable adjclose_industrial_delta industrial
label variable adjclose_energy_delta energy
label variable adjclose_financial_delta financial
label variable adjclose_tech_delta tech
label variable adjclose_utilities_delta utilities
label variable adjclose_consumer_delta consumer

*next perform adl regression loops and store estat
foreach x of varlist *_delta {
	local varlabel : variable label `x'
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L.`x' if time>5
	estimates store adl`varlabel'21
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/2).`x' if time>5
	estimates store adl`varlabel'22
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/3).`x' if time>5
	estimates store adl`varlabel'23
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/4).`x' if time>5
	estimates store adl`varlabel'24
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/5).`x' if time>5
	estimates store adl`varlabel'25
		}
*estimates stats ar2 adlpharm21 adlpharm22 adlpharm23 adlpharm24 adlpharm25 adlsemicon21 adlsemicon22 adlsemicon23 adlsemicon24 adlsemicon25 adlindustrial21 adlindustrial22 adlindustrial23 adlindustrial24 adlindustrial25 adlenergy21 adlenergy22 adlenergy23 adlenergy24 adlenergy25 adlfinancial21 adlfinancial22 adlfinancial23 adlfinancial24 adlfinancial25 adltech21 adltech22 adltech23 adltech24 adltech25 adlutilities21 adlutilities22 adlutilities23 adlutilities24 adlutilities25 adlconsumer21 adlconsumer22 adlconsumer23 adlconsumer24 adlconsumer25

ardl adjclose_snp500_change adjclose_pharm_delta adjclose_semicon_delta adjclose_industrial_delta adjclose_energy_delta adjclose_financial_delta adjclose_tech_delta adjclose_utilities_delta adjclose_consumer_delta if tin(), maxlags(5) aic
