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
