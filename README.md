# Post-Brexit-Fishing-vessel-project
Publicly available code for my project with François-Charles Wolff on studying  the effects of a French 2023 post-Brexit aid package on French fish markets using a protected dataset containing the universe of fish sales in France.

This read-me file summarizes the origin of the data used for the beggining of this research project, the role of the different R files and the meaning of the various outputs. Unfortunately, some of the data used is protected data from Pr. Wolff, and I am not able to share it here, although I make available the code running on it and some of the related output.

This first step of the research process consists in constructing counterfactual fish sale values for fishing vessels that were removed from circulation during 2024.

## DATA FILES

### liste_86.xlsx
Description: Publicly available list of ships affected by removal program  
Origin: link

### all_records.csv
Description: European fleet registry records for selected sample of ships ()  
Origin: link

### universe.csv
Description: All vessels from Eu fleet registry, with treated ships identified  
Origin: Output of R file 1 (filter_clean.r)

### treated_list.csv
Description: List of vessels treated, with information from fleet registry added, including date of destruction  
Origin: Output of R file 1 (filter_clean.r)

### sum_quartier.csv
Description: Summary statistics by port on selected ships present in fleet at certain dates, with treatment status  
Origin: Output of R file 2 (summary_stats.r)

### treatment_progress.csv
Description: Summary stattistics for ships treated at each date during the year  
Origin: Output of R file 2 (summary_stats.r)

### ricPAItemptt.dta (unavailable of Github due to data restrictions)
Description: Aggregate fish sales data by ship x month cell  
Origin: Data (in Stata format) from national fish transaction database, agregated by Pr. Wolff at the ship-month cell level for relevant ports.

### ric.csv (unavailable of Github due to data restrictions)
Description: Aggregate fish sales data by ship x month cell  
Origin: Output of R file 4 (counterfactual_estimation.r)

### ric_cf.csv (unavailable of Github due to data restrictions)
Description: ric.csv with added counterfactuals  
Origin: Output of R file 4 (counterfactual_estimation.r)

## R FILES (IN ORDER)

### File 1: filter_clean.r
Role:  Download initial raw data and filter it  
Input files: liste_86.xlsx, all_records.csv  
Output files: universe.csv, treated_list.csv

### File 2: summary_stats.r
Role: Summarise treatment by zone and over time  
Input files: universe.csv, treated_list.csv  
Output files: sum_quartier.csv, treatment_progress.csv

### File 3: summary_graphs.r
Role: Output treatment graphs  
Input: sum_quartier.csv, treatment_progress.csv, zone.csv, ric.csv, treated_list.csv  
Output: treatment_plot.png, carte.png, plots_treated_sales.png, plots_random_sales (and by changing one bit of code, get also for qt and mt), char_space.png

### File 4: counterfactual_estimation.r
Role: Estimate counterfactual trajectories ship by ship  
Input: ricPAItemptt.dta  
Output: ric.csv, neighboring_controls.png, synth_dif.png, ric_cf.csv

## GRAPHS (OUTPUT FILES)

### treatment_plot.png
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### carte.png
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### plots_treated_sales.png
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### plots_random_sales.png
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### char_space.png
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### neighboring_controls.png
Description: complete  
Origin: Output of R file 4 (counterfactual_estimation.r)

### synth_dif.png
Description: complete
Origin: Output of R file 4 (counterfactual_estimation.r)

ALSO ADD GOOGLE DRIVE NOTES, AND LINKS TO DIFFERENT FILES, AND REREAD FOR COMPLETION. RELIRE NOTES #
