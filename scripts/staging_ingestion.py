import psycopg2
import csv
import pandas
import os
from dotenv import load_dotenv
load_dotenv()


#Database connection parameters
DB_HOST = 'localhost'
DB_USER = 'postgres'
DB_NAME = 'retail_staging'
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_PORT = '5433'

# Function - Connect to postgres
def connect_to_retail():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT,
        connect_timeout=5
    )

# Function - Ingest data
def pipe_data():
    # Connection to PostgreSQL
    conn = connect_to_retail()
    curs = conn.cursor()

    print("Successfully connected to PostgreSQL")

    # Open the file (CSV)
    with open('ventes.csv','r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=';')
        next(reader) # Skip the header row

        # CORRECTION : Remplacement du %d par %s pour psycopg2
        query = "INSERT INTO staging.staging_ventes (id_vente, date_vente, id_magasin, id_produit, quantite, chiffre_affaires, cout_ventes, marge, temps_livraison_jours, statut_livraison) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"

        # Insert each row in the table 
        for row in reader:
            #print(f"Ligne lue : {row}")
            # On ignore les lignes vraiment vides ou incomplètes
            if not row or len(row) < 10:
                continue    
            
            curs.execute(query, row)
        
        # Commit and close the connection
        conn.commit()
        curs.close()
        conn.close()
        print ("Successful Data Pipeline")

if __name__ == "__main__":
    pipe_data()