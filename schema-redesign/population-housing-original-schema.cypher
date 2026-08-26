MATCH (i:Individu)-[:VIU]->(h:Habitatge)

RETURN
    h.municipi AS municipi,
    h.any_padro AS any_padro,
    count(DISTINCT i) AS habitants,
    count(DISTINCT h) AS habitatges

ORDER BY municipi ASC, any_padro ASC;