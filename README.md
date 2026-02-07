# Hsu-2018-replication-and-extension

This repository contains code and outputs for a replication + modest extension of:

Hsu, Joanne W., David A. Matsa, and Brian T. Melzer (2018).  
**“Unemployment Insurance as a Housing Market Stabilizer.”** *American Economic Review*, 108(1), 49–81.

The project replicates key results requested in the assignment and implements an extension using state-level consumer credit delinquency outcomes.

---

## What is included in this repository

### Code
- `code/Replication and Extension.do`  
  Master Stata do-file that generates all figures and tables in this repo’s `output/` folder.

### Data included (extension only)
These are used for the extension (state-year 90+ delinquency outcomes):
- `data/Credit.xlsx` (credit card 90+ delinquency, Q4)
- `data/car.xlsx` (auto loan 90+ delinquency, Q4)
- `data/student.xlsx` (student loan 90+ delinquency, Q4)

### Outputs
All generated results are saved in:
- `output/`

Files include:
- `output/Figure1_Replication.png`  
- `output/Figure_Level_1991.png`  
- `output/Figure_Level_2010.png`  
- `output/Correlation_Plot.png`  
- `output/table3_replication.tex`  
- `output/table4_replication.tex`  
- `output/extension_table5.tex`  
- `output/Replication Results.log`

---

## Data not included (too large)

The following replication package datasets are **required** to run the full replication, but are **not uploaded** to GitHub because they exceed GitHub’s file size limits:

- `ui_econ_analysis.dta`
- `ui_sipp_analysis.dta`

### How to obtain them
Download the replication package for the paper (https://www.openicpsr.org/openicpsr/project/116160/version/V1/view), then place the `.dta` files locally.

### Where to put them
You can store them anywhere on your computer, but you must update the file paths inside:

- `code/Replication and Extension.do`

---

## Software requirements

- Stata (recommended: Stata 15+; should work in earlier versions with minor adjustments)
- Stata user-written packages:
  - `maptile` and `spmap` (for Figure 1 maps)
  - `estout` (for `esttab` / `estadd` used in tables)
  - `outreg2` (used in the extension table export)

Install them in Stata using:

```stata
ssc install maptile, replace
ssc install spmap, replace
ssc install estout, replace
ssc install outreg2, replace
maptile_install using "http://files.michaelstepner.com/geo_state.zip"
````

---

## How to run (end-to-end)

1. **Clone or download** this repository.
2. Ensure the extension Excel files are in:

   * `data/`
3. Download and store the replication package datasets locally:

   * `ui_econ_analysis.dta`
   * `ui_sipp_analysis.dta`
4. Open:

   * `code/Replication and Extension.do`
5. **Edit the file paths** at the top (or wherever `use "..."` appears) so Stata can find:

   * `ui_econ_analysis.dta`
   * `ui_sipp_analysis.dta`
   * `data/Credit.xlsx`, `data/car.xlsx`, `data/student.xlsx`
6. Run the do-file in Stata:

   ```stata
   do "code/Replication and Extension.do"
   ```
7. All outputs will be written to:

   * `output/`

---

## Replication tasks covered

### Figure 1 (Replication + two additional maps)

* Replicates Figure 1: geographic distribution of **regular UI max benefit increases (1991–2010)** by quantile
* Adds two maps:

  * UI max benefit levels in **1991**
  * UI max benefit levels in **2010**
* Also produces a correlation plot and dispersion statistics to answer:

  * correlation between initial level (1991) and subsequent increase
  * whether UI benefits became more/less homogeneous by 2010

Outputs:

* `output/Figure1_Replication.png`
* `output/Figure_Level_1991.png`
* `output/Figure_Level_2010.png`
* `output/Correlation_Plot.png`

### Table 3 (Replication)

* Replicates Table 3 regressions of max benefit on economic variables with state and year fixed effects.
* **Note:** the paper’s `hpi_growth` (Case-Shiller home price growth) is not available in the public replication files due to data contract restrictions, so the code **skips Column (3)** and runs the remaining columns.

Output:

* `output/table3_replication.tex`

### Table 4 (Replication)

* Replicates Table 4: mortgage delinquency regressed on UI generosity and controls using SIPP-based microdata.
* Includes models with interaction terms and a specification with state-year fixed effects.

Output:

* `output/table4_replication.tex`

---

## Extension: State-level 90+ delinquency (Auto / Credit card / Student), 2003–2010


This extension combines **state-year 90+ delinquency rates** (auto loans, credit cards, and student loans) with **state-year unemployment rates** and **UI generosity** measures. We estimate regressions that include **state fixed effects** and **year fixed effects**, with **standard errors clustered by state**, to test whether delinquency is related to unemployment and whether more generous UI mitigates the effect of unemployment on delinquency.

Output:

* `output/extension_table5.tex`


---


## Citation

Hsu, Joanne W., David A. Matsa, and Brian T. Melzer. 2018.
“Unemployment Insurance as a Housing Market Stabilizer.” *American Economic Review* 108(1): 49–81.

