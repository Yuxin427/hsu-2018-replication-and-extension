*******************************************************
* Replication + Extension Master Do-File
* Paper: Hsu, Matsa, Melzer (AER 2018)
* Tasks: Replicate Figure 1, Table 3, Table 4; add extension
* IMPORTANT: Commands are kept unchanged; only comments are rewritten in English.
*******************************************************

*******************************************************
* SECTION 0. Packages and map data (Figure 1 only)
*******************************************************

*** Figure 1 prerequisites
ssc install maptile, replace
ssc install spmap, replace
maptile_install using "http://files.michaelstepner.com/geo_state.zip" // download US state shapefile for maptile


*******************************************************
* SECTION 1. FIGURE 1: Mapping UI max benefit changes (1991 vs 2010)
*******************************************************

* Setup
clear all
set more off

* Load data
use "C:\Users\Willi\Downloads\116160-V1\ui_econ_analysis.dta", clear

* Data processing:
* - Use the original string variable "state" (two-letter abbreviation), which matches the map geometry
* - Keep only 1991 and 2010
keep if year == 1991 | year == 2010

* Keep only required variables (keep "state" as string ID for mapping)
keep state year max_ben

* Reshape to wide format: one row per state with max_ben1991 and max_ben2010
reshape wide max_ben, i(state) j(year)

* Compute change from 1991 to 2010
gen change_91_10 = max_ben2010 - max_ben1991


*******************************************************
* Plotting maps
*******************************************************

* (1) Replicate Figure 1: Change (1991–2010), quantiles
maptile change_91_10, geo(state) nq(5) ///
twopt(title("Replication of Figure 1: UI Benefit Increases (1991-2010)") ///
subtitle("Quantile Map")) ///
savegraph("Figure1_Replication.png") replace

* (2) Extension map: Level in 1991, quantiles
maptile max_ben1991, geo(state) nq(5) ///
twopt(title("Extension: Max UI Benefit Level in 1991") ///
subtitle("Quantile Map")) ///
savegraph("Figure_Level_1991.png") replace

* (3) Extension map: Level in 2010, quantiles
maptile max_ben2010, geo(state) nq(5) ///
twopt(title("Extension: Max UI Benefit Level in 2010") ///
subtitle("Quantile Map")) ///
savegraph("Figure_Level_2010.png") replace


*******************************************************
* Step 4: Statistical analysis for the homework questions
* (Correlation and homogeneity / convergence)
*******************************************************

* Q1: Correlation between initial level (1991) and change (1991–2010)
display "--------------------------------------------------------"
display "Question 1: Correlation between initial level (1991) and increase (1991-2010)"
pwcorr max_ben1991 change_91_10, sig

scatter change_91_10 max_ben1991 || lfit change_91_10 max_ben1991, ///
title("Correlation between Initial Level and Increase") ///
ytitle("Increase in Max Benefit (1991-2010)") ///
xtitle("Max Benefit Level in 1991")

graph export "Correlation_Plot.png", replace
display "--------------------------------------------------------"

* Q2: Compare dispersion across states in 1991 vs 2010 using SD and coefficient of variation (CV)
display "--------------------------------------------------------"
display "Question 2: Dispersion comparison (1991 vs 2010)"

summarize max_ben1991, detail
scalar sd_1991 = r(sd)
scalar cv_1991 = r(sd) / r(mean)

summarize max_ben2010, detail
scalar sd_2010 = r(sd)
scalar cv_2010 = r(sd) / r(mean)

display "1991 Standard Deviation: " sd_1991
display "2010 Standard Deviation: " sd_2010
display "--------------------------------"
display "1991 Coeff. of Variation: " cv_1991
display "2010 Coeff. of Variation: " cv_2010

if cv_2010 < cv_1991 {
display "Conclusion: CV decreased -> benefit levels became more homogeneous across states."
}
else {
display "Conclusion: CV increased -> benefit levels became less homogeneous across states."
}
display "--------------------------------------------------------"



*******************************************************
* SECTION 2. TABLE 3: UI generosity vs. economic variables (with state and year FE)
* NOTE: Column (3) house price growth (hpi_growth) is not available in your data.
*******************************************************

* Setup
clear all
set more off

* Load data
use "C:\Users\Willi\Downloads\116160-V1\ui_econ_analysis.dta", clear

* Variable labels to match the paper's wording in the exported table
label variable unemp_rate "Unemployment rate (\%)"
label variable ln_realgdp_percap "log of real GDP per capita"
label variable wages_state "Average wage"
label variable cov "Union coverage (\%)"
label variable ui_rr "UI trust fund reserves ((\%) of covered wages)"
label variable neg_ui_rr "UI trust fund reserve $<$ 0?"
label variable max_ben "Max Benefit"

* Run regressions and attach a "Yes" indicator for FE row in the output

*--- Column (1): Unemployment rate ---
areg max_ben unemp_rate year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m1

*--- Column (2): log of real GDP per capita ---
areg max_ben ln_realgdp_percap year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m2

*--- Column (3): House Price Growth (SKIPPED) ---
***Data Unavailable

*--- Column (4): Average wage ---
areg max_ben wages_state year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m4

*--- Column (5): Union coverage ---
areg max_ben cov year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m5

*--- Column (6): UI trust fund reserves ---
areg max_ben ui_rr year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m6

*--- Column (7): UI trust fund reserve < 0 ---
areg max_ben neg_ui_rr year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m7

*--- Column (8): Multivariate (All variables) ---
areg max_ben unemp_rate ln_realgdp_percap wages_state cov ui_rr neg_ui_rr year_dum*, a(stcode) cl(stcode)
estadd local fixed "Yes"
estimates store m8

* Export LaTeX table
local output_file "table3_replication.tex"

esttab m1 m2 m4 m5 m6 m7 m8 using "`output_file'", replace ///
b(3) se(3) ///
label ///
booktabs ///
keep(unemp_rate ln_realgdp_percap wages_state cov ui_rr neg_ui_rr) ///
order(unemp_rate ln_realgdp_percap wages_state cov ui_rr neg_ui_rr) ///
stats(N r2 fixed, labels("Observations" "R$^2$" "State and year fixed effects?") fmt(%9.0fc %9.2f)) ///
mtitles("(1)" "(2)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Replication of Table 3") ///
addnotes("Notes: Standard errors adjusted for clustering at the state level in parentheses." "Column (3) excluded due to data unavailability.")



*******************************************************
* SECTION 3. TABLE 4: Mortgage delinquency vs UI generosity (SIPP analysis)
* NOTE: hpi_growth removed because not available.
*******************************************************

* Setup
clear all
set more off

* Load data
use "C:\Users\Willi\Downloads\116160-V1\ui_sipp_analysis.dta", clear

* Define controls
global state_controls "unemp_rate ln_realgdp_percap wages_state ui_rr neg_ui_rr union_cov"
global ind_controls "i.layoff##c.ltv_win_demean i.layoff##c.neg_equity_demean earnings_total thhtnw educ_hs educ_somecol educ_col educ_grad"


*******************************************************
* Run regressions
*******************************************************

*--- Model (1): Main effect (no interaction) ---
areg delinq_mort max_ben_demean i.layoff year_dum* $state_controls $ind_controls [pw = weight_ref], a(stcode) cl(stcode)
estadd local hh_ctrl "Yes"
estadd local st_ctrl "Yes"
estadd local fe "Yes"
estadd local st_yr_fe "No"
estimates store m1

*--- Model (2): Interaction effect ---
areg delinq_mort i.layoff##c.max_ben_demean year_dum* $state_controls $ind_controls [pw = weight_ref], a(stcode) cl(stcode)
estadd local hh_ctrl "Yes"
estadd local st_ctrl "Yes"
estadd local fe "Yes"
estadd local st_yr_fe "No"
estimates store m2

*--- Model (3): State-year fixed effects ---
areg delinq_mort i.layoff##c.max_ben_demean $state_controls $ind_controls [pw = weight_ref], a(st_year) cl(stcode)
estadd local hh_ctrl "Yes"
estadd local st_ctrl "---"
estadd local fe "---"
estadd local st_yr_fe "Yes"
estimates store m3


*******************************************************
* Export Table 4 to LaTeX
*******************************************************

local output_file "table4_replication.tex"

esttab m1 m2 m3 using "`output_file'", replace ///
    b(2) se(2) ///                                      
    booktabs ///                                        
    label ///                                           
    keep(max_ben_demean 1.layoff#c.max_ben_demean 1.layoff) /// 
    order(max_ben_demean 1.layoff#c.max_ben_demean 1.layoff) /// 
    coeflabels(max_ben_demean "Max Benefit" ///        
               1.layoff#c.max_ben_demean "Max Benefit $\times$ Layoff" ///
               1.layoff "Layoff") ///
    stats(N r2 hh_ctrl st_ctrl fe st_yr_fe, ///         
        labels("Observations" "R$^2$" "Household controls" "State-year controls" "State and year fixed effects" "State-year fixed effects") ///
        fmt(%9.0fc %9.2f)) ///
    mtitles("(1)" "(2)" "(3)") ///                     
    star(* 0.10 ** 0.05 *** 0.01) ///                   
    title("Replication of Table 4: Unemployment Insurance Generosity and Mortgage Delinquency") ///
    addnotes("Notes: The dependent variable is mortgage delinquency. Max Benefit is demeaned. Standard errors adjusted for clustering at the state level.")



*******************************************************
* SECTION 4. EXTENSION: State-level 90+ delinquency (auto / credit card / student), 2003–2010
*******************************************************

clear all
set more off

* Paths
global uiecon   "C:\Users\Willi\Downloads\116160-V1\ui_econ_analysis.dta"
global carxls   "C:\Users\Willi\Desktop\car.xlsx"
global creditxls "C:\Users\Willi\Desktop\Credit.xlsx"
global studentxls "C:\Users\Willi\Desktop\student.xlsx"

* Build state crosswalk: state abbreviation -> stcode (FIPS)
clear
input str2 st_abbr byte stcode
"AL" 1
"AK" 2
"AZ" 4
"AR" 5
"CA" 6
"CO" 8
"CT" 9
"DE" 10
"DC" 11
"FL" 12
"GA" 13
"HI" 15
"ID" 16
"IL" 17
"IN" 18
"IA" 19
"KS" 20
"KY" 21
"LA" 22
"ME" 23
"MD" 24
"MA" 25
"MI" 26
"MN" 27
"MS" 28
"MO" 29
"MT" 30
"NE" 31
"NV" 32
"NH" 33
"NJ" 34
"NM" 35
"NY" 36
"NC" 37
"ND" 38
"OH" 39
"OK" 40
"OR" 41
"PA" 42
"RI" 44
"SC" 45
"SD" 46
"TN" 47
"TX" 48
"UT" 49
"VT" 50
"VA" 51
"WA" 53
"WV" 54
"WI" 55
"WY" 56
end
save "state_crosswalk.dta", replace

* Build UI state-year panel (2003–2010) + demeaned max_ben
use "$uiecon", clear
keep stcode year max_ben unemp_rate
keep if inrange(year, 2003, 2010)

collapse (mean) max_ben unemp_rate, by(stcode year)

bys year: egen max_ben_year_mean = mean(max_ben)
gen max_ben_demean = max_ben - max_ben_year_mean
drop max_ben_year_mean

isid stcode year
save "ui_state_year_0310.dta", replace

* Check outreg2 availability
capture which outreg2
if _rc != 0 {
di as error "outreg2 not found. Run: ssc install outreg2, replace"
exit 198
}

*******************************************************
* Auto loan 90+ delinquency
*******************************************************
import excel "$carxls", firstrow clear
rename state st_abbr
drop if inlist(st_abbr, "allUS", "PR")
reshape long Q4_, i(st_abbr) j(year)
rename Q4_ auto90
destring auto90, replace force
keep if inrange(year, 2003, 2010)

merge m:1 st_abbr using "state_crosswalk.dta", keep(3) nogen
merge 1:1 stcode year using "ui_state_year_0310.dta", keep(3) nogen

areg auto90 c.unemp_rate##c.max_ben_demean i.year, absorb(stcode) vce(cluster stcode)
outreg2 using "extension_table5.tex", replace tex bdec(3) sdec(3) keep(unemp_rate max_ben_demean c.unemp_rate#c.max_ben_demean) addtext(State FE, Yes, Year FE, Yes, SE clustered by state, Yes) ctitle("Auto loan 90+")

*******************************************************
* Credit card 90+ delinquency
*******************************************************
import excel "$creditxls", firstrow clear
rename state st_abbr
drop if inlist(st_abbr, "allUS", "PR")
reshape long Q4_, i(st_abbr) j(year)
rename Q4_ cc90
destring cc90, replace force
keep if inrange(year, 2003, 2010)

merge m:1 st_abbr using "state_crosswalk.dta", keep(3) nogen
merge 1:1 stcode year using "ui_state_year_0310.dta", keep(3) nogen

areg cc90 c.unemp_rate##c.max_ben_demean i.year, absorb(stcode) vce(cluster stcode)
outreg2 using "extension_table5.tex", append tex bdec(3) sdec(3) keep(unemp_rate max_ben_demean c.unemp_rate#c.max_ben_demean) addtext(State FE, Yes, Year FE, Yes, SE clustered by state, Yes) ctitle("Credit card 90+")

*******************************************************
* Student loan 90+ delinquency
*******************************************************
import excel "$studentxls", firstrow clear
rename state st_abbr
drop if inlist(st_abbr, "allUS", "PR")
reshape long Q4_, i(st_abbr) j(year)
rename Q4_ stud90
destring stud90, replace force
keep if inrange(year, 2003, 2010)

merge m:1 st_abbr using "state_crosswalk.dta", keep(3) nogen
merge 1:1 stcode year using "ui_state_year_0310.dta", keep(3) nogen

areg stud90 c.unemp_rate##c.max_ben_demean i.year, absorb(stcode) vce(cluster stcode)
outreg2 using "extension_table5.tex", append tex bdec(3) sdec(3) keep(unemp_rate max_ben_demean c.unemp_rate#c.max_ben_demean) addtext(State FE, Yes, Year FE, Yes, SE clustered by state, Yes) ctitle("Student loan 90+")

display "Done. Extension table written to extension_table5.tex"
