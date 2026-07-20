-- 1. Création du schéma décisionnel
CREATE SCHEMA IF NOT EXISTS dwh;

-- ============================================================================
-- 2. CRÉATION DES TABLES DE DIMENSIONS
-- ============================================================================

-- DIMENSION MAGASINS
DROP TABLE IF EXISTS dwh.dim_stores CASCADE;
CREATE TABLE dwh.dim_magasins (
    id_magasin VARCHAR(50) PRIMARY KEY,
    ville VARCHAR(100),
    region VARCHAR(100),
    format VARCHAR(50),
    surface INTEGER
);

-- DIMENSION PRODUITS
DROP TABLE IF EXISTS dwh.dim_products CASCADE;
CREATE TABLE dwh.dim_produits (
    id_produit VARCHAR(50) PRIMARY KEY,
    nom_produit VARCHAR(150),
    categorie VARCHAR(100),
    prix_revient NUMERIC(10, 2),
    prix_vente NUMERIC(10, 2)
);

-- DIMENSION DATE (Calendrier pré-généré de 2020 à 2030)
DROP TABLE IF EXISTS dwh.dim_date CASCADE;
CREATE TABLE dwh.dim_date (
    id_date DATE PRIMARY KEY,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    nom_mois VARCHAR(20) NOT NULL,
    trimestre INTEGER NOT NULL,
    semaine_annee INTEGER NOT NULL,
    jour_mois INTEGER NOT NULL,
    jour_semaine INTEGER NOT NULL,
    nom_jour VARCHAR(20) NOT NULL,
    est_weekend BOOLEAN NOT NULL
);

-- ============================================================================
-- 3. CRÉATION DE LA TABLE DE FAITS (Modèle en Étoile avec Clés Étrangères)
-- ============================================================================
DROP TABLE IF EXISTS dwh.fact_sales CASCADE;
CREATE TABLE dwh.fait_ventes (
    id_vente VARCHAR(50) PRIMARY KEY,
    id_date DATE NOT NULL REFERENCES dwh.dim_date(id_date),
    id_magasin VARCHAR(50) NOT NULL REFERENCES dwh.dim_magasins(id_magasin),
    id_produit VARCHAR(50) NOT NULL REFERENCES dwh.dim_produits(id_produit),
    quantite INTEGER,
    chiffre_affaires NUMERIC(12, 2),
    cout_ventes NUMERIC(12, 2),
    marge NUMERIC(12, 2),
    temps_livraison_jours INTEGER,
    statut_livraison VARCHAR(50)
);

-- ============================================================================
-- 4. ALIMENTATION (ETL / POPULATION DES TABLES)
-- ============================================================================

-- Remplissage de dim_magasins à partir du Staging
INSERT INTO dwh.dim_magasins (id_magasin, ville, region, format, surface)
SELECT id_magasin, ville, region, format, surface FROM staging.staging_magasins;

-- Remplissage de dim_produits à partir du Staging
INSERT INTO dwh.dim_produits (id_produit, nom_produit, categorie, prix_revient, prix_vente)
SELECT id_produit, nom_produit, categorie, prix_revient, prix_vente FROM staging.staging_produits;

-- Remplissage de dim_date grâce au moteur Postgres (2020 à 2030)
INSERT INTO dwh.dim_date
SELECT 
    datum AS id_date,
    EXTRACT(YEAR FROM datum)::INTEGER AS annee,
    EXTRACT(MONTH FROM datum)::INTEGER AS mois,
    TO_CHAR(datum, 'TMMonth') AS nom_mois,
    EXTRACT(QUARTER FROM datum)::INTEGER AS trimestre,
    EXTRACT(WEEK FROM datum)::INTEGER AS semaine_annee,
    EXTRACT(DAY FROM datum)::INTEGER AS jour_mois,
    EXTRACT(ISODOW FROM datum)::INTEGER AS jour_semaine,
    TO_CHAR(datum, 'TMDay') AS nom_jour,
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END AS est_weekend
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) datum;

-- Remplissage de la table de faits finale (Conversion du texte date en vrai type DATE)
INSERT INTO dwh.fait_ventes (
    id_vente, id_date, id_magasin, id_produit, quantite, 
    chiffre_affaires, cout_ventes, marge, temps_livraison_jours, statut_livraison
)
SELECT 
    id_vente,
    date_vente::DATE, -- On caste le texte '2026-03-02' en type DATE SQL
    id_magasin,
    id_produit,
    quantite,
    chiffre_affaires,
    cout_ventes,
    marge,
    temps_livraison_jours,
    statut_livraison
FROM staging.staging_ventes;