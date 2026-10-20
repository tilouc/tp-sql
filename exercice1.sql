-- =====================================================================
-- TP SQL - Exercice 1 : Création d'une base de données
-- SGBD : PostgreSQL (en ligne, hébergé sur Supabase)
-- =====================================================================

-- 1. Créer un serveur
--    Sur Supabase, un projet = un serveur PostgreSQL. Le projet
--    « entreprise » a été créé (région eu-west-3, Paris).

-- 2. Créer une base de données « entreprise »
--    En local (pgAdmin / psql), on exécuterait :
--        CREATE DATABASE entreprise;
--    Sur Supabase, chaque projet possède déjà sa base de données :
--    c'est la base du projet « entreprise » qui est utilisée.

-- 3. Création des tables depuis l'outil « Query » (SQL Editor)
--    a. noms et types des attributs
--    b. clés primaires (PRIMARY KEY) et étrangères (REFERENCES)
--    c. attributs qui ne doivent pas être vides (NOT NULL)

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

-- 4. Clé primaire de « Diriger » : clé composée (id_manager, id_dirige),
--    définie au niveau de la table avec PRIMARY KEY (col1, col2).
CREATE TABLE diriger (
    id_manager INTEGER NOT NULL REFERENCES employe (id_employe),
    id_dirige  INTEGER NOT NULL REFERENCES employe (id_employe),
    date       DATE    NOT NULL,
    PRIMARY KEY (id_manager, id_dirige)
);
