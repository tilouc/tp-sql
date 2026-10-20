SELECT DISTINCT nom, prenom FROM employe ORDER BY nom;

SELECT e.nom, e.prenom
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE en.nom = 'Atlas Distribution';

SELECT nom, prenom, date_naissance
FROM employe
WHERE EXTRACT(YEAR FROM date_naissance) > 2020;

SELECT nom, prenom
FROM employe
WHERE id_employe IN (SELECT id_manager FROM diriger);

SELECT ROUND(AVG(salaire), 2) AS salaire_moyen FROM employe;

SELECT en.nom AS entreprise, ROUND(AVG(e.salaire), 2) AS salaire_moyen
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;

SELECT CONCAT(prenom, ' ', nom, ' : ', salaire) AS employe_salaire
FROM employe;

SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
ORDER BY nb_diriges DESC;

SELECT ROUND(AVG(nb_diriges), 2) AS moyenne_diriges
FROM (SELECT COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t;

SELECT nom, prenom, EXTRACT(YEAR FROM AGE(date_naissance)) AS age
FROM employe;

SELECT nom, prenom
FROM employe
WHERE id_employe NOT IN (SELECT id_manager FROM diriger);

SELECT en.nom AS entreprise, ROUND(AVG(t.nb_diriges), 2) AS moyenne_diriges
FROM (SELECT id_manager, COUNT(*) AS nb_diriges FROM diriger GROUP BY id_manager) t
JOIN employe m     ON m.id_employe     = t.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom
ORDER BY en.nom;

SELECT CONCAT(m.prenom, ' ', m.nom) AS manager,
       CONCAT(n.prenom, ' ', n.nom) AS n_moins_1,
       d.date AS date_prise_en_charge
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
JOIN employe n ON n.id_employe = d.id_dirige
ORDER BY manager, d.date;

SELECT CASE WHEN id_employe IN (SELECT id_manager FROM diriger)
            THEN 'manager' ELSE 'autre' END AS statut,
       ROUND(AVG(salaire), 2) AS salaire_moyen
FROM employe
GROUP BY statut;

SELECT en.nom AS entreprise, e.nom, e.prenom, e.date_naissance
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.date_naissance = (SELECT MIN(date_naissance) FROM employe);

SELECT en.nom AS entreprise, m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m     ON m.id_employe     = d.id_manager
JOIN entreprise en ON en.id_entreprise = m.id_entreprise
GROUP BY en.nom, m.id_employe, m.nom, m.prenom
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM diriger GROUP BY id_manager);

SELECT m.nom, m.prenom, COUNT(*) AS nb_diriges
FROM diriger d
JOIN employe m ON m.id_employe = d.id_manager
GROUP BY m.id_employe, m.nom, m.prenom
HAVING COUNT(*) > 1;

SELECT nom, prenom, salaire,
       ROUND(salaire * 100.0 / SUM(salaire) OVER (), 2) AS pourcentage
FROM employe;

SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire,
       ROUND(e.salaire * 100.0 / SUM(e.salaire) OVER (PARTITION BY e.id_entreprise), 2) AS pourcentage
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
ORDER BY en.nom;

SELECT en.nom AS entreprise, e.nom, e.prenom, e.salaire
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire = (SELECT MAX(e2.salaire) FROM employe e2
                   WHERE e2.id_entreprise = e.id_entreprise)
ORDER BY en.nom;

SELECT en.nom AS entreprise, COUNT(*) AS nb_salaries_plus_35k
FROM employe e
JOIN entreprise en ON en.id_entreprise = e.id_entreprise
WHERE e.salaire > 35000
GROUP BY en.nom
HAVING COUNT(*) >= 3;
