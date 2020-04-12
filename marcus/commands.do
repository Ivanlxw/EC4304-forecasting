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

foreach x of varlist *_delta {
    gen `x'_lag = L.`x'
    }
	
tsappend, add(5)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change if time<2571
predict ar2in

forvalues p=1/5{
    local q = `p'+1
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change
    predict ar2`p'
    predict ar2sf`p', stdf
    gen ar2`p'L68 = ar2`p'-0.995*ar2sf`p'
    gen ar2`p'U68 = ar2`p'+0.995*ar2sf`p'
    gen ar2`p'L50 = ar2`p'-0.675*ar2sf`p'
    gen ar2`p'U50 = ar2`p'+0.675*ar2sf`p'
}

egen ar2p2=rowfirst(ar21 ar22 ar23 ar24 ar25) if time>=2571
egen ar2pL68=rowfirst(ar21L68 ar22L68 ar23L68 ar24L68 ar25L68) if time>=2571
egen ar2pU68=rowfirst(ar21U68 ar22U68 ar23U68 ar24U68 ar25U68) if time>=2571
egen ar2pL50=rowfirst(ar21L50 ar22L50 ar23L50 ar24L50 ar25L50) if time>=2571
egen ar2pU50=rowfirst(ar21U50 ar22U50 ar23U50 ar24U50 ar25U50) if time>=2571

tsline adjclose_snp500_change ar2in ar2p2 ar2pL50 ar2pU50 ar2pL68 ar2pU68 if time>=2545, title(adj_close_SnP_%chg 50% 68% fan with AR2 Model) lpattern (solid solid solid longdash longdash shortdash shortdash)
