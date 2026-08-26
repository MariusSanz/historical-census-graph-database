// ALTERNATIVE GRAPH SCHEMA - DATA INGESTION

// 0. Constraints and indexes for the alternative schema
CREATE CONSTRAINT individu_v2_id IF NOT EXISTS
FOR (i:IndividuV2)
REQUIRE i.id IS UNIQUE;

CREATE CONSTRAINT habitatge_v2_id IF NOT EXISTS
FOR (h:HabitatgeV2)
REQUIRE h.id_habitatge IS UNIQUE;

CREATE CONSTRAINT municipi_v2_codi IF NOT EXISTS
FOR (m:Municipi)
REQUIRE m.codi IS UNIQUE;

CREATE CONSTRAINT padro_v2_id IF NOT EXISTS
FOR (p:Padro)
REQUIRE p.id_padro IS UNIQUE;

CREATE CONSTRAINT carrer_v2_id IF NOT EXISTS
FOR (c:Carrer)
REQUIRE c.id_carrer IS UNIQUE;

CREATE INDEX individu_v2_nom IF NOT EXISTS
FOR (i:IndividuV2)
ON (i.nom);

CREATE INDEX individu_v2_cognoms IF NOT EXISTS
FOR (i:IndividuV2)
ON (i.cognom1, i.cognom2);

CREATE INDEX padro_v2_any IF NOT EXISTS
FOR (p:Padro)
ON (p.any_padro);

CREATE INDEX carrer_v2_nom IF NOT EXISTS
FOR (c:Carrer)
ON (c.nom);

// 1. Load individuals
LOAD CSV WITH HEADERS FROM 'file:///INDIVIDUAL.csv' AS row
WITH row
WHERE row.Id IS NOT NULL
  AND trim(toString(row.Id)) <> ''
  AND NOT toLower(trim(toString(row.Id))) IN ['null', 'nan']
  AND row.Year IS NOT NULL
  AND trim(toString(row.Year)) <> ''
  AND NOT toLower(trim(toString(row.Year))) IN ['null', 'nan']

MERGE (i:IndividuV2 {id: toInteger(row.Id)})
SET
    i.any_padro = toInteger(row.Year),

    i.nom =
        CASE
            WHEN row.name IS NULL OR trim(toString(row.name)) = '' OR toLower(trim(toString(row.name))) IN ['null', 'nan']
            THEN null
            ELSE toLower(trim(toString(row.name)))
        END,

    i.cognom1 =
        CASE
            WHEN row.surname IS NULL OR trim(toString(row.surname)) = '' OR toLower(trim(toString(row.surname))) IN ['null', 'nan']
            THEN null
            ELSE toLower(trim(toString(row.surname)))
        END,

    i.cognom2 =
        CASE
            WHEN row.second_surname IS NULL OR trim(toString(row.second_surname)) = '' OR toLower(trim(toString(row.second_surname))) IN ['null', 'nan']
            THEN null
            ELSE toLower(trim(toString(row.second_surname)))
        END;

// 2. Load municipalities, census records and households
LOAD CSV WITH HEADERS FROM 'file:///HABITATGES.csv' AS row
WITH row
WHERE row.Municipi IS NOT NULL
  AND trim(toString(row.Municipi)) <> ''
  AND NOT toLower(trim(toString(row.Municipi))) IN ['null', 'nan']
  AND row.Id_Llar IS NOT NULL
  AND trim(toString(row.Id_Llar)) <> ''
  AND NOT toLower(trim(toString(row.Id_Llar))) IN ['null', 'nan']
  AND row.Any_Padro IS NOT NULL
  AND trim(toString(row.Any_Padro)) <> ''
  AND NOT toLower(trim(toString(row.Any_Padro))) IN ['null', 'nan']

WITH
    row,
    toUpper(trim(toString(row.Municipi))) AS municipi,
    toInteger(row.Id_Llar) AS id_llar,
    toInteger(row.Any_Padro) AS any_padro

MERGE (m:Municipi {codi: municipi})
SET m.nom =
    CASE municipi
        WHEN 'CR' THEN 'Castellví de Rosanes'
        WHEN 'SFLL' THEN 'Sant Feliu de Llobregat'
        ELSE municipi
    END

MERGE (p:Padro {id_padro: municipi + '_' + toString(any_padro)})
SET
    p.any_padro = any_padro,
    p.municipi = municipi

MERGE (m)-[:TE_PADRO]->(p)

MERGE (h:HabitatgeV2 {
    id_habitatge: municipi + '_' + toString(any_padro) + '_' + toString(id_llar)
})
SET
    h.id_llar = id_llar,
    h.municipi = municipi,
    h.any_padro = any_padro,
    h.numero =
        CASE
            WHEN row.Numero IS NULL OR trim(toString(row.Numero)) = '' OR toLower(trim(toString(row.Numero))) IN ['null', 'nan']
            THEN null
            ELSE toInteger(toFloat(row.Numero))
        END

MERGE (p)-[:CONTE_HABITATGE]->(h);

// 3. Load streets and household-street
LOAD CSV WITH HEADERS FROM 'file:///HABITATGES.csv' AS row
WITH row
WHERE row.Municipi IS NOT NULL
  AND trim(toString(row.Municipi)) <> ''
  AND NOT toLower(trim(toString(row.Municipi))) IN ['null', 'nan']
  AND row.Id_Llar IS NOT NULL
  AND trim(toString(row.Id_Llar)) <> ''
  AND NOT toLower(trim(toString(row.Id_Llar))) IN ['null', 'nan']
  AND row.Any_Padro IS NOT NULL
  AND trim(toString(row.Any_Padro)) <> ''
  AND NOT toLower(trim(toString(row.Any_Padro))) IN ['null', 'nan']
  AND row.Carrer IS NOT NULL
  AND trim(toString(row.Carrer)) <> ''
  AND NOT toLower(trim(toString(row.Carrer))) IN ['null', 'nan']

WITH
    toUpper(trim(toString(row.Municipi))) AS municipi,
    toInteger(row.Id_Llar) AS id_llar,
    toInteger(row.Any_Padro) AS any_padro,
    toLower(trim(toString(row.Carrer))) AS carrer

MATCH (h:HabitatgeV2 {
    id_habitatge: municipi + '_' + toString(any_padro) + '_' + toString(id_llar)
})

MERGE (c:Carrer {id_carrer: municipi + '_' + carrer})
SET
    c.nom = carrer,
    c.municipi = municipi

MERGE (h)-[:SITUAT_A]->(c);

// 4. Load VIU_A and APAREIX_EN residence relationships
LOAD CSV WITH HEADERS FROM 'file:///VIU.csv' AS row
WITH row
WHERE row.IND IS NOT NULL
  AND trim(toString(row.IND)) <> ''
  AND NOT toLower(trim(toString(row.IND))) IN ['null', 'nan']
  AND row.Location IS NOT NULL
  AND trim(toString(row.Location)) <> ''
  AND NOT toLower(trim(toString(row.Location))) IN ['null', 'nan']
  AND row.Year IS NOT NULL
  AND trim(toString(row.Year)) <> ''
  AND NOT toLower(trim(toString(row.Year))) IN ['null', 'nan']
  AND row.HOUSE_ID IS NOT NULL
  AND trim(toString(row.HOUSE_ID)) <> ''
  AND NOT toLower(trim(toString(row.HOUSE_ID))) IN ['null', 'nan']

WITH
    toInteger(row.IND) AS id_individu,
    toUpper(trim(toString(row.Location))) AS municipi,
    toInteger(row.Year) AS any_padro,
    toInteger(row.HOUSE_ID) AS id_llar

MATCH (i:IndividuV2 {id: id_individu})
MATCH (h:HabitatgeV2 {
    id_habitatge: municipi + '_' + toString(any_padro) + '_' + toString(id_llar)
})
MATCH (p:Padro {
    id_padro: municipi + '_' + toString(any_padro)
})

MERGE (i)-[r:VIU_A]->(h)
SET
    r.municipi = municipi,
    r.any_padro = any_padro

MERGE (i)-[:APAREIX_EN]->(p);

// 5. Load FAMILIA_AMB residence relationships
LOAD CSV WITH HEADERS FROM 'file:///FAMILIA.csv' AS row
WITH row
WHERE row.ID_1 IS NOT NULL
  AND trim(toString(row.ID_1)) <> ''
  AND NOT toLower(trim(toString(row.ID_1))) IN ['null', 'nan']
  AND row.ID_2 IS NOT NULL
  AND trim(toString(row.ID_2)) <> ''
  AND NOT toLower(trim(toString(row.ID_2))) IN ['null', 'nan']

WITH
    row,
    toInteger(row.ID_1) AS id_1,
    toInteger(row.ID_2) AS id_2

MATCH (i1:IndividuV2 {id: id_1})
MATCH (i2:IndividuV2 {id: id_2})

MERGE (i1)-[r:FAMILIA_AMB]->(i2)
SET
    r.relacio_original =
        CASE
            WHEN row.Relacio IS NULL OR trim(toString(row.Relacio)) = '' OR toLower(trim(toString(row.Relacio))) IN ['null', 'nan']
            THEN null
            ELSE toLower(trim(toString(row.Relacio)))
        END,

    r.relacio_harmonitzada =
        CASE
            WHEN row.Relacio_Harmonitzada IS NULL OR trim(toString(row.Relacio_Harmonitzada)) = '' OR toLower(trim(toString(row.Relacio_Harmonitzada))) IN ['null', 'nan']
            THEN null
            ELSE toLower(trim(toString(row.Relacio_Harmonitzada)))
        END;

// 6. Load SAME_AS_V2 residence relationships
LOAD CSV WITH HEADERS FROM 'file:///SAME_AS.csv' AS row
WITH row
WHERE row.Id_A IS NOT NULL
  AND trim(toString(row.Id_A)) <> ''
  AND NOT toLower(trim(toString(row.Id_A))) IN ['null', 'nan']
  AND row.Id_B IS NOT NULL
  AND trim(toString(row.Id_B)) <> ''
  AND NOT toLower(trim(toString(row.Id_B))) IN ['null', 'nan']

WITH
    toInteger(row.Id_A) AS id_a,
    toInteger(row.Id_B) AS id_b

MATCH (a:IndividuV2 {id: id_a})
MATCH (b:IndividuV2 {id: id_b})

MERGE (a)-[:SAME_AS_V2]->(b);