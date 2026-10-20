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
