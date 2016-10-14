# postgresql_r
R functions and packages for working with PostgreSQL.

Source this file and use the functions as follows:

```R
iris <- as.data.frame(iris)
pg.conn <- getPgConnection('localhost', 5433, 'cd38', 'micktusker')
result <- loadDataFrameToPg(pg.conn,'iris',iris)
print(result)
dbDisconnect(pg.conn)
```
