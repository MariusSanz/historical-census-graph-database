MATCH (rafel:Individu)-[v1:VIU]->(h:Habitatge)
WHERE rafel.nom = 'rafel'
  AND rafel.cognom1 = 'marti'
  AND rafel.cognom2 IS NULL
  AND h.municipi = 'SFLL'
  AND h.any_padro = 1838
MATCH (persona:Individu)-[v2:VIU]->(h)
RETURN rafel, v1, h, persona, v2;