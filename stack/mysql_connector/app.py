import sys
import pymysql
import logging
import sys

HOST = "mysqldb-rdscluster-yfo9et6qxuvh.cluster-cnsvu2edmlyg.us-east-1.rds.amazonaws.com"
USER = "root"
PASSWORD = "AmazingPassword"
DB = "myschema"

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def db_connection() :
    db_conn = pymysql.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        db=DB
    )
    db_cur = db_conn.cursor()
    return db_conn , db_cur

def count_rows(cursor , table):
    query = "SELECT * FROM {};".format(table)
    cursor.execute(query)
    count = 0

    for row in cursor.fetchall():
        count +=1
        logger.info(row)

    return count

def insert_int_S3(cur , table):
    query = f"""
        SELECT *
         FROM myschema.{table}
         INTO OUTFILE S3 's3://md-source-datalake/data/myschema/{table}/{table}.scv'
         FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' OVERWRITE ON;"""

    cur.execute(query)
    logger.info("Successfully connected and found table {} in the database.".format(table))







def lambda_handler(event , context):
    """
    This function run sql queries against rds cluster
     to retrieve data and ingest the data to S3
    """

    try:
        conn , cur = db_connection()
        logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")
    except pymysql.MySQLError as e:
        logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        logger.error(e)
        sys.exit()

    insert_int_S3(cur , "users")
    insert_int_S3(cur , "transactions")


    users_count = count_rows(cur , "users")
    transactions_count = count_rows(cur , "transactions")

    conn.close()

    return "Found {} items in users table & {} items in transactions table".format(users_count , transactions_count)





