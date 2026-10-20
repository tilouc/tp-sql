# tp sql

projet réalisé à deux par :

- camara serge louis klondie
- noufou mohamed adel-akou yemi

on a fait le tp en ligne sur supabase (c'est du postgresql) au lieu d'un sgbd en local.

## exercice 1 : création d'une base de données

### 1. créer un serveur sur votre sgbd

sur supabase, un projet correspond à un serveur postgresql. on a créé un projet qu'on a appelé « entreprise ». comme ça, tous ceux qui ont accès au projet travaillent sur le même environnement et voient la base dans le même état.

### 2. créer une base de données « entreprise »

en local, on aurait fait :

```sql
create database entreprise;
```

sur supabase, chaque projet a déjà sa propre base de données, donc on a directement utilisé celle du projet « entreprise ».

### 3. comment créer une table à partir de l'outil « query » ?

on ouvre l'éditeur de requêtes (le sql editor sur supabase, ou le query tool sur pgadmin), on écrit un `create table` et on clique sur run. pour chaque table on a précisé :

- a. le nom et le type de chaque attribut (`integer`, `varchar`, `date`)
- b. la clé primaire avec `primary key` et les clés étrangères avec `references`
- c. les attributs qui ne doivent pas être vides avec `not null`. on l'a mis sur tous les autres attributs parce que toutes les infos servent dans les requêtes (âge, salaire, entreprise...). pour les clés primaires pas besoin, elles sont déjà not null d'office

```sql
create table entreprise (
    id_entreprise integer      primary key,
    nom           varchar(100) not null,
    date_creation date         not null
);

create table employe (
    id_employe     integer      primary key,
    nom            varchar(100) not null,
    prenom         varchar(100) not null,
    date_naissance date         not null,
    salaire        integer      not null,
    id_entreprise  integer      not null references entreprise (id_entreprise)
);

create table diriger (
    id_manager integer not null references employe (id_employe),
    id_dirige  integer not null references employe (id_employe),
    date       date    not null,
    primary key (id_manager, id_dirige)
);
```

on a enlevé les accents dans les noms (employe, prenom, id_dirige) pour éviter les problèmes d'encodage.

### 4. quelle est la clé primaire de « diriger » et comment la définir ?

la clé primaire de diriger, c'est le couple (id_manager, id_dirige). un seul des deux ne suffit pas : un manager peut diriger plusieurs personnes (par exemple 101 dirige 102 et 106), donc id_manager se répète. c'est la combinaison des deux qui identifie une ligne.

comme elle porte sur deux colonnes, on ne peut pas mettre `primary key` à côté d'une seule colonne. on la définit à la fin du `create table` :

```sql
primary key (id_manager, id_dirige)
```

en plus, id_manager et id_dirige sont chacune une clé étrangère vers employe (id_employe).

## exercice 2 : insertion des données

### 1. comment insérer les données sur une table à partir d'un sgbd ?

avec `insert into nom_table (colonnes) values (...), (...);` dans l'éditeur sql. il faut faire attention à l'ordre à cause des clés étrangères : d'abord entreprise, puis employe, puis diriger. sinon on fait référence à une ligne qui n'existe pas encore et l'insertion est refusée.

```sql
insert into entreprise (id_entreprise, nom, date_creation) values
    (1, 'Atlas Distribution', '2015-03-12'),
    (2, 'NordTech',           '2018-09-24'),
    (3, 'GreenMarket',        '2021-01-08');

insert into employe (id_employe, nom, prenom, date_naissance, salaire, id_entreprise) values
    (101, 'Benali',    'Sara',    '1998-05-14', 42000, 1),
    (102, 'Martin',    'Lucas',   '1992-11-03', 38500, 1),
    (103, 'El Amrani', 'Yasmine', '1995-07-22', 55000, 2),
    (104, 'Dupont',    'Hugo',    '2000-02-16', 29000, 3),
    (105, 'Diallo',    'Aminata', '1997-12-09', 33500, 2),
    (106, 'Bernard',   'Inès',    '1994-04-28', 41000, 1),
    (107, 'Petit',     'Adam',    '1999-08-17', 30500, 3),
    (108, 'Leroy',     'Nora',    '1996-01-30', 36000, 2),
    (109, 'Moreau',    'Yanis',   '1993-06-11', 43000, 1),
    (110, 'Roux',      'Lina',    '2001-10-05', 28000, 3);

insert into diriger (id_manager, id_dirige, date) values
    (101, 102, '2022-01-10'),
    (101, 106, '2022-01-10'),
    (109, 101, '2023-02-15'),
    (103, 105, '2023-06-01'),
    (103, 108, '2023-06-01'),
    (106, 104, '2024-03-01'),
    (109, 107, '2024-04-12'),
    (109, 110, '2024-04-12');
```

### 2. que se passe-t-il si une valeur requise n'est pas soumise ? pourquoi ?

on a testé en oubliant le prénom :

```sql
insert into employe (id_employe, nom, date_naissance, salaire, id_entreprise)
values (111, 'Test', '1990-01-01', 30000, 1);
```

postgresql refuse l'insertion et la ligne n'est pas ajoutée :

```
null value in column "prenom" of relation "employe" violates not-null constraint
```

pourquoi : quand on ne donne pas de valeur à une colonne, elle prend `null`. or prenom est en `not null`, donc le sgbd bloque. c'est une contrainte d'intégrité, ça sert à éviter d'avoir des données incomplètes dans la base.

### 3. que se passe-t-il quand un attribut est de type erroné ? pourquoi ?

on a testé en mettant du texte dans le salaire :

```sql
insert into employe (id_employe, nom, prenom, date_naissance, salaire, id_entreprise)
values (111, 'Test', 'Test', '1990-01-01', 'beaucoup', 1);
```

là aussi l'insertion est refusée :

```
invalid input syntax for type integer: "beaucoup"
```

pourquoi : salaire est déclaré en `integer`. le sgbd essaie de convertir 'beaucoup' en entier, il n'y arrive pas, donc il rejette la ligne.

par contre, dans l'autre sens ça passe : si on met un nombre dans une colonne texte (genre 123 dans nom), postgresql le convertit tout seul en '123'. pareil si on met '30000' entre guillemets dans salaire, il arrive à le convertir en entier. en fait, le sgbd refuse seulement quand la conversion vers le type de la colonne est impossible.

## exercice 3 : interrogation de la base de données

### 1. sélectionner les noms et les prénoms différents de chaque employé

```sql
select distinct nom, prenom from employe order by nom;
```

réponse : les 10 employés ressortent, sans doublon. sara benali, inès bernard, aminata diallo, hugo dupont, yasmine el amrani, nora leroy, lucas martin, yanis moreau, adam petit et lina roux.

### 2. trouver les employés de l'entreprise « atlas distribution »

```sql
select e.nom, e.prenom
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where lower(en.nom) = 'atlas distribution';
```

réponse : sara benali, lucas martin, inès bernard et yanis moreau.

### 3. quels sont les employés nés après 2020 ?

```sql
select nom, prenom, date_naissance
from employe
where extract(year from date_naissance) > 2020;
```

réponse : aucun. la plus jeune (lina roux) est née en 2001, donc la requête ne renvoie rien.

### 4. quels sont les employés qui ont la qualité de manager ?

```sql
select nom, prenom
from employe
where id_employe in (select id_manager from diriger);
```

réponse : sara benali, yasmine el amrani, inès bernard et yanis moreau.

### 5. quel est le salaire moyen des salariés ? et par entreprise ?

```sql
select round(avg(salaire), 2) as salaire_moyen from employe;
```

```sql
select en.nom as entreprise, round(avg(e.salaire), 2) as salaire_moyen
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
group by en.nom
order by en.nom;
```

réponse : le salaire moyen est de 37 650 €. par entreprise :

| entreprise | salaire moyen |
|---|---|
| atlas distribution | 41 125 |
| greenmarket | 29 166,67 |
| nordtech | 41 500 |

### 6. retourner une liste (une colonne) avec le nom complet de chacun des employés et leur salaire

```sql
select concat(prenom, ' ', nom, ' : ', salaire) as employe_salaire
from employe;
```

réponse :

| employe_salaire |
|---|
| sara benali : 42000 |
| lucas martin : 38500 |
| yasmine el amrani : 55000 |
| hugo dupont : 29000 |
| aminata diallo : 33500 |
| inès bernard : 41000 |
| adam petit : 30500 |
| nora leroy : 36000 |
| yanis moreau : 43000 |
| lina roux : 28000 |

### 7. quel est le nombre des employés dirigés par manager ? la moyenne ?

```sql
select m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m on m.id_employe = d.id_manager
group by m.id_employe, m.nom, m.prenom
order by nb_diriges desc;
```

```sql
select round(avg(nb_diriges), 2) as moyenne_diriges
from (select count(*) as nb_diriges from diriger group by id_manager) t;
```

réponse : yanis moreau dirige 3 personnes, sara benali 2, yasmine el amrani 2 et inès bernard 1. en moyenne, un manager dirige 2 personnes.

### 8. quel est le nom et l'âge de chacun des employés ?

```sql
select nom, prenom, extract(year from age(date_naissance)) as age
from employe;
```

réponse (âges calculés le 20/10/2026) :

| employé | âge |
|---|---|
| sara benali | 28 |
| lucas martin | 33 |
| yasmine el amrani | 31 |
| hugo dupont | 26 |
| aminata diallo | 28 |
| inès bernard | 32 |
| adam petit | 27 |
| nora leroy | 30 |
| yanis moreau | 33 |
| lina roux | 25 |

### 9. quels sont les employés n'ayant jamais eu la qualité de manager ?

```sql
select nom, prenom
from employe
where id_employe not in (select id_manager from diriger);
```

réponse : lucas martin, hugo dupont, aminata diallo, adam petit, nora leroy et lina roux.

### 10. quel est le nombre moyen d'employés dirigés par entreprise ?

on compte combien d'employés de chaque entreprise sont dirigés par quelqu'un, puis on fait la moyenne sur les 3 entreprises.

```sql
select en.nom as entreprise, count(d.id_dirige) as nb_diriges
from entreprise en
join employe e on e.id_entreprise = en.id_entreprise
left join diriger d on d.id_dirige = e.id_employe
group by en.nom
order by en.nom;
```

```sql
select round(avg(nb_diriges), 2) as moyenne_diriges
from (select e.id_entreprise, count(d.id_dirige) as nb_diriges
      from employe e
      left join diriger d on d.id_dirige = e.id_employe
      group by e.id_entreprise) t;
```

réponse : il y a 3 employés dirigés chez atlas distribution, 3 chez greenmarket et 2 chez nordtech, donc en moyenne 2,67 employés dirigés par entreprise.

### 11. trouver le nom complet des managers, leurs n-1 et la date de prise en charge

```sql
select concat(m.prenom, ' ', m.nom) as manager,
       concat(n.prenom, ' ', n.nom) as n_moins_1,
       d.date as date_prise_en_charge
from diriger d
join employe m on m.id_employe = d.id_manager
join employe n on n.id_employe = d.id_dirige
order by manager, d.date;
```

réponse :

| manager | n-1 | date de prise en charge |
|---|---|---|
| inès bernard | hugo dupont | 2024-03-01 |
| sara benali | inès bernard | 2022-01-10 |
| sara benali | lucas martin | 2022-01-10 |
| yanis moreau | sara benali | 2023-02-15 |
| yanis moreau | lina roux | 2024-04-12 |
| yanis moreau | adam petit | 2024-04-12 |
| yasmine el amrani | aminata diallo | 2023-06-01 |
| yasmine el amrani | nora leroy | 2023-06-01 |

### 12. quel est le salaire moyen des managers ? des autres ?

```sql
select case when id_employe in (select id_manager from diriger)
            then 'manager' else 'autre' end as statut,
       round(avg(salaire), 2) as salaire_moyen
from employe
group by statut;
```

réponse : 45 250 € pour les managers et 32 583,33 € pour les autres.

### 13. quelle est l'entreprise avec la personne la plus âgée ? avec la personne prenant en charge le plus de personnes ?

```sql
select en.nom as entreprise, e.nom, e.prenom, e.date_naissance
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.date_naissance = (select min(date_naissance) from employe);
```

```sql
select en.nom as entreprise, m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m     on m.id_employe     = d.id_manager
join entreprise en on en.id_entreprise = m.id_entreprise
group by en.nom, m.id_employe, m.nom, m.prenom
having count(*) >= all (select count(*) from diriger group by id_manager);
```

réponse : dans les deux cas, c'est atlas distribution. la personne la plus âgée est lucas martin (né le 03/11/1992), et celle qui prend en charge le plus de personnes est yanis moreau (3 personnes).

### 14. sélectionner les managers prenant plus d'une personne en charge

```sql
select m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m on m.id_employe = d.id_manager
group by m.id_employe, m.nom, m.prenom
having count(*) > 1;
```

réponse : sara benali (2), yasmine el amrani (2) et yanis moreau (3).

### 15. donner le salaire de chaque employé en pourcentage des salaires présents dans la bdd

```sql
select nom, prenom, salaire,
       round(salaire * 100.0 / sum(salaire) over (), 2) as pourcentage
from employe;
```

réponse :

| employé | salaire | % |
|---|---|---|
| sara benali | 42000 | 11,16 |
| lucas martin | 38500 | 10,23 |
| yasmine el amrani | 55000 | 14,61 |
| hugo dupont | 29000 | 7,70 |
| aminata diallo | 33500 | 8,90 |
| inès bernard | 41000 | 10,89 |
| adam petit | 30500 | 8,10 |
| nora leroy | 36000 | 9,56 |
| yanis moreau | 43000 | 11,42 |
| lina roux | 28000 | 7,44 |

### 16. donner le salaire de chaque employé en pourcentage sur les salaires de leurs entreprises

```sql
select en.nom as entreprise, e.nom, e.prenom, e.salaire,
       round(e.salaire * 100.0 / sum(e.salaire) over (partition by e.id_entreprise), 2) as pourcentage
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
order by en.nom;
```

réponse :

| entreprise | employé | salaire | % |
|---|---|---|---|
| atlas distribution | sara benali | 42000 | 25,53 |
| atlas distribution | lucas martin | 38500 | 23,40 |
| atlas distribution | inès bernard | 41000 | 24,92 |
| atlas distribution | yanis moreau | 43000 | 26,14 |
| greenmarket | hugo dupont | 29000 | 33,14 |
| greenmarket | lina roux | 28000 | 32,00 |
| greenmarket | adam petit | 30500 | 34,86 |
| nordtech | aminata diallo | 33500 | 26,91 |
| nordtech | nora leroy | 36000 | 28,92 |
| nordtech | yasmine el amrani | 55000 | 44,18 |

### 17. trouver les salariés les mieux payés par entreprise

```sql
select en.nom as entreprise, e.nom, e.prenom, e.salaire
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.salaire = (select max(e2.salaire) from employe e2
                   where e2.id_entreprise = e.id_entreprise)
order by en.nom;
```

réponse : yanis moreau chez atlas distribution (43 000 €), adam petit chez greenmarket (30 500 €) et yasmine el amrani chez nordtech (55 000 €).

### 18. afficher les entreprises qui ont au moins trois salariés gagnant plus de 35k

```sql
select en.nom as entreprise, count(*) as nb_salaries_plus_35k
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.salaire > 35000
group by en.nom
having count(*) >= 3;
```

réponse : seulement atlas distribution, avec 4 salariés au-dessus de 35k.
