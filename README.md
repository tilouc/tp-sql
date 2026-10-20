# TP SQL

Base de données « entreprise » réalisée en ligne sur **Supabase** (PostgreSQL).

| Fichier | Contenu |
|---|---|
| [`exercice1.sql`](exercice1.sql) | Création des tables |
| [`exercice2.sql`](exercice2.sql) | Insertion des données et tests d'erreurs |
| [`exercice3.sql`](exercice3.sql) | Requêtes d'interrogation et leurs résultats |

## Exercice 1 : Création d'une base de données

**1. Créer un serveur.**
Sur Supabase, un projet correspond à un serveur PostgreSQL. Le projet « entreprise » a été créé (région eu-west-3, Paris). Tous les utilisateurs qui y ont accès travaillent sur le même état de la base.

**2. Créer une base de données « entreprise ».**
En local, on écrirait `CREATE DATABASE entreprise;`. Sur Supabase, chaque projet a déjà sa propre base de données : on utilise celle du projet « entreprise ».

**3. Comment créer une table depuis l'outil « Query » ?**
On ouvre l'éditeur de requêtes (*SQL Editor* sur Supabase, *Query Tool* sur pgAdmin), on y écrit une instruction `CREATE TABLE` et on l'exécute. Pour chaque table, on précise :
- a. le nom et le type de chaque attribut (`INTEGER`, `VARCHAR`, `DATE`) ;
- b. la clé primaire (`PRIMARY KEY`) et les clés étrangères (`REFERENCES table (colonne)`) ;
- c. les attributs obligatoires (`NOT NULL`).

Voir [`exercice1.sql`](exercice1.sql).

**4. Quelle est la clé primaire de « Diriger » et comment la définir ?**
C'est une clé primaire composée du couple `(id_manager, id_dirige)` : un même manager ne peut diriger un même employé qu'une seule fois. Comme elle porte sur deux colonnes, elle se définit au niveau de la table :

```sql
PRIMARY KEY (id_manager, id_dirige)
```

Chacune de ces deux colonnes est aussi une clé étrangère vers `employe (id_employe)`.

## Exercice 2 : Insertion des données

**1. Comment insérer les données sur une table ?**
Avec `INSERT INTO table (colonnes) VALUES (...), (...);`. L'ordre d'insertion est imposé par les clés étrangères : d'abord `entreprise`, puis `employe`, puis `diriger`. Voir [`exercice2.sql`](exercice2.sql).

**2. Que se passe-t-il si une valeur requise n'est pas soumise ? Pourquoi ?**
L'insertion est refusée et aucune ligne n'est ajoutée :

```
ERROR: 23502: null value in column "prenom" of relation "employe" violates not-null constraint
DETAIL: Failing row contains (111, Test, null, 1990-01-01, 30000, 1).
```

Une colonne absente de l'`INSERT` prend la valeur `NULL`. Or la colonne est déclarée `NOT NULL` : le SGBD fait respecter cette contrainte d'intégrité et rejette toute la ligne.

**3. Que se passe-t-il quand un attribut est de type erroné ? Pourquoi ?**
L'insertion est refusée :

```
ERROR: 22P02: invalid input syntax for type integer: "beaucoup"
```

Chaque colonne a un type qui définit les valeurs qu'elle peut contenir. Le SGBD essaie de convertir la valeur dans le type de la colonne. Ici, `'beaucoup'` ne peut pas devenir un entier, donc la ligne est rejetée. À l'inverse, une chaîne comme `'42000'` serait acceptée, car elle se convertit en entier.

## Exercice 3 : Interrogation de la base de données

Les 18 requêtes et leurs résultats sont dans [`exercice3.sql`](exercice3.sql).
