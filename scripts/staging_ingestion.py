import psycopg2
import csv
import os
from dotenv import load_dotenv

# Revenir d'un niveau pour trouver le fichier .env dans config/
load_dotenv(os.path.join(os.path.dirname(__file__), '../config/.env'))

# Database connection parameters
DB_HOST = 'localhost'
DB_USER = 'postgres'
DB_NAME = 'retail_staging'
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_PORT = '5433'

def connect_to_retail():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT,
        connect_timeout=5
    )

def ingest_csv(curs, file_path, query, expected_cols):
    """Fonction générique pour ingérer un fichier CSV avec gestion des erreurs"""
    if not os.path.exists(file_path):
        print(f"❌ Fichier introuvable : {file_path}")
        return False
        
    with open(file_path, 'r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=';')
        next(reader) # Ignorer l'entête

        for row in reader:
            if not row or len(row) < expected_cols:
                continue    
            curs.execute(query, row)
    print(f"✅ Ingestion réussie pour : {os.path.basename(file_path)}")
    return True

def pipe_data():
    conn = connect_to_retail()
    curs = conn.cursor()
    print("Successfully connected to PostgreSQL")

    # Définition des chemins d'accès relatifs grâce à os.path
    base_dir = os.path.dirname(__file__)
    data_dir = os.path.join(base_dir, '../data/raw')

    # 1. Requêtes d'insertion
    q_ventes = "INSERT INTO staging.staging_ventes (id_vente, date_vente, id_magasin, id_produit, quantite, chiffre_affaires, cout_ventes, marge, temps_livraison_jours, statut_livraison) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    q_magasins = "INSERT INTO staging.staging_magasins (id_magasin, ville, region, format, surface) VALUES (%s, %s, %s, %s, %s)"
    q_produits = "INSERT INTO staging.staging_produits (id_produit, nom_produit, categorie, prix_revient, prix_vente) VALUES (%s, %s, %s, %s, %s)"

    # 2. Exécution de l'ingestion pour chaque fichier
    try:
        # Vider le staging avant de recharger (Optionnel mais recommandé pour éviter les doublons)
        curs.execute("TRUNCATE staging.staging_ventes, staging.staging_magasins, staging.staging_produits CASCADE;")
        
        ingest_csv(curs, os.path.join(data_dir, 'ventes.csv'), q_ventes, 10)
        ingest_csv(curs, os.path.join(data_dir, 'magasins.csv'), q_magasins, 5)
        ingest_csv(curs, os.path.join(data_dir, 'produits.csv'), q_produits, 5)
        
        conn.commit()
        print("🎉 Successful Data Pipeline - All data ingested!")
    except Exception as e:
        conn.rollback()
        print(f"❌ Erreur durant le pipeline : {e}")
    finally:
        curs.close()
        conn.close()

if __name__ == "__main__":
    pipe_data()
