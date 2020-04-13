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

reg adjclose_snp500_change L(1/2).adjclose_snp500_change if time<2452
predict ar2in

forvalues p=1/5{
    local q = `p'+1
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change if time<2452
    display e(rmse)
	predict ar2`p' if time>=2452
    predict ar2sf`p', stdf
    gen ar2`p'L68 = ar2`p'-0.995*ar2sf`p'
    gen ar2`p'U68 = ar2`p'+0.995*ar2sf`p'
    gen ar2`p'L50 = ar2`p'-0.675*ar2sf`p'
    gen ar2`p'U50 = ar2`p'+0.675*ar2sf`p'
}

egen ar2p2=rowfirst(ar21 ar22 ar23 ar24 ar25) if time>=2452
egen ar2pL68=rowfirst(ar21L68 ar22L68 ar23L68 ar24L68 ar25L68) if time>=2452
egen ar2pU68=rowfirst(ar21U68 ar22U68 ar23U68 ar24U68 ar25U68) if time>=2452
egen ar2pL50=rowfirst(ar21L50 ar22L50 ar23L50 ar24L50 ar25L50) if time>=2452
egen ar2pU50=rowfirst(ar21U50 ar22U50 ar23U50 ar24U50 ar25U50) if time>=2452

tsline adjclose_snp500_change ar2in ar2p2 ar2pL50 ar2pU50 ar2pL68 ar2pU68 if time>=2422, title(adj_close_SnP_%chg 50% 68% fan with AR2 Model) lpattern (solid solid solid longdash longdash shortdash shortdash)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change L.adjclose_industrial_delta if time<2452
predict adl21in

forvalues p=1/5{
    local q = `p'+1
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change L`p'.adjclose_industrial_delta if time<2452
    display e(rmse)
	predict adl21`p' if time>=2452
    predict adl21sf`p', stdf
    gen adl21`p'L68 = adl21`p'-0.995*adl21sf`p'
    gen adl21`p'U68 = adl21`p'+0.995*adl21sf`p'
    gen adl21`p'L50 = adl21`p'-0.675*adl21sf`p'
    gen adl21`p'U50 = adl21`p'+0.675*adl21sf`p'
}

egen adl21p2=rowfirst(adl211 adl212 adl213 adl214 adl215) if time>=2452
egen adl21pL68=rowfirst(adl211L68 adl212L68 adl213L68 adl214L68 adl215L68) if time>=2452
egen adl21pU68=rowfirst(adl211U68 adl212U68 adl213U68 adl214U68 adl215U68) if time>=2452
egen adl21pL50=rowfirst(adl211L50 adl212L50 adl213L50 adl214L50 adl215L50) if time>=2452
egen adl21pU50=rowfirst(adl211U50 adl212U50 adl213U50 adl214U50 adl215U50) if time>=2452

tsline adjclose_snp500_change adl21in adl21p2 adl21pL50 adl21pU50 adl21pL68 adl21pU68 if time>=2422, title(adj_close_SnP_%chg 50% 68% fan with ADL21 Model) lpattern (solid solid solid longdash longdash shortdash shortdash)

reg adjclose_snp500_change L(1/2).adjclose_snp500_change L.adjclose_semicon_delta L.adjclose_industrial_delta L(1/3).adjclose_energy_delta L(1/5).adjclose_financial_delta L.adjclose_tech_delta L(1/3).adjclose_utilities_delta L(1/2).adjclose_consumer_delta if time<2452
predict combin

forvalues p=1/5{
    local q = `p'+1
    local s = `p'+2
    local u = `p'+4
    qui reg adjclose_snp500_change L(`p'/`q').adjclose_snp500_change L`p'.adjclose_semicon_delta L`p'.adjclose_industrial_delta L(`p'/`s').adjclose_energy_delta L(`p'/`u').adjclose_financial_delta L`p'.adjclose_tech_delta L(`p'/`s').adjclose_utilities_delta L(`p'/`q').adjclose_consumer_delta if time<2452
    display e(rmse)
	predict comb`p' if time>=2452
    predict combsf`p', stdf
    gen comb`p'L68 = comb`p'-0.995*combsf`p'
    gen comb`p'U68 = comb`p'+0.995*combsf`p'
    gen comb`p'L50 = comb`p'-0.675*combsf`p'
    gen comb`p'U50 = comb`p'+0.675*combsf`p'
}

egen combp2=rowfirst(comb1 comb2 comb3 comb4 comb5) if time>=2452
egen combpL68=rowfirst(comb1L68 comb2L68 comb3L68 comb4L68 comb5L68) if time>=2452
egen combpU68=rowfirst(comb1U68 comb2U68 comb3U68 comb4U68 comb5U68) if time>=2452
egen combpL50=rowfirst(comb1L50 comb2L50 comb3L50 comb4L50 comb5L50) if time>=2452
egen combpU50=rowfirst(comb1U50 comb2U50 comb3U50 comb4U50 comb5U50) if time>=2452

tsline adjclose_snp500_change combin combp2 combpL50 combpU50 combpL68 combpU68 if time>=2422, title(adj_close_SnP_%chg 50% 68% fan with COMB Model) lpattern (solid solid solid longdash longdash shortdash shortdash)
