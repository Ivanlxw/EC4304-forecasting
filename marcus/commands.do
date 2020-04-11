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

*check granger causality
foreach x of varlist *_delta {
	newey adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/5).`x', lag(5)
	testparm L(1/5).`x'
	}
	
*check seriel correlation with robust errors
foreach x of varlist *_delta {
	reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/5).`x', r
	testparm L(1/5).`x'
	}
	
foreach x of varlist *_delta {
	gen `x'_lag = L.`x'
	}
	
	
reg adjclose_snp500_change L(1/2).adjclose_snp500_change
estimates store ar2

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
estimates stats ar2 adlpharm21 adlpharm22 adlpharm23 adlpharm24 adlpharm25 adlsemicon21 adlsemicon22 adlsemicon23 adlsemicon24 adlsemicon25 adlindustrial21 adlindustrial22 adlindustrial23 adlindustrial24 adlindustrial25 adlenergy21 adlenergy22 adlenergy23 adlenergy24 adlenergy25 adlfinancial21 adlfinancial22 adlfinancial23 adlfinancial24 adlfinancial25 adltech21 adltech22 adltech23 adltech24 adltech25 adlutilities21 adlutilities22 adlutilities23 adlutilities24 adlutilities25 adlconsumer21 adlconsumer22 adlconsumer23 adlconsumer24 adlconsumer25
reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/2).adjclose_pharm_delta L.adjclose_semicon_delta L.adjclose_industrial_delta L(1/3).adjclose_energy_delta L(1/5).adjclose_financial_delta L(1/2).adjclose_tech_delta L(1/3).adjclose_utilities_delta L.adjclose_consumer_delta
combined311135132
ardl adjclose_snp500_change adjclose_semicon_delta_lag adjclose_industrial_delta_lag adjclose_energy_delta_lag adjclose_financial_delta_lag adjclose_tech_delta_lag adjclose_utilities_delta_lag adjclose_consumer_delta_lag, maxcombs(8398080) maxlag(4) aic
combined301135132
ardl adjclose_snp500_change adjclose_pharm_delta_lag adjclose_semicon_delta_lag adjclose_industrial_delta_lag adjclose_energy_delta_lag adjclose_financial_delta_lag adjclose_tech_delta_lag adjclose_utilities_delta_lag adjclose_consumer_delta_lag, maxcombs(8398080) maxlag(4) aic
221135231
