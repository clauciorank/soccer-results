source('utils.r')


league <- 'bra-serie-a'
season <- 2003:2022

path <- 'data/leagues/bra-serie-a/'

for(ano in season){
  a <- get_results_of_season(league, ano)
  
  json <- jsonlite::toJSON(a)
  
  write(json, sprintf('%sresults_%s.json', path, ano))
}

