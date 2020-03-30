# COVID-19 Prediction for Confirmed Cases
[![Build Status](https://travis-ci.org/dspim/COVID-19-Forecasts.svg?branch=master)](https://travis-ci.org/dspim/COVID-19-Forecasts)

![COVID-19 prediction on confirmed case (Taiwan)](https://github.com/dspim/COVID-19-Forecasts/raw/master/snapshot.png "COVID-19 prediction on confirmed case (Taiwan)")  
https://dspim.github.io/COVID-19-Forecasts/

### About this project
As the COVID-19 pandemic continues to grow, health authorities need to have a better understanding of future epidemic development in order to execute proper non-medical interventions and optimize the allocation of critical medical resources.

In view of this, we applied statistical methods to predict daily confirmed cases in infected countries. 

### What are sample use cases
Our project has two main outputs: a country-level prediction model for confirmed cases and a dashboard for demonstrating prediction results.

First, since this statistical model covers all infected countries, health authorities and medical institutions around the world can use these predictions for executing proper non-medical interventions and medical resource planning.

Secondly, epidemic modelers can either replace the included prediction model with their own models or enhance their models with the included one. In both cases, the modellers can use the dashboard for model output and as the user interface.

### How did you address this problem
We developed a country-level prediction model for confirmed cases, based on daily epidemic updates from trustworthy data sources.

We also provided a dashboard to display real-time case statistics, model results and prediction performance over time. 

We have designed this system for use in all countries. 

All source code can be downloaded on Github. (https://dspim.github.io/COVID-19-Forecasts/)

### How I bulit it
- [R](https://www.r-project.org) + [R Markdown](https://rmarkdown.rstudio.com) + [GitHub](https://github.com) + [Travis CI](https://travis-ci.org)
- Data visualization r packages：`plotly` + `dygraph` + `DT`
- Data source:
    - [Novel COVID-19 API](https://github.com/novelcovid/api)
    - [Taiwan CDC](https://nidss.cdc.gov.tw/ch/NIDSS_DiseaseMap.aspx?dc=1&disease=19CoV&dt=5&fbcl=)
- Reference of forecast methods
    - [Hsieh, T. C., Ma, K. H., & Chao, A. (2016). iNEXT: iNterpolation and EXTrapolation for species diversity. R package version, 2(8), 1-18.](https://cran.r-project.org/web/packages/iNEXT/vignettes/Introduction.html)
    - [Chao, A., & Jost, L. (2012). Coverage‐based rarefaction and extrapolation: standardizing samples by completeness rather than size. Ecology, 93(12), 2533-2547.](http://chao.stat.nthu.edu.tw/wordpress/paper/95.pdf)

### Implementation
1. Install required tools 
  - Required: [R](https://www.r-project.org)
  - Install R packages in `DESCRIPTION`
  - Suggested: [RStudio IDE](https://rstudio.com/products/rstudio/download/)

2. Clone this repo to your system to get the project files
```{bash}
git clone https://github.com/dspim/COVID-19-Forecasts.git
```

3. Open the checked out top level folder inside your terminal
```{bash}
cd COVID-19-Forecasts
```

4. Run all relevant build scripts at once
```{bash}
Rscript R/01_get_raw_data.R 
Rscript R/02_get_Stage1_data.R 
Rscript R/03_make_pred.R 
Rscript R/04_makeDashboard.R
```

5. Open dashboard file (`index.html`)

### Hack the prediction algorithm
- Create a prediction function like  `Pred.Chao()` in `"./R/main.R Line 77-92"`  
- Modified `calPred()` in `"./R/main.R Line 55-58"`

### Who (or what organizations) could potentially benefit from your solution?
We are data scientists, not epidemonist. We have crunched the numbers and produced a data-driven epidemic prediction model. 

We hope health authority and medical institutions around the world can use our project for decision support, such as executing proper non-medical interventions and optimizing the allocation of critical medical resources.

### What's next for COVID-19 Prediction on Confirmed Case
- Develop subnational (city) level prediction models.
- Hopefully, assist local authorities in decision making for epidemic risk management.
- Encourage data scientists and/or epidemonists around the world to collaborate by using this system to improve their own prediction models.



### Credits
- Johnson Hsieh (johnson@dsp.im)
- Chen En Li (leslie.li@dsp.im)
- [DSP, Inc.](https://dsp.im) a data driven consulting company based in Taiwan

### License
[The MIT License (MIT)](https://github.com/dspim/COVID-19-Forecasts/blob/master/LICENSE)
