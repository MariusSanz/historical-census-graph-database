MATCH (i:Individu)-[:VIU]->(h:Habitatge)
WHERE h.municipi = 'SFLL'
  AND h.carrer IS NOT NULL
  AND trim(toString(h.carrer)) <> ''

WITH 
    h.any_padro AS any_padro,
    h.carrer AS carrer,
    count(DISTINCT i) AS habitants

CALL (any_padro) {
    WITH any_padro

    MATCH (i2:Individu)-[:VIU]->(h2:Habitatge)
    WHERE h2.municipi = 'SFLL'
      AND h2.any_padro = any_padro
      AND h2.carrer IS NOT NULL
      AND trim(toString(h2.carrer)) <> ''

    WITH 
        h2.carrer AS carrer2,
        count(DISTINCT i2) AS habitants2

    RETURN min(habitants2) AS min_habitants
}

WITH 
    any_padro,
    carrer,
    habitants,
    min_habitants

WHERE habitants = min_habitants

RETURN
    any_padro,
    carrer,
    habitants

ORDER BY any_padro ASC, carrer ASC;