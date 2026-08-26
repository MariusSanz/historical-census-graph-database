MATCH (cap:Individu)-[:VIU]->(h:Habitatge)
WHERE h.municipi = 'CR'

MATCH (cap)-[r:FAMILIA]->(fill:Individu)
WHERE r.relacio_harmonitzada STARTS WITH 'fill'

WITH 
    cap,
    count(DISTINCT fill) AS nombre_fills

WHERE nombre_fills > 3

RETURN
    cap.nom AS nom_cap_familia,
    cap.cognom1 AS cognom1,
    cap.cognom2 AS cognom2,
    cap.any_padro AS any_padro,
    nombre_fills

ORDER BY nombre_fills DESC, cognom1, nom_cap_familia
LIMIT 20;