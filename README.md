# Post-Brexit-Fishing-vessel-project

Publicly available code for my project with François-Charles Wolff on studying  the effects of a French 2023 post-Brexit aid package on French fish markets using a protected dataset containing the universe of fish sales in France. This first step of the research process consists in constructing counterfactual fish sale values for fishing vessels that were removed from circulation during 2024.

This read-me file summarizes the origin of the data used for the beggining of this research project, the role of the different R files and the meaning of the various outputs. Unfortunately, some of the data used is protected data from Pr. Wolff, and I am not able to share it here, although I make available the code running on it, as well as the related output.

In this readme file, every data file and output graph is accompanied by its source and a brief description, and R files have a brief description of their purpose and of the files they take as inputs and outputs. For all files available in this repository, there is a direct link (in blue) at the appropriate section of this readme file.

## DATA FILES

### [liste_86.xlsx](liste_86.xlsx)
Description: Publicly available list of ships affected by removal program  
Origin: link

### all_records.csv (too big to be uploaded on Github)
Description: European fleet registry records (universe of French fishing vessels)
Origin: [link](https://webgate.ec.europa.eu/fleet-europa/search_en), with the following search criteria:
- Specific country = France
- Period = "All vessels"
- Search Data Context = "Search data in the whole history of the vessels"

### [zone.csv](zone.csv)
Description: Correspondance between names and two-letter codes of fishing zones.
Origin: Entered manually from the following wikipedia page [link](https://fr.wikipedia.org/wiki/Liste_des_quartiers_d%27immatriculation_des_navires_en_France) 

### [universe.csv](universe.csv)
Description: All vessels from Eu fleet registry, with treated ships identified  
Origin: Output of R file 1 (filter_clean.r)

### [treated_list.csv](treated_list.csv)
Description: List of vessels treated, with information from fleet registry added, including date of destruction  
Origin: Output of R file 1 (filter_clean.r)

### [sum_quartier.csv](sum_quartier.csv)
Description: Summary statistics by port on selected ships present in fleet at certain dates, with treatment status  
Origin: Output of R file 2 (summary_stats.r)

### [treatment_progress.csv](treatment_progress.csv)
Description: Summary stattistics for ships treated at each date during the year  
Origin: Output of R file 2 (summary_stats.r)

### ricPAItemptt.dta (unavailable due to data restrictions)
Description: Aggregate fish sales data by ship x month cell  
Origin: Data (in Stata format) from national fish transaction database, agregated by Pr. Wolff at the ship-month cell level for relevant ports.

### ric.csv (unavailable due to data restrictions)
Description: Aggregate fish sales data by ship x month cell  
Origin: Output of R file 4 (counterfactual_estimation.r)

### ric_cf.csv (unavailable due to data restrictions)
Description: ric.csv with added counterfactuals  
Origin: Output of R file 4 (counterfactual_estimation.r)

## R FILES (IN ORDER)

###  [File 1: filter_clean.r](filter_clean.R)
Role:  Download initial raw data and filter it  
Input files: liste_86.xlsx, all_records.csv  
Output files: universe.csv, treated_list.csv  

### [File 2: summary_stats.r](summary_stats.R)
Role: Summarise treatment by zone and over time  
Input files: universe.csv, treated_list.csv  
Output files: sum_quartier.csv, treatment_progress.csv  

### [File 3: summary_graphs.r](summary_graphs.r)
Role: Output treatment graphs  
Input: sum_quartier.csv, treatment_progress.csv, zone.csv, ric.csv, treated_list.csv  
Output: treatment_plot.png, carte.png, plots_treated_sales.png, plots_random_sales (and by changing one bit of code, get also for qt and mt), char_space.png  

### [File 4: counterfactual_estimation.r](counterfactual_estimation.R)
Role: Estimate counterfactual trajectories ship by ship  
Input: ricPAItemptt.dta  
Output: ric.csv, neighboring_controls.png, synth_dif.png, ric_cf.csv  

## GRAPHS (OUTPUT FILES)

### [treatment_plot.png](treatment_plot.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [carte.png](carte.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_sales.png](plots_treated_sales.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_sales.png](plots_random_sales.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_quantities.png](plots_treated_quantities.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_quantities.png](plots_random_quantities.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_values.png](plots_treated_values.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_values.png](plots_random_values.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [char_space.png](char_space.png)
Description: complete  
Origin: Output of R file 3 (summary_graphs.r)

### [neighboring_controls.png](neighboring_controls.png)
Description: complete  
Origin: Output of R file 4 (counterfactual_estimation.r)

### [synth_dif.png](synth_dif.png)
Description: complete
Origin: Output of R file 4 (counterfactual_estimation.r)

ALSO ADD GOOGLE DRIVE NOTES, AND LINKS TO DIFFERENT FILES, AND REREAD FOR COMPLETION. RELIRE NOTES #. Remplir description. Nom variables ?Accessibility of repository. Ajouter descriptif des variables ?
