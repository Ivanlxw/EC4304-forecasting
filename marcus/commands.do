cd "C:\Users\maple\Documents\GitHub\EC4304-forecasting\marcus"
import delimited C:\Users\maple\Documents\GitHub\EC4304-forecasting\marcus\data\output.csv

gen dcode = date(date, "DMY")
gen time = dofd(dcode)
format %td time
bcal create sp500, from(time) replace
drop time
gen time = bofd("sp500", dcode)
tsset time

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
rename adjclose_snp500_delta adjclose_snp500_change

qui reg adjclose_snp500_change L.adjclose_snp500_change if time>5
estimates store ar1
qui reg adjclose_snp500_change L(1/2).adjclose_snp500_change if time>5
estimates store ar2
qui reg adjclose_snp500_change L(1/3).adjclose_snp500_change if time>5
estimates store ar3
qui reg adjclose_snp500_change L(1/4).adjclose_snp500_change if time>5
estimates store ar4
arima adjclose_snp500_change if time>5, ma(1)
estimates store ma1
arima adjclose_snp500_change if time>5, ma(2)
estimates store ma2
arima adjclose_snp500_change if time>5, ma(3)
estimates store ma3
qui arima adjclose_snp500_change if time>5, arima(2,0,1)
estimates store arma21
estimates stats ar1 ar2 ar3 ar4 ma1 ma2 ma3 arma21

foreach x of varlist *_delta {
    newey adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/5).`x', lag(10)
    testparm L(1/5).`x'
    }

foreach x of varlist *_delta {
    corrgram `x'
    }

foreach x of varlist *_delta {
    reg adjclose_snp500_change L(1/2).adjclose_snp500_change L(1/5).`x', r
    testparm L(1/5).`x'
    }

reg adjclose_snp500_change L(1/2).adjclose_snp500_change if time>5
estimates store ar2
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

foreach x of varlist *_delta {
    gen `x'_lag = L.`x'
    }
	

ardl adjclose_snp500_change adjclose_pharm_delta_lag adjclose_semicon_delta_lag adjclose_industrial_delta_lag adjclose_energy_delta_lag adjclose_financial_delta_lag adjclose_tech_delta_lag adjclose_utilities_delta_lag adjclose_consumer_delta_lag, maxcombs(8398080) lag(2 . . . . . . . .) maxlag(4) aic

ardl adjclose_snp500_change adjclose_semicon_delta_lag adjclose_industrial_delta_lag adjclose_energy_delta_lag adjclose_financial_delta_lag adjclose_tech_delta_lag adjclose_utilities_delta_lag adjclose_consumer_delta_lag, maxcombs(8398080) lag(2 . . . . . . .) maxlag(4) aic

tsappend, add(5)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change if time<2388
predict ar2in

forvalues p=1/5{
    local q = `p'+1
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change if time<2388
	predict ar2`p' if time>=2388
    predict ar2sf`p', stdf
}

egen ar2p2=rowfirst(ar21 ar22 ar23 ar24 ar25) if time>=2388

tsline adjclose_snp500_change ar2in ar2p2  if time>=2388, title(adj_close_SnP_%chg with AR2 Model) lpattern (solid solid solid longdash longdash shortdash shortdash)
tsline adjclose_snp500_change ar2in ar2p2  if time>=2540, title(adj_close_SnP_%chg with AR2 Model zoom) lpattern (solid solid solid longdash longdash shortdash shortdash)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change L.adjclose_industrial_delta if time<2388
predict adl21in

forvalues p=1/5{
    local q = `p'+1
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change L`p'.adjclose_industrial_delta if time<2388
	predict adl21`p' if time>=2388
    predict adl21sf`p', stdf
}

egen adl21p2=rowfirst(adl211 adl212 adl213 adl214 adl215) if time>=2388

tsline adjclose_snp500_change adl21in adl21p2 if time>=2388, title(adj_close_SnP_%chg with ADL21 Model) lpattern (solid solid solid longdash longdash shortdash shortdash)
tsline adjclose_snp500_change adl21in adl21p2 if time>=2540, title(adj_close_SnP_%chg with ADL21 Model zoom) lpattern (solid solid solid longdash longdash shortdash shortdash)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change L.adjclose_semicon_delta L.adjclose_industrial_delta L(1/3).adjclose_energy_delta L(1/5).adjclose_financial_delta L.adjclose_tech_delta L(1/3).adjclose_utilities_delta L(1/2).adjclose_consumer_delta if time<2388
predict combin

forvalues p=1/5{
    local q = `p'+1
    local s = `p'+2
    local u = `p'+4
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change L`p'.adjclose_semicon_delta L`p'.adjclose_industrial_delta L(`p'/`s').adjclose_energy_delta L(`p'/`u').adjclose_financial_delta L`p'.adjclose_tech_delta L(`p'/`s').adjclose_utilities_delta L(`p'/`q').adjclose_consumer_delta if time<2388
	predict comb`p' if time>=2388
    predict combsf`p', stdf
}

egen combp2=rowfirst(comb1 comb2 comb3 comb4 comb5) if time>=2388

tsline adjclose_snp500_change combin combp2 if time>=2388, title(adj_close_SnP_%chg with COMB Model) lpattern (solid solid solid longdash longdash shortdash shortdash)
tsline adjclose_snp500_change combin combp2 if time>=2540, title(adj_close_SnP_%chg with COMB Model zoom) lpattern (solid solid solid longdash longdash shortdash shortdash)
