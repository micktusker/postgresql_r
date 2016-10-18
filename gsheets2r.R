library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))

"
> gs_auth()
Waiting for authentication in browser...
Press Esc/Ctrl + C to abort
Authentication complete.
> foxp3.cord.experiments <- getSheetAsDataFrame(sh.id, sh.name, df.name)
Assumes '.httr-oauth' has been set by above steps.
"
getSheetAsDataFrame <- function(gs.id, sheet.name, dataframe.name) {
  sh <- gs_key(gs.id, verbose = FALSE)
  tmp.file.name <- tempfile(sheet.name, fileext = '.csv')
  gs_download(sh, ws = sheet.name, tmp.file.name, verbose = FALSE)
  sheet.as.dataframe <- read.csv(tmp.file.name, stringsAsFactors = FALSE)
  return(sheet.as.dataframe)
}
