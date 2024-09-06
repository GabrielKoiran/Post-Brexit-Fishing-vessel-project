# Post-Brexit-Fishing-vessel-project

Publicly available code for my project with François-Charles Wolff on studying  the effects of a French 2023 post-Brexit aid package on French fish markets using a protected dataset containing the universe of fish sales in France. This first step of the research process consists in constructing counterfactual fish sale values for fishing vessels that were removed from circulation during 2024.

This read-me file summarizes the origin of the data used for the beggining of this research project, the role of the different R files and the meaning of the various outputs. Unfortunately, some of the data used is protected data from Pr. Wolff, and I am not able to share it here, although I make available the code running on it, as well as the related output.

In this readme file, every data file and output graph is accompanied by its source and a brief description, and R files have a brief description of their purpose and of the files they take as inputs and outputs. For all files available in this repository, there is a direct link (in blue) at the appropriate section of this readme file.

A [context note](Context note.pdf) written from online research in press and governmental sources as part of this project explains the broad purpose and implications of this reform. It is uploaded in this repository and accompanied by an English translation.

## DATA FILES

### [liste_86.xlsx](liste_86.xlsx)
Publicly available list of ships affected by removal program  
Origin: Downloaded pdf on [a page of the French ministry of the Sea](https://www.mer.gouv.fr/sites/default/files/2023-12/Liste%20des%20b%C3%A9n%C3%A9ficiaires%20finaux%20PAI%20-%2086%20navires-3.pdf) and converted to excel

### all_records.csv (too big to be uploaded on Github)
Universe of French fishing vessels  
Origin: [EU fleet registry](https://webgate.ec.europa.eu/fleet-europa/search_en) with the following search criteria:
- Specific country = France
- Period = "All vessels"
- Search Data Context = "Search data in the whole history of the vessels"

### [zone.csv](zone.csv)
orrespondance between names and two-letter codes of fishing zones.  
Origin: Entered manually [this Wikipedia page](https://fr.wikipedia.org/wiki/Liste_des_quartiers_d%27immatriculation_des_navires_en_France) 

### [universe.csv](universe.csv)
All vessels from EU fleet registry, with treated ships identified  
Origin: Output of R file 1 (filter_clean.r)

### [treated_list.csv](treated_list.csv)
List of vessels treated, with information from fleet registry added, including date of destruction  
Origin: Output of R file 1 (filter_clean.r)

### [sum_quartier.csv](sum_quartier.csv)
Summary statistics by port on selected ships present in fleet at certain dates, with treatment status  
Origin: Output of R file 2 (summary_stats.r)

### [treatment_progress.csv](treatment_progress.csv)
Summary stattistics for ships treated at each date during the year  
Origin: Output of R file 2 (summary_stats.r)

### ricPAItemptt.dta (unavailable due to data restrictions)
Aggregate fish sales data by ship x month cell  
Origin: Data (in Stata format) from national fish transaction database, agregated by Pr. Wolff at the ship-month cell level for relevant ports. Includes imputed values when there are no sales certain months, which is reajusted for in later counterfactual estimation.

### ric.csv (unavailable due to data restrictions)
Aggregate fish sales data by ship x month cell  
Origin: Output of R file 4 (counterfactual_estimation.r)

### ric_cf.csv (unavailable due to data restrictions)
Equivalent of Ric.csv with added counterfactuals, and a high and low scenario corresponding to different imputation methods for missing months.  
Origin: Output of R file 4 (counterfactual_estimation.r)

## R FILES (IN ORDER)

###  [File 1: filter_clean.r](filter_clean.R)
Download initial raw data and filter it  
Input files: liste_86.xlsx, all_records.csv  
Output files: universe.csv, treated_list.csv  

### [File 2: summary_stats.r](summary_stats.R)
Summarise treatment by zone and over time  
Input files: universe.csv, treated_list.csv  
Output files: sum_quartier.csv, treatment_progress.csv  

### [File 3: summary_graphs.r](summary_graphs.r)
Output treatment graphs  
Input: sum_quartier.csv, treatment_progress.csv, zone.csv, ric.csv, treated_list.csv  
Output: treatment_plot.png, carte.png, plots_treated_sales.png, plots_random_sales, plots_treated_values.png, plots_random_values, plots_treated_quantities.png, plots_random_quantities, char_space.png  

### [File 4: counterfactual_estimation.r](counterfactual_estimation.R)
Estimate counterfactual trajectories ship by ship  
Input: ricPAItemptt.dta  
Output: ric.csv, neighboring_controls.png, synth_dif.png, ric_cf.csv  

## GRAPHS (OUTPUT FILES)

### [treatment_plot.png](treatment_plot.png)
Cumulative treated (removed) fishing capacity, measured according to different metrics: number of vessels removed, and total legnth, power or shipping volume thereof.  
Origin: Output of R file 3 (summary_graphs.r)

### [carte.png](carte.png)
Map of treatment across the French Atlantic coast, both according to total number of ships removed and the share of initial monthly fishing capacity (in volume) removed.  
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_sales.png](plots_treated_sales.png)
Helps visualize treatment by plotting the sales history of all 86 treated ships in number of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_sales.png](plots_random_sales.png)
Helps visualize control units and imputation by plotting the sales history of 250 random ships in number of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_quantities.png](plots_treated_quantities.png)
Helps visualize treatment by plotting the sales history of all 86 treated ships in total quantity of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_quantities.png](plots_random_quantities.png)
Helps visualize control units and imputation by plotting the sales history of 250 random ships in total quantity of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [plots_treated_values.png](plots_treated_values.png)
Helps visualize treatment by plotting the sales history of all 86 treated ships in total value of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [plots_random_values.png](plots_random_values.png)
Helps visualize control units and imputation by plotting the sales history of 250 random ships in total value of sales. Imputed months are indicated by red dots.   
Origin: Output of R file 3 (summary_graphs.r)

### [char_space.png](char_space.png)
Situates all treated and control ships in the tonnage (vertical axis) / length (horizontal axis) space to detect outliers and select matching criterion. Light blue points represent treated units and dark blue are controls.  
Origin: Output of R file 3 (summary_graphs.r)

### [neighboring_controls.png](neighboring_controls.png)
Visualize, for each treated unit, all matched controls according to the selected criterion in the length/tonnage space. Keep as matched controls only ships that are same gear, and +/- 20% of length and tonnage if treated ship is less than 25m long, and all ships of length above 24m if treated unit is above 25m long.  
Origin: Output of R file 4 (counterfactual_estimation.r)

### [synth_dif.png](synth_dif.png)
Visualize counterfactuals (and treatment effect, which are non-realized fish sales) estimated using synthetic difference in difference, with the synthdid R package, for each treated unit. This graphs represents vessel production in terms of the total value of sales, but counterfactuals were also estimated for total quantity and number of sales in R file 4.  
Origin: Output of R file 4 (counterfactual_estimation.r)

ALSO ADD GOOGLE DRIVE NOTES. RELIRE NOTES #. Nom variables ? Accessibility of repository. Points à la fin. Put spaces between everything.
