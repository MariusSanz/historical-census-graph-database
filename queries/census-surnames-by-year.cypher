MATCH (i:Individu)-[:VIU]->(h:Habitatge)
WHERE h.municipi = 'CR'
WITH 
    h.any_padro AS any_padro,
    count(DISTINCT i) AS habitants,
    collect(DISTINCT i.cognom1) + collect(DISTINCT i.cognom2) AS cognoms_raw

UNWIND cognoms_raw AS cognom_original

WITH 
    any_padro,
    habitants,
    CASE
        WHEN cognom_original IS NULL THEN NULL
        ELSE toLower(trim(toString(cognom_original)))
    END AS cognom

WHERE cognom IS NOT NULL
  AND cognom <> ''
  AND NOT cognom IN ['nan', 'null', 'true', 'false']

WITH 
    any_padro,
    habitants,
    collect(DISTINCT cognom) AS cognoms

RETURN 
    any_padro,
    habitants,
    cognoms

ORDER BY any_padro;