-- =====================================================================
-- TP SQL - Exercice 3 : Interrogation de la base de données
-- Résultats obtenus sur la base Supabase « entreprise » (2026-10-20)
-- =====================================================================

-- 1. (*) Sélectionner les noms et les prénoms différents de chaque employé.
SELECT DISTINCT nom, prenom FROM employe ORDER BY nom;
-- Benali Sara | Bernard Inès | Diallo Aminata | Dupont Hugo
-- El Amrani Yasmine | Leroy Nora | Martin Lucas | Moreau Yanis
-- Petit Adam | Roux Lina


-- 2. (*) Trouver les employés de l'entreprise « Atlas distribution ».
SELECT e.nom, e.prenom
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE en.nom = 'Atlas Distribution';
-- Benali Sara | Martin Lucas | Bernard Inès | Moreau Yanis


-- 3. (*) Quels sont les employés nés après 2020 ?
SELECT nom, prenom, date_naissance
FROM employe
WHERE EXTRACT(YEAR FROM date_naissance) > 2020;
-- Aucun résultat (le plus jeune employé est né en 2001).


-- 4. (*) Quels sont les employés qui ont la qualité de manager ?
SELECT nom, prenom
FROM employe
WHERE id_employe IN (SELECT id_manager FROM diriger);
-- Benali Sara | El Amrani Yasmine | Bernard Inès | Moreau Yanis


-- 5. (*) Quel est le salaire moyen des salariés ? Et par entreprise ?
SELECT ROUND(AVG(salaire), 2) AS salaire_moyen FROM employe;
-- 37650.00

SELECT en.nom AS entreprise, ROUND(AVG(e.salaire), 2) AS salaire_moyen
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;
-- Atlas Distribution | 41125.00
-- GreenMarket        | 29166.67
-- NordTech           | 41500.00


-- 6. (*) Retourner une liste (une colonne) avec le nom complet de chacun
--    des employés et leur salaire.
SELECT CONCAT(prenom, ' ', nom, ' : ', salaire) AS employe_salaire
FROM employe;
-- Sara Benali : 42000
-- Lucas Martin : 38500
-- Yasmine El Amrani : 55000
-- Hugo Dupont : 29000
-- Aminata Diallo : 33500
-- Inès Bernard : 41000
-- Adam Petit : 30500
-- Nora Leroy : 36000
-- Yanis Moreau : 43000
-- Lina Roux : 28000


-- 7. (*) Quel est le nombre des employés dirigés par manager ? La moyenne ?
SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
ORDER BY nb_diriges DESC;
-- Moreau Yanis      | 3
-- Benali Sara       | 2
-- El Amrani Yasmine | 2
-- Bernard Inès      | 1

SELECT ROUND(AVG(nb_diriges), 2) AS moyenne_diriges
FROM (SELECT COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t;
-- 2.00


-- 8. (**) Quel est le nom et l'âge de chacun des employés ?
SELECT nom, prenom, EXTRACT(YEAR FROM AGE(date_naissance)) AS age
FROM employe;
-- Âges calculés au 2026-10-20 :
-- Benali Sara 28 | Martin Lucas 33 | El Amrani Yasmine 31 | Dupont Hugo 26
-- Diallo Aminata 28 | Bernard Inès 32 | Petit Adam 27 | Leroy Nora 30
-- Moreau Yanis 33 | Roux Lina 25


-- 9. (**) Quels sont les employés n'ayant jamais eu la qualité de manager ?
SELECT nom, prenom
FROM employe
WHERE id_employe NOT IN (SELECT id_manager FROM diriger);
-- Martin Lucas | Dupont Hugo | Diallo Aminata | Petit Adam
-- Leroy Nora | Roux Lina


-- 10. (**) Quel est le nombre moyen d'employés dirigés par entreprise ?
--     (moyenne du nombre de N-1 par manager, selon l'entreprise du manager)
SELECT en.nom AS entreprise, ROUND(AVG(t.nb_diriges), 2) AS moyenne_diriges
FROM (SELECT id_manager, COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t
JOIN employe m     ON m.id_employe     = t.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;
-- Atlas Distribution | 2.00
-- NordTech           | 2.00
-- (GreenMarket n'a aucun manager)


-- 11. (**) Trouver le nom complet des managers, leurs N-1 et la date de
--     prise en charge.
SELECT CONCAT(m.prenom, ' ', m.nom) AS manager,
       CONCAT(n.prenom, ' ', n.nom) AS n_moins_1,
       d.date AS date_prise_en_charge
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
JOIN employe n ON n.id_employe = d.id_dirige
ORDER BY manager, d.date;
-- Inès Bernard      | Hugo Dupont    | 2024-03-01
-- Sara Benali       | Inès Bernard   | 2022-01-10
-- Sara Benali       | Lucas Martin   | 2022-01-10
-- Yanis Moreau      | Sara Benali    | 2023-02-15
-- Yanis Moreau      | Lina Roux      | 2024-04-12
-- Yanis Moreau      | Adam Petit     | 2024-04-12
-- Yasmine El Amrani | Aminata Diallo | 2023-06-01
-- Yasmine El Amrani | Nora Leroy     | 2023-06-01


-- 12. (**) Quel est le salaire moyen des managers ? Des autres ?
SELECT CASE WHEN id_employe IN (SELECT id_manager FROM diriger)
            THEN 'manager' ELSE 'autre' END AS statut,
       ROUND(AVG(salaire), 2) AS salaire_moyen
FROM employe
GROUP BY statut;
-- manager | 45250.00
-- autre   | 32583.33


-- 13. (**) Quelle est l'entreprise avec la personne la plus âgée ?
SELECT en.nom AS entreprise, e.nom, e.prenom, e.date_naissance
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.date_naissance = (SELECT MIN(date_naissance) FROM employe);
-- Atlas Distribution | Martin Lucas | 1992-11-03

--     Avec la personne prenant en charge le plus de personnes ?
SELECT en.nom AS entreprise, m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m     ON m.id_employe     = d.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom, m.id_employe, m.nom, m.prenom
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM diriger GROUP BY id_manager);
-- Atlas Distribution | Moreau Yanis | 3


-- 14. (**) Sélectionner les managers prenant plus d'une personne en charge.
SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
HAVING COUNT(*) > 1;
-- Benali Sara       | 2
-- El Amrani Yasmine | 2
-- Moreau Yanis      | 3


-- 15. (**) Donner le salaire de chaque employé en pourcentage des salaires
--     présents dans la bdd.
SELECT nom, prenom, salaire,
       ROUND(salaire * 100.0 / SUM(salaire) OVER (), 2) AS pourcentage
FROM employe;
-- Benali Sara       | 42000 | 11.16
-- Martin Lucas      | 38500 | 10.23
-- El Amrani Yasmine | 55000 | 14.61
-- Dupont Hugo       | 29000 |  7.70
-- Diallo Aminata    | 33500 |  8.90
-- Bernard Inès      | 41000 | 10.89
-- Petit Adam        | 30500 |  8.10
-- Leroy Nora        | 36000 |  9.56
-- Moreau Yanis      | 43000 | 11.42
-- Roux Lina         | 28000 |  7.44


-- 16. (**) Donner le salaire de chaque employé en pourcentage sur les
--     salaires de leurs entreprises.
SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire,
       ROUND(e.salaire * 100.0 / SUM(e.salaire) OVER (PARTITION BY e.id_entreprise), 2) AS pourcentage
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
ORDER BY en.nom;
-- Atlas Distribution | Benali Sara       | 42000 | 25.53
-- Atlas Distribution | Martin Lucas      | 38500 | 23.40
-- Atlas Distribution | Bernard Inès      | 41000 | 24.92
-- Atlas Distribution | Moreau Yanis      | 43000 | 26.14
-- GreenMarket        | Dupont Hugo       | 29000 | 33.14
-- GreenMarket        | Roux Lina         | 28000 | 32.00
-- GreenMarket        | Petit Adam        | 30500 | 34.86
-- NordTech           | Diallo Aminata    | 33500 | 26.91
-- NordTech           | Leroy Nora        | 36000 | 28.92
-- NordTech           | El Amrani Yasmine | 55000 | 44.18


-- 17. (***) Trouver les salariés les mieux payés par entreprise.
SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire = (SELECT MAX(e2.salaire) FROM employe e2
                   WHERE e2.id_entreprise = e.id_entreprise)
ORDER BY en.nom;
-- Atlas Distribution | Moreau Yanis      | 43000
-- GreenMarket        | Petit Adam        | 30500
-- NordTech           | El Amrani Yasmine | 55000


-- 18. (***) Afficher les entreprises qui ont au moins trois salariés
--     gagnant plus de 35k.
SELECT en.nom AS entreprise, COUNT(*) AS nb_salaries_plus_35k
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire > 35000
GROUP BY en.nom
HAVING COUNT(*) >= 3;
-- Atlas Distribution | 4
