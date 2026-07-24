-- ============================================================================
-- 1. Création du Schéma de Staging
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS staging;

-- ============================================================================
-- 2. Suppression des tables existantes (pour réinitialisation propre)
-- ============================================================================
DROP TABLE IF EXISTS staging.staging_ventes;
DROP TABLE IF EXISTS staging.staging_magasins;
DROP TABLE IF EXISTS staging.staging_produits;

-- ============================================================================
-- 3. Structure de la table : Magasins (Source: magasins.csv)
-- ============================================================================
CREATE TABLE staging.staging_magasins (
    id_magasin VARCHAR(50),
    ville VARCHAR(100),
    region VARCHAR(100),
    format VARCHAR(50),
    surface INT
);

-- ============================================================================
-- 4. Structure de la table : Produits (Source: produits.csv)
-- ============================================================================
CREATE TABLE staging.staging_produits (
    id_produit VARCHAR(50),
    nom_produit VARCHAR(150),
    categorie VARCHAR(100),
    prix_revient NUMERIC(10, 2),
    prix_vente NUMERIC(10, 2)
);

-- ============================================================================
-- 5. Structure de la table : Ventes (Source: ventes.csv)
-- ============================================================================
CREATE TABLE staging.staging_ventes (
    id_vente VARCHAR(50),
    date_vente DATE,
    id_magasin VARCHAR(50),
    id_produit VARCHAR(50),
    quantite INT,
    chiffre_affaires NUMERIC(12, 2),
    cout_ventes NUMERIC(12, 2),
    marge NUMERIC(12, 2),
    temps_livraison_jours INT,
    statut_livraison VARCHAR(50)
);