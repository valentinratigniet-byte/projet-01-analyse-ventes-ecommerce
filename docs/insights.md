# Note d'insights — Ventes Olist

**Question métier posée** : « Les ventes ont chuté ces derniers mois — pourquoi,
et que faire ? »
**Périmètre** : commandes livrées (CA réalisé), 2016-2018, marché brésilien.

## 1. Ce qui s'est passé

Après une croissance continue et un pic à **978 k R$ en mai 2018**, le CA a
**reculé 3 mois de suite** (juin → août) pour finir à **839 k R$**, soit **−14 %
sous le pic**. Le pic de **novembre 2017 (+36 % sur un mois)** correspond au
**Black Friday** — un effet saisonnier, pas une tendance de fond.

## 2. La baisse n'est PAS un problème de qualité

Contre-intuitif mais net : pendant la baisse, l'opérationnel s'est **amélioré**.

| Mois 2018 | Délai livraison | % en retard | Note moyenne |
|---|---|---|---|
| Mars | 15,9 j | 21,4 % | 3,81 |
| Mai (pic) | 11,0 j | 8,2 % | 4,24 |
| Août | **7,3 j** | 10,4 % | **4,31** |

→ Délais raccourcis, satisfaction stable et haute (~4,3/5). **La baisse relève de
la saisonnalité / normalisation post-pic, pas d'une dégradation du service.** Il ne
faut donc pas « réparer » l'opérationnel, mais **actionner la demande**.

## 3. Les 3 vrais leviers (où est l'argent)

**a) Rétention quasi nulle — le plus gros gisement.**
**97 % des clients n'ont commandé qu'une seule fois.** L'activité repose
entièrement sur l'acquisition. Récupérer ne serait-ce que quelques points de
ré-achat aurait plus d'impact que n'importe quelle optimisation ponctuelle.

**b) Dépendance géographique forte.**
**São Paulo = 38 % du CA**, et le top 3 des états (SP, RJ, MG) pèse **63 %**. Toute
croissance passe soit par approfondir SP, soit par développer les états sous-exploités.

**c) Le retard de livraison détruit la satisfaction.**
Une commande **en retard tombe à 2,57/5** de note, contre **4,29** à l'heure. Le
retard n'est pas fréquent, mais quand il arrive, il coûte cher en image — et donc
en ré-achat potentiel.

## 4. Recommandations

1. **Lancer un programme de rétention** (relance post-achat, e-mail, offre 2ᵉ
   commande) : cible prioritaire vu les 97 % de one-shot.
2. **Fiabiliser la promesse de livraison** : les retards sont rares mais très
   punitifs sur la note → sécuriser les délais estimés plutôt que les raccourcir.
3. **Plan de croissance géographique** : capitaliser sur SP (38 %) tout en
   développant RJ/MG et les états secondaires pour réduire la dépendance.
4. **Anticiper la saisonnalité** (Black Friday) : la demande est cyclique, planifier
   stock et acquisition autour des pics plutôt que réagir aux creux.

---
*Analyse reproductible : `sql/01_schema.sql` → `02_clean.sql` → `03_kpi.sql`.
Données : Olist (Kaggle), commandes livrées uniquement.*
