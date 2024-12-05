-- A partir du script SQL Gaulois fourni par votre formateur,
-- écrivez et exécutez les requêtes SQL suivantes:

-- 1. Nom des lieux qui finissent par 'um'.
    SELECT nom_lieu
    FROM lieu
    WHERE nom_lieu
    LIKE "%um";

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).
    SELECT l.nom_lieu, COUNT(p.id_personnage) AS nombre_habitant
    FROM personnage p
    INNER JOIN lieu l
    ON p.id_lieu = l.id_lieu
    GROUP BY l.id_lieu
    ORDER BY nombre_habitant DESC;

-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation,
-- triés par lieu puis par nom de personnage.
    SELECT p.nom_personnage, s.nom_specialite, p.adresse_personnage, l.nom_lieu
    FROM personnage p
    INNER JOIN specialite s
    ON p.id_specialite = s.id_specialite
    INNER JOIN lieu l
    ON p.id_lieu = l.id_lieu
    ORDER BY l.nom_lieu, p.nom_personnage;


-- 4. Nom des spécialités avec nombre de personnages par spécialité
-- (trié par nombre de personnages décroissant).
    SELECT s.nom_specialite, COUNT(p.id_personnage) AS nombre_specialite
    FROM personnage p
    INNER JOIN specialite s
    ON p.id_specialite = s.id_specialite
    GROUP BY s.id_specialite
    ORDER BY nombre_specialite DESC;

-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne
-- (dates affichées au format jj/mm/aaaa).
    SELECT b.nom_bataille, DATE_FORMAT(b.date_bataille, "%d/%m/%Y"), l.nom_lieu
    FROM bataille b
    INNER JOIN lieu l
    ON b.id_lieu = l.id_lieu
    ORDER BY b.date_bataille DESC;


-- 6. Nom des potions + coût de réalisation de la potion
-- (trié par coût décroissant).
    SELECT p.nom_potion, SUM(c.qte * i.cout_ingredient) AS prix
    FROM potion p
    INNER JOIN composer c
    ON p.id_potion = c.id_potion
    INNER JOIN ingredient i
    ON c.id_ingredient = i.id_ingredient
    GROUP BY p.id_potion
    ORDER BY prix DESC;

--7. Nom des ingrédients + coût + quantité de chaque ingrédient
-- qui composent la potion 'Santé'.
    SELECT i.nom_ingredient, i.cout_ingredient, c.qte
    FROM potion p
    INNER JOIN composer c
    ON p.id_potion = c.id_potion
    INNER JOIN ingredient i
    ON c.id_ingredient = i.id_ingredient
    WHERE p.nom_potion = "Santé";

-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille
-- 'Bataille du village gaulois'.
    SELECT p.nom_personnage, SUM(pc.qte) AS casque_pris
    FROM personnage p
    INNER JOIN prendre_casque pc
    ON p.id_personnage = pc.id_personnage
    INNER JOIN bataille b
    ON pc.id_bataille = b.id_bataille
    WHERE b.nom_bataille = 'Bataille du village gaulois'
    GROUP BY p.id_personnage
    HAVING casque_pris >= ALL (
        SELECT pc.qte
        FROM prendre_casque pc
        INNER JOIN bataille b
        ON pc.id_bataille = b.id_bataille
        WHERE b.nom_bataille = 'Bataille du village gaulois'
        GROUP BY pc.id_personnage
    );


-- 9. Nom des personnages et leur quantité de potion bue
-- (en les classant du plus grand buveur au plus petit).
    SELECT p.nom_personnage, SUM(b.dose_boire) AS potion_bue
    FROM personnage p
    INNER JOIN boire b
    ON p.id_personnage = b.id_personnage
    GROUP BY p.id_personnage
    ORDER BY potion_bue DESC;

-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.
    SELECT b.nom_bataille, SUM(pc.qte) AS casque_pris
    FROM bataille b
    INNER JOIN prendre_casque pc
    ON b.id_bataille = pc.id_bataille
    GROUP BY b.id_bataille
    HAVING casque_pris >= ALL (
        SELECT SUM(pc.qte)
        FROM prendre_casque pc
        GROUP BY pc.id_bataille
    );

-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ?
-- (classés par nombre décroissant)
SELECT COUNT(c.id_casque) AS nombre_casque, tc.nom_type_casque, SUM(c.cout_casque) AS cout_total
FROM type_casque tc
INNER JOIN casque c
ON tc.id_type_casque = c.id_type_casque
GROUP BY tc.id_type_casque
ORDER BY cout_total DESC;

-- 12. Nom des potions dont un des ingrédients est le poisson frais.
SELECT p.nom_potion
FROM potion p
INNER JOIN composer c
ON p.id_potion = c.id_potion
INNER JOIN ingredient i
ON c.id_ingredient = i.id_ingredient
WHERE LOWER(i.nom_ingredient) = "poisson frais";

-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.
SELECT l.nom_lieu, COUNT(p.id_lieu) AS habitants
FROM lieu l
INNER JOIN personnage p
ON l.id_lieu = p.id_lieu
WHERE LOWER(l.nom_lieu) != 'village gaulois'
GROUP BY l.id_lieu
HAVING habitants >= ALL (
    SELECT COUNT(p.id_lieu)
    FROM personnage p
    INNER JOIN lieu l
    ON p.id_lieu = l.id_lieu
    WHERE LOWER(l.nom_lieu) != 'village gaulois'
    GROUP BY l.id_lieu
);

-- 14. Nom des personnages qui n'ont jamais bu aucune potion.
SELECT p.nom_personnage
FROM personnage p
WHERE p.id_personnage
NOT IN (
    SELECT b.id_personnage
    FROM boire b
);

-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.
SELECT p.nom_personnage
FROM personnage p
WHERE p.id_personnage
NOT IN (
    SELECT ab.id_personnage
    FROM autoriser_boire ab
    INNER JOIN potion p
    ON ab.id_potion = p.id_potion
    WHERE LOWER(p.nom_potion) = 'magique'
);

-- _______________________________________________________________________________
-- En écrivant toujours des requêtes SQL, modifiez la base de données comme suit :

-- A. Ajoutez le personnage suivant :
-- Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.
INSERT INTO personnage (nom_personnage, adresse_personnage, id_lieu, id_specialite)
VALUES ("Champdeblix", "ferme Hantassion", 6, 12);
-- Rotamagus id = 6
-- Agriculteur id = 12

-- B. Autorisez Bonemine à boire de la potion magique,
-- elle est jalouse d'Iélosubmarine...
INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES (1, 12);
-- Bonemine id = 12
-- Potion magique id = 1

-- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.
DELETE FROM casque c
WHERE c.id_casque
NOT IN (
    SELECT pc.id_casque
    FROM prendre_casque pc
);

-- D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.
UPDATE personnage
SET adresse_personnage = 'Prison',
    id_lieu = (
        SELECT id_lieu
        FROM lieu
        WHERE nom_lieu = 'Condate'
    )
WHERE nom_personnage = 'Zerozerosix';

-- E. La potion 'Soupe' ne doit plus contenir de persil.
DELETE FROM composer c
WHERE c.id_ingredient = (
    SELECT i.id_ingredient
    FROM ingredient i
    WHERE i.nom_ingredient = 'Persil'
) AND c.id_potion = (
    SELECT p.id_potion
    FROM potion p
    WHERE p.nom_potion = 'Soupe'
);

-- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths
-- qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !
UPDATE prendre_casque pc
SET pc.id_casque = (
    SELECT c.id_casque
    FROM casque c
    WHERE c.nom_casque = 'Weisenau'
)
WHERE pc.id_bataille = (
    SELECT b.id_bataille
    FROM bataille b
    WHERE b.nom_bataille = 'Attaque de la banque postale'
);