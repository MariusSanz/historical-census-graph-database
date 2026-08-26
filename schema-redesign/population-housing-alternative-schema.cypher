MATCH (m:Municipi)-[:TE_PADRO]->(p:Padro)-[:CONTE_HABITATGE]->(h:HabitatgeV2)
OPTIONAL MATCH (i:IndividuV2)-[:VIU_A]->(h)

RETURN
    m.codi AS municipi,
    p.any_padro AS any_padro,
    count(DISTINCT i) AS habitants,
    count(DISTINCT h) AS habitatges

ORDER BY municipi ASC, any_padro ASC;