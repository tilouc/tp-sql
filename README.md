# TP SQL

## Exercice 1

### 2

```sql
CREATE DATABASE entreprise;
```

### 3

```sql
CREATE TABLE entreprise (
    id_entreprise INTEGER      PRIMARY KEY,
    nom           VARCHAR(100) NOT NULL,
    date_creation DATE         NOT NULL
);

CREATE TABLE employe (
    id_employe     INTEGER      PRIMARY KEY,
    nom            VARCHAR(100) NOT NULL,
    prenom         VARCHAR(100) NOT NULL,
    date_naissance DATE         NOT NULL,
    salaire        INTEGER      NOT NULL,
    id_entreprise  INTEGER      NOT NULL REFERENCES entreprise (id_entreprise)
);

CREATE TABLE diriger (
    id_manager INTEGER NOT NULL REFERENCES employe (id_employe),
    id_dirige  INTEGER NOT NULL REFERENCES employe (id_employe),
    date       DATE    NOT NULL,
    PRIMARY KEY (id_manager, id_dirige)
);
```

### 4

```sql
PRIMARY KEY (id_manager, id_dirige)
```

## Exercice 2

### 1

```sql
INSERT INTO entreprise (id_entreprise, nom, date_creation) VALUES
    (1, 'Atlas Distribution', '2015-03-12'),
    (2, 'NordTech',           '2018-09-24'),
    (3, 'GreenMarket',        '2021-01-08');

INSERT INTO employe (id_employe, nom, prenom, date_naissance, salaire, id_entreprise) VALUES
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

INSERT INTO diriger (id_manager, id_dirige, date) VALUES
    (101, 102, '2022-01-10'),
    (101, 106, '2022-01-10'),
    (109, 101, '2023-02-15'),
    (103, 105, '2023-06-01'),
    (103, 108, '2023-06-01'),
    (106, 104, '2024-03-01'),
    (109, 107, '2024-04-12'),
    (109, 110, '2024-04-12');
```

### 2

```sql
INSERT INTO employe (id_employe, nom, date_naissance, salaire, id_entreprise)
VALUES (111, 'Test', '1990-01-01', 30000, 1);
```

### 3

```sql
INSERT INTO employe (id_employe, nom, prenom, date_naissance, salaire, id_entreprise)
VALUES (111, 'Test', 'Test', '1990-01-01', 'beaucoup', 1);
```

## Exercice 3

### 1

```sql
SELECT DISTINCT nom, prenom FROM employe ORDER BY nom;
```

### 2

```sql
SELECT e.nom, e.prenom
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE en.nom = 'Atlas Distribution';
```

### 3

```sql
SELECT nom, prenom, date_naissance
FROM employe
WHERE EXTRACT(YEAR FROM date_naissance) > 2020;
```

### 4

```sql
SELECT nom, prenom
FROM employe
WHERE id_employe IN (SELECT id_manager FROM diriger);
```

### 5

```sql
SELECT ROUND(AVG(salaire), 2) AS salaire_moyen FROM employe;
```

```sql
SELECT en.nom AS entreprise, ROUND(AVG(e.salaire), 2) AS salaire_moyen
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;
```

### 6

```sql
SELECT CONCAT(prenom, ' ', nom, ' : ', salaire) AS employe_salaire
FROM employe;
```

### 7

```sql
SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
ORDER BY nb_diriges DESC;
```

```sql
SELECT ROUND(AVG(nb_diriges), 2) AS moyenne_diriges
FROM (SELECT COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t;
```

### 8

```sql
SELECT nom, prenom, EXTRACT(YEAR FROM AGE(date_naissance)) AS age
FROM employe;
```

### 9

```sql
SELECT nom, prenom
FROM employe
WHERE id_employe NOT IN (SELECT id_manager FROM diriger);
```

### 10

```sql
SELECT en.nom AS entreprise, ROUND(AVG(t.nb_diriges), 2) AS moyenne_diriges
FROM (SELECT id_manager, COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t
JOIN employe m     ON m.id_employe     = t.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;
```

### 11

```sql
SELECT CONCAT(m.prenom, ' ', m.nom) AS manager,
       CONCAT(n.prenom, ' ', n.nom) AS n_moins_1,
       d.date AS date_prise_en_charge
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
JOIN employe n ON n.id_employe = d.id_dirige
ORDER BY manager, d.date;
```

### 12

```sql
SELECT CASE WHEN id_employe IN (SELECT id_manager FROM diriger)
            THEN 'manager' ELSE 'autre' END AS statut,
       ROUND(AVG(salaire), 2) AS salaire_moyen
FROM employe
GROUP BY statut;
```

### 13

```sql
SELECT en.nom AS entreprise, e.nom, e.prenom, e.date_naissance
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.date_naissance = (SELECT MIN(date_naissance) FROM employe);
```

```sql
SELECT en.nom AS entreprise, m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m     ON m.id_employe     = d.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom, m.id_employe, m.nom, m.prenom
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM diriger GROUP BY id_manager);
```

### 14

```sql
SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
HAVING COUNT(*) > 1;
```

### 15

```sql
SELECT nom, prenom, salaire,
       ROUND(salaire * 100.0 / SUM(salaire) OVER (), 2) AS pourcentage
FROM employe;
```

### 16

```sql
SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire,
       ROUND(e.salaire * 100.0 / SUM(e.salaire) OVER (PARTITION BY e.id_entreprise), 2) AS pourcentage
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
ORDER BY en.nom;
```

### 17

```sql
SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire = (SELECT MAX(e2.salaire) FROM employe e2
                   WHERE e2.id_entreprise = e.id_entreprise)
ORDER BY en.nom;
```

### 18

```sql
SELECT en.nom AS entreprise, COUNT(*) AS nb_salaries_plus_35k
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire > 35000
GROUP BY en.nom
HAVING COUNT(*) >= 3;
```
