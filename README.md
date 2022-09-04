# Football (soccer) results

### In this project I used some important data analysis skills to download, proccess and visualize some soccer data. All the project is developed in R language and some tidyverse packages. In a first moment I explored the points obtained by brazilian teams in the first division of the national championship (Brasileirão) making an animated plot with the temporal evolution with the top 10 teams with more cummulative points since 2003 (the first year in the actual format).

# Web scraping:
Get the results from [worldfootball](worldfootball.net) (the code could be used for download any league in an easy way) and the logos from [escudosfc](https://www.escudosfc.com.br/bras2022.htm).

Files:
- [download_results.r](R/download_results.r)
- [utils.r](R/utils.r)
- [getting_logos.r](R/getting_logos.r)

# Data wrangling and plot:
Proccess the data in a tidy way for filter transform and plot the data. The [animated plot](animated_plot.mpeg) was made with ggplot and gganimate.

![animated_plot](animated_plot.mpeg)
