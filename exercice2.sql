-- =====================================================================
-- TP SQL - Exercice 2 : Insertion des données
-- =====================================================================

-- 1. Insertion avec INSERT INTO ... VALUES ...
--    Ordre imposé par les clés étrangères :
--    entreprise -> employe -> diriger

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

-- 2. Valeur requise non soumise (laissée vide)
INSERT INTO employe (id_employe, nom, date_naissance, salaire, id_entreprise)
VALUES (111, 'Test', '1990-01-01', 30000, 1);
-- ERREUR : null value in column "prenom" of relation "employe"
--          violates not-null constraint
-- La colonne prenom est NOT NULL : la ligne est refusée.

-- 3. Attribut de type erroné (chaîne au lieu d'un entier)
INSERT INTO employe (id_employe, nom, prenom, date_naissance, salaire, id_entreprise)
VALUES (111, 'Test', 'Test', '1990-01-01', 'beaucoup', 1);
-- ERREUR : invalid input syntax for type integer: "beaucoup"
-- salaire est de type INTEGER : la valeur ne peut pas être convertie,
-- la ligne est refusée.
