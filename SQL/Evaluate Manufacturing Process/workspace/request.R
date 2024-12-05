# Load the DBI package
library(DBI)


#Step 1: Find file postgresql.conf in C:\Program Files\PostgreSQL\13\data then set password_encryption = md5 # nolint
#Step 2: Find file pg_hba.conf in C:\Program Files\PostgreSQL\13\data then change all METHOD to md5 # nolint
#Step 3: Open command line (cmd,cmder,git bash...) and run psql -U postgres then enter your password when installed postgres sql # nolint
#Step 4: Then change your password by run ALTER USER postgres WITH PASSWORD 'new-password'; in command line # nolint
#Final: Restart service postgresql-x64-1X in your Service.

# Connect to the PostgreSQL database: con
con <- dbConnect(RPostgreSQL::PostgreSQL(),  # nolint
                 dbname = "parts", # nolint
                 host = "127.0.0.1", # nolint
                 port = 5432,
                 user = "postgres",
                 password = "!QAZxsw2")

# Count
# dbGetQuery(con, "SELECT item_no, length FROM parts WHERE item_no = 1") # nolint
parts <- dbGetQuery(con, "WITH agg AS (
	SELECT 
		operator,
		ROW_NUMBER () OVER (PARTITION BY operator ORDER BY item_no) AS row_number,
		height,	
		AVG(height) 
        OVER(PARTITION BY operator ORDER BY 
        item_no RANGE BETWEEN 4 PRECEDING AND CURRENT ROW) 
        AS avg_height,
		 STDDEV(height) 
         OVER (PARTITION BY operator ORDER BY 
         item_no RANGE BETWEEN 4 PRECEDING AND CURRENT ROW) 
         AS stddev_height
	FROM parts p
	--WHERE operator = 'Op-2'
),	
control_limits AS (
    SELECT
		ag.operator AS operator,
		ag.row_number AS row_number,
		ag.height AS height,
		ag.avg_height AS avg_height,
		ag.stddev_height AS stddev_height,
        ag.avg_height + (3 * ag.stddev_height / SQRT(5)) AS ucl,
        ag.avg_height - (3 * ag.stddev_height / SQRT(5)) AS lcl
    FROM agg ag
)
SELECT operator,
	   row_number,
	   height,
	   avg_height,
	   stddev_height,
       ucl,
       lcl,
       CASE 
           WHEN height > ucl OR height < lcl THEN TRUE
           ELSE FALSE
       END AS alert
FROM control_limits cl
WHERE row_number >= 5
--ORDER BY alert DESC
") # nolint

# Print parts
print(parts)