This code package uses HRS, IDDA, and SOI data to produce figures regarding nonwage income for the feature article in For All Spring 2026. 
Current figures can be reviewed in /out/nwi_article_charts.html


Directory organization: 

/data is used by programs in /do to produce output in /graphs and /out. 


Data:

Instructions: Download all the files indicated below and move and/or extract them to the '/data' subfolder of the home directory. 

1. RAND HRS data

Navigate to: https://hrsdata.isr.umich.edu/data-products/rand 

Locate the header 'Longitudinal and Cross-Wave Data Products' 

Click on the 'RAND HRS Longitudinal File 2022', 'RAND HRS Detailed Imputations File 2022' hyperlinks to download: 
		
	randhrs1992_2022v1.zip
	randhrsimp1002_2022v1.zip 

Note: These files are large (2.9gb) and will take time to download.  
	 
2. Survey of Income Statistics data, IDDA pctls

Provided in the data subfolder. 



Programs (/do/): 

00_hrs.do cleans and reshapes HRS data to be used in: 
	hrs_graphs.do 
		which produces Figures 4-7
	hrs_data_dive_graphs.do 
		which produces figures for data dive

idda_nw_pctls.R 
	produces Figure 2

SOI_nw_components.R
	produces Figure 3  










 