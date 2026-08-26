MATCH (m:Municipi {codi: 'SFLL'})-[:TE_PADRO]->(p:Padro {any_padro: 1881})
MATCH (p)-[:CONTE_HABITATGE]->(h:HabitatgeV2)<-[:VIU_A]-(i:IndividuV2)
MATCH (h)-[:SITUAT_A]->(c:Carrer)

RETURN
    c.nom AS carrer,
    count(DISTINCT i) AS habitants,
    count(DISTINCT h) AS habitatges

ORDER BY habitants DESC, carrer ASC
LIMIT 10;