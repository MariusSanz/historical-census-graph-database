MATCH (i:Individu)-[:VIU]->(h:Habitatge)

WHERE h.municipi = 'SFLL'
  AND h.any_padro = 1881
  AND h.carrer IS NOT NULL
  AND trim(toString(h.carrer)) <> ''
  AND NOT toLower(trim(toString(h.carrer))) IN ['null', 'nan']

RETURN
    h.carrer AS carrer,
    count(DISTINCT i) AS habitants,
    count(DISTINCT h) AS habitatges

ORDER BY habitants DESC, carrer ASC
LIMIT 10;