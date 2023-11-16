import pymysql

HOST = "mysqldb-rdscluster-tnw2kz7v8ep4.cluster-ro-cnsvu2edmlyg.us-east-1.rds.amazonaws.com"
USER = "root"
PASSWORD = "AmazingPassword"
def mysqlconnect():
    #connect to rds cluster
    db_conn = pymysql.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
    )
    #get the database cursor to interact with the database
    db_cur = db_conn.cursor()

    return db_conn , db_cur

def create_myschema_db(db_cur):
    #Creating the myschema table we will use
    query = "CREATE DATABASE IF NOT EXISTS myschema;"
    db_cur.execute(query)

def split_query(file_dir = ""):
    #Read the quries from .sql file
    with open(file_dir , 'r') as sql_file:
        #split quries by its ending ;
        queries = sql_file.read().split(";")

    #remove the last empty query in the list
    queries.pop()
    return queries

def execute_queries(db_cur, executable_queries):
    #execute all quries one by one
    for query in executable_queries:
        db_cur.execute(query + ";")


if __name__ == "__main__":
    sqlFilePath = "initialQuery.sql" #SQL queries file
    conn , cur = mysqlconnect() #Get the cursor and the connection obects
    create_myschema_db(cur) #Create myschema table
    project_queries = split_query(sqlFilePath) #Read the queries in the .sql file and appemd them into a list
    execute_queries(cur, project_queries) #Execute the queries one by one
    conn.close() #close the connection