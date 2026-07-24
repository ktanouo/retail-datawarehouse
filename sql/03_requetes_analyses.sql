/*Évolution du chiffre d'affaires, du coût des ventes, de la marge globale et du taux de marge moyen par mois pour l'année 2024*/
select 
	mois, 
	nom_mois,
	annee,
	sum(chiffre_affaires) as somme_ca, 
	sum(marge) as somme_marges, 
	round((sum(marge)/sum(chiffre_affaires)*100),2) as taux_moyen_marge
	
from dwh.fait_ventes as v
join dwh.dim_date as d on (v.date_vente=d.date_id)
where annee = 2024
group by nom_mois, mois, annee
order by mois;



/*Marge générée en croisant le format des magasins et la catégorie des produits*/
select 
	coalesce(format, 'Tous formats') as format_magasin,
	coalesce(categorie, 'Toutes catégories') as categorie_produit,
	sum(marge) as marge_totale
	
from dwh.fait_ventes as v 
join dwh.dim_produits as p on (v.id_produit = p.id_produit)
join dwh.dim_magasins as m on (v.id_magasin = m.id_magasin)

group by cube (format, categorie )
order by (format, categorie)
;



/*Délai moyen de livraison par région de magasin, quelle est la proportion de commandes "en retard" par rapport à celles "à l'heure"*/
select
	region, 
	round(avg(temps_livraison_jours), 2) as delai_livraison_moyen,
	round(count(case when statut_livraison = 'En retard' then 1 end)*100.0/ count(*),2) as proportion
	
from dwh.fait_ventes as v
join dwh.dim_magasins as m on (v.id_magasin = m.id_magasin)

group by region
order by proportion asc
;



/*Top 5 des produits les plus rentables*/
select
	nom_produit, 
	sum(marge) as total_marges
	
from dwh.fait_ventes as v
join dwh.dim_produits as p on (v.id_produit = p.id_produit)

group by nom_produit
order by total_marges desc
limit 5
;



/*Impact de la taille des magasins (CA/m²)*/
select 
	ville,
	format,
	sum(chiffre_affaires) as chiffre_affaires,
	surface,
	round(sum(chiffre_affaires)/surface, 2) as impact_chiffre_affaires
	
from dwh.fait_ventes as v
join dwh.dim_magasins as m on (v.id_magasin = m.id_magasin)
group by ville, format, surface
order by impact_chiffre_affaires desc
;