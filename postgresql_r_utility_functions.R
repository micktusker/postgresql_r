# Some general functions for using R and PostgreSQL.
# Links:
# http://www.win-vector.com/blog/2016/02/using-postgresql-in-r/
# http://welcome-to-data-science.blogspot.co.uk/2015/03/comparison-of-packages-rpostgresql-and.html

library(RPostgreSQL)
# Return a vector where each line is an entry in the ".pgpass" file.
getPgPassFile <- function() {
  home.dir <- Sys.getenv("HOME")
  pgpass.path <- paste0(home.dir, '/', '.pgpass')
  lines <- readLines(pgpass.path)
  return(lines)
}

# Given the host, port, dbname and user, find the line in.pgpass
#  matching these, return the password.
# Clunky but works!
getPgPwd <- function(host, port, dbname, user) {
  pgpass.lines <- getPgPassFile()
  entry <- paste0(c(host, port, dbname, user), ':', collapse = '')
  pass.entry.idx <- grep(entry, pgpass.lines)
  pass.entry <- pgpass.lines[pass.entry.idx]
  passwd <- gsub(entry, "", pass.entry)
  return(passwd)
}

# Return a postgresql connection for the given arguments.
# TODO: Better error trapping if the connection cannot be made.
getPgConnection <- function(host, port, dbname, user) {
  password <- getPgPwd(host, port, dbname, user)
  if(length(password) == 0) {
    stop("No password found for given arguments")
  }
  pg.driver <- dbDriver("PostgreSQL")
  pg.conn <- try(dbConnect(pg.driver, dbname=dbname, host=host, port=port, user=user, password=password))
  rm(password)
  return(pg.conn)
}

# Given a Postgresql connection as created by "getPgConnection", a Postgresql table
#  name (the table will be created) and a data frame to load, load the data frame
#  and return the result.
# On success, return TRUE.
loadDataFrameToPg <- function(pg.conn, pg.table.name, dataframe.to.load) {
  result <- dbWriteTable(pg.conn, pg.table.name, dataframe.to.load, row.names=FALSE)
  return(result)
}
# When a new table is created from an uploaded data frame, there is no way to use a schema
#  other than 'public'. This function takes a table name and a schema name and moves the table
#  from the public schema to the new schema.
# Assumes the table name existsd in the 'public' schema and that the new schema name exists.
# On success, returns TRUE.
changeTableSchema <- function(pg.conn, table.name, new.schema.name) {
  schema.change.sql <- sprintf('ALTER TABLE %s SET SCHEMA %s', table.name, new.schema.name)
  result <- dbGetQuery(pg.conn, schema.change.sql)
  if(is.null(result)) {
    return(TRUE)
  }
}
