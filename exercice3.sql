select distinct nom, prenom from employe order by nom;

select e.nom, e.prenom
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where lower(en.nom) = 'atlas distribution';

select nom, prenom, date_naissance
from employe
where extract(year from date_naissance) > 2020;

select nom, prenom
from employe
where id_employe in (select id_manager from diriger);

select round(avg(salaire), 2) as salaire_moyen from employe;

select en.nom as entreprise, round(avg(e.salaire), 2) as salaire_moyen
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
group by en.nom
order by en.nom;

select concat(prenom, ' ', nom, ' : ', salaire) as employe_salaire
from employe;

select m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m on m.id_employe = d.id_manager
group by m.id_employe, m.nom, m.prenom
order by nb_diriges desc;

select round(avg(nb_diriges), 2) as moyenne_diriges
from (select count(*) as nb_diriges from diriger group by id_manager) t;

select nom, prenom, extract(year from age(date_naissance)) as age
from employe;

select nom, prenom
from employe
where id_employe not in (select id_manager from diriger);

select en.nom as entreprise, count(d.id_dirige) as nb_diriges
from entreprise en
join employe e on e.id_entreprise = en.id_entreprise
left join diriger d on d.id_dirige = e.id_employe
group by en.nom
order by en.nom;

select round(avg(nb_diriges), 2) as moyenne_diriges
from (select e.id_entreprise, count(d.id_dirige) as nb_diriges
      from employe e
      left join diriger d on d.id_dirige = e.id_employe
      group by e.id_entreprise) t;

select concat(m.prenom, ' ', m.nom) as manager,
       concat(n.prenom, ' ', n.nom) as n_moins_1,
       d.date as date_prise_en_charge
from diriger d
join employe m on m.id_employe = d.id_manager
join employe n on n.id_employe = d.id_dirige
order by manager, d.date;

select case when id_employe in (select id_manager from diriger)
            then 'manager' else 'autre' end as statut,
       round(avg(salaire), 2) as salaire_moyen
from employe
group by statut;

select en.nom as entreprise, e.nom, e.prenom, e.date_naissance
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.date_naissance = (select min(date_naissance) from employe);

select en.nom as entreprise, m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m     on m.id_employe     = d.id_manager
join entreprise en on en.id_entreprise = m.id_entreprise
group by en.nom, m.id_employe, m.nom, m.prenom
having count(*) >= all (select count(*) from diriger group by id_manager);

select m.nom, m.prenom, count(*) as nb_diriges
from diriger d
join employe m on m.id_employe = d.id_manager
group by m.id_employe, m.nom, m.prenom
having count(*) > 1;

select nom, prenom, salaire,
       round(salaire * 100.0 / sum(salaire) over (), 2) as pourcentage
from employe;

select en.nom as entreprise, e.nom, e.prenom, e.salaire,
       round(e.salaire * 100.0 / sum(e.salaire) over (partition by e.id_entreprise), 2) as pourcentage
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
order by en.nom;

select en.nom as entreprise, e.nom, e.prenom, e.salaire
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.salaire = (select max(e2.salaire) from employe e2
                   where e2.id_entreprise = e.id_entreprise)
order by en.nom;

select en.nom as entreprise, count(*) as nb_salaries_plus_35k
from employe e
join entreprise en on en.id_entreprise = e.id_entreprise
where e.salaire > 35000
group by en.nom
having count(*) >= 3;
