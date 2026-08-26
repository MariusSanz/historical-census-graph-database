// Find all historical appearances of the same person using SAME_AS relationships.
// Variable-length traversal captures linked records even when surname spelling changes.

MATCH (base:Individu)
WHERE base.nom = 'miguel'
  AND base.cognom1 = 'estape'
  AND base.cognom2 = 'bofill'
MATCH (base)-[:SAME_AS*0..]-(aparicio:Individu)
RETURN DISTINCT
    aparicio.id AS id,
    aparicio.any_padro AS any_padro,
    aparicio.nom AS nom,
    aparicio.cognom1 AS cognom1,
    aparicio.cognom2 AS cognom2
ORDER BY any_padro;