# COVID-19 Prediction for Confirmed Cases
[![Build Status](https://travis-ci.org/dspim/COVID-19-Forecasts.svg?branch=master)](https://travis-ci.org/dspim/COVID-19-Forecasts)

![COVID-19 prediction on confirmed case (Taiwan)](https://github.com/dspim/COVID-19-Forecasts/raw/master/snapshot.png "COVID-19 prediction on confirmed case (Taiwan)")  
https://dspim.github.io/COVID-19-Forecasts/

### About this project
As the epidemic continues to develop, health authorities in various countries around the world need to to stay on top of medical resources and the development of the disease.

In view of this, we have used ecological statistical methods to make daily prediction model for the number of confirmed diagnoses and make epidemic forecasting for countries around the world. It not only provide policy reference for government agencies' epidemic prevention deployment, but also provides epidemiologists around the world to collaborate with.

### What are sample use cases
The dashboard is divided into several large blocks. First of all, users can quickly view the trend of total and new confirmed cases, as well as the development of our predicted epidemic situation. The block on the right side can check the daily information and forecast situation. The four blocks above are the algorithm's accuracy monitoring indicators and the epidemic growth trend indicators.

The same method can be extended to the whole world. We have made predictions of epidemic development in various regions and countries around the world.

### How did you address this problem
The forecasting algorithm is the key element of the whole project. In this version, we used ecological rarefaction and extrapolation methods to build the algorithm.

We also design a plug-in framework for scientists who would like to use their prediction methods to replace our default forecasts. 

This project is a  serverless architecture. We use CI tools to get data, compute forecasting, and deploy the dashboard everyday.

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
Every health authority of governments can benefit from our solution. In addition, it provides epidemiologists around the world to collaborate with. They could fork this github repository, change country views or algorithms. This dashboard could run automatically.

### What's next for COVID-19 Prediction on Confirmed Case
- Develop local versions and assist local governments in using this tool.
- Promote projects to allow more scientists to collaborate.
- Just finished the web crawler from Taiwan CDC, we are going to develop regional (city-based) dashboard in Taiwan.

### Credits
- Johnson Hsieh (johnson@dsp.im)
- Chen En Li (leslie.li@dsp.im)
- [DSP, Inc.](https://dsp.im) a data driven consulting company based in Taiwan

### License
[The MIT License (MIT)](https://github.com/dspim/COVID-19-Forecasts/blob/master/LICENSE)
