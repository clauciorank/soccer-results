library(rvest)


images <-
read_html('https://www.escudosfc.com.br/bras2022.htm') %>% 
  html_nodes('img')


links <- images %>% html_attr('src')
names <- images %>% html_attr('alt')


df <- data.frame(names = names[3:126], links = links[3:126]) %>% 
        dplyr::arrange(names) %>% 
        dplyr::mutate(links_total = paste0('https://www.escudosfc.com.br/', links),
                      links_path = paste0('logo_images/', links))

download_images <- function(link, path){
  download.file(link, path)
}

purrr::map2(df$links_total, df$links_path, download_images)

# write.csv(df, 'logos.csv')
