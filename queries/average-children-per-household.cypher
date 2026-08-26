CALL () {
    MATCH (h:Habitatge)
    WHERE h.municipi = 'SFLL'
      AND h.any_padro = 1881
    RETURN count(DISTINCT h) AS nombre_habitatges
}

MATCH (cap:Individu)-[:VIU]->(h:Habitatge)
WHERE h.municipi = 'SFLL'
  AND h.any_padro = 1881

MATCH (cap)-[r:FAMILIA]->(fill:Individu)
WHERE r.relacio_harmonitzada STARTS WITH 'fill'

WITH 
    nombre_habitatges,
    count(DISTINCT fill) AS total_fills

RETURN
    total_fills,
    nombre_habitatges,
    toFloat(total_fills) / nombre_habitatges AS mitjana_fills_per_habitatge;