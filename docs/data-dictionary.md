# Dictionnaire de données — dashboard Olist

> **Instantané publié** (Living Documentation). Source de vérité : les descriptions
> vivent dans le modèle `dashboard-olist.pbix` (info-bulles) et dans les vues SQL.
> Ce document en est une copie lisible, régénérable depuis le modèle. Ne pas éditer
> ici — éditer dans le modèle / les vues.
>
> Périmètre : commandes **livrées** (CA réalisé). Devise : réal brésilien (R$).

## Chaîne des couches

| Couche | Objets | Rôle |
|---|---|---|
| Brut | `olist.<table>` (7 tables TEXT) | copie fidèle des CSV Olist (`01_schema.sql`) |
| Nettoyée | `olist.v_*` (vues typées) | types, nulls, catégories traduites, délais calculés (`02_clean.sql`) |
| Étoile (BI) | `olist.bi_*` (vues) | modèle consommé par Power BI (`04_star_powerbi.sql`) |

## Modèle en étoile (ce que consomme Power BI)

Relations 1→* à sens unique depuis les dimensions vers `bi_fct_sales`.

### `bi_fct_sales` — faits (grain : une ligne d'article, commande livrée)

| Colonne | Type | Description |
|---|---|---|
| order_id | texte | Commande (FK → dim_orders). 1 commande = N lignes → compter via `[Nb commandes]`. |
| product_key | texte | FK → dim_product. |
| customer_key | texte | FK → dim_customer (compte, pas personne). |
| date_key | entier | FK → dim_date (AAAAMMJJ, date d'achat). |
| price | décimal | Prix de l'article (R$). Base du CA (`[CA]` = SUM). |
| freight | décimal | Frais de port de la ligne (R$). Séparé du CA. |

### `bi_dim_orders` — dimension commande (grain : commande)

| Colonne | Type | Description |
|---|---|---|
| order_id | texte | Clé commande (côté 1 vers les faits). |
| status | texte | Statut Olist (modèle filtré sur `delivered`). |
| purchase_month | date | Mois d'achat (1er du mois). |
| delivery_days | entier | Délai réel de livraison (jours). |
| delay_days | entier | Écart vs date estimée (>0 = retard). |
| is_late | booléen | Vrai si livré après l'estimation. |
| **Livraison** | texte | *(colonne calculée)* « À l'heure » / « En retard » / « Inconnu » — dérivée de `is_late`, lisible en axe. |
| review_score | décimal | Note d'avis moyenne de la commande (1-5). |

### `bi_dim_product` — dimension produit

| Colonne | Type | Description |
|---|---|---|
| product_key | texte | Clé primaire. |
| category | texte | Catégorie (traduite en anglais ; « unknown » si absente). |

### `bi_dim_customer` — dimension client

| Colonne | Type | Description |
|---|---|---|
| customer_key | texte | Clé du **compte** (un par commande chez Olist). |
| customer_unique_id | texte | Identifiant de la **personne** → base de la rétention. |
| state | texte | Code de l'état brésilien (ex. SP). Catégorisé « État/province ». |
| state_name | texte | Nom complet de l'état (SP → São Paulo). Lisible, pour carte/légendes. |
| city | texte | Ville du client. |

### `bi_dim_date` — calendrier (marquée table de dates)

| Colonne | Type | Description |
|---|---|---|
| date_key | entier | Clé AAAAMMJJ (→ faits). |
| date | date | Jour. Socle de la time intelligence. |
| annee / trimestre / mois_num | entier | Niveaux de la hiérarchie `Calendrier`. |
| annee_mois | texte | Clé AAAA-MM (axe des courbes mensuelles). |

## Mesures (18)

### 1 Ventes
| Mesure | Format | Description |
|---|---|---|
| `CA` | R$ | CA = SUM(price). Mesure socle (hors fret). |
| `Fret` | R$ | Total frais de port. |
| `Nb commandes` | # | Commandes distinctes (DISTINCTCOUNT order_id). |
| `Nb articles` | # | Nombre de lignes d'articles. |
| `Nb clients` | # | Comptes clients distincts. |
| `Panier moyen` | R$ | CA / Nb commandes. |

### 2 Temps *(nécessitent la table de dates)*
| Mesure | Format | Description |
|---|---|---|
| `CA mois -1` | R$ | CA du mois précédent (DATEADD). |
| `CA YTD` | R$ | CA cumulé annuel. |
| `Croissance MoM %` | % | Variation vs mois précédent. Révèle la chute de juin 2018 (−12,4 %). |

### 3 Satisfaction
| Mesure | Format | Description |
|---|---|---|
| `Note moyenne` | 0.00 | Note d'avis moyenne (niveau commande). |
| `Délai moyen (j)` | 0.0 | Délai de livraison moyen. |
| `% en retard` | % | Part des commandes livrées en retard. |

### 4 Rétention
| Mesure | Format | Description |
|---|---|---|
| `Clients uniques` | # | Personnes distinctes ayant acheté (périmètre livré) = 93 358. |
| `Taux one-shot %` | % | Part de clients à une seule commande = **97,0 %**. |
| `Clients one-shot` | # | Nombre de clients à 1 commande (90 557). |
| `Clients récurrents` | # | Clients à ≥ 2 commandes (2 801). |
| `Taux récurrent %` | % | Complément du one-shot (3,0 %). |
| `Cible 100%` | % | Constante = 100 % (échelle max d'une jauge). |

---

*Régénérer : relire les métadonnées du modèle via le MCP `powerbi-modeling`
(tables/colonnes/mesures) ou les vues `olist.*`, puis réécrire ce fichier.*
