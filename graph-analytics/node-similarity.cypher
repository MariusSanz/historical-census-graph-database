// ============================================================
// EXERCICI 4b - SEMBLANÇA ENTRE NODES
// ============================================================


// ---- Pas 1: Crear arestes MATEIX_HAB ----
MATCH (h1:Habitatge), (h2:Habitatge)
WHERE h1.municipi  = h2.municipi
  AND h1.carrer    = h2.carrer
  AND h1.numero    = h2.numero
  AND h1.any_padro < h2.any_padro
MERGE (h2)-[:MATEIX_HAB]->(h1);


// ---- Pas 2: Crear el graf en memòria ----
CALL gds.graph.project(
  'grafSimilitud',
  ['Individu', 'Habitatge'],
  {
    VIU:        { type: 'VIU',        orientation: 'UNDIRECTED' },
    FAMILIA:    { type: 'FAMILIA',    orientation: 'UNDIRECTED' },
    MATEIX_HAB: { type: 'MATEIX_HAB', orientation: 'UNDIRECTED' }
  }
);


// ---- Pas 3: Calcular similitud i escriure a la BD ----
CALL gds.nodeSimilarity.write(
  'grafSimilitud',
  {
    writeRelationshipType : 'SIMILAR',
    writeProperty         : 'score',
    similarityCutoff      : 0.1,
    topK                  : 10
  }
)
YIELD nodesCompared, relationshipsWritten, similarityDistribution
RETURN
  nodesCompared          AS Nodes_comparats,
  relationshipsWritten   AS Relacions_SIMILAR,
  similarityDistribution AS Distribució_similituds;


// ---- Pas 4: Veure els resultats ----

// Parelles d'Individus més similars
MATCH (a:Individu)-[s:SIMILAR]->(b:Individu)
RETURN a.id AS Individu_A, b.id AS Individu_B, round(s.score * 1000)/1000.0 AS Score
ORDER BY Score DESC
LIMIT 20;


// Candidats a SAME_AS (score = 1.0)
MATCH (a:Individu)-[s:SIMILAR]->(b:Individu)
WHERE s.score = 1.0 
  AND a.id < b.id
RETURN
  a.id                     AS Individu_A,
  b.id                     AS Individu_B,
  s.score                  AS Score
ORDER BY Individu_A;


// ---- Pas 5: Eliminar el graf de memòria ----
CALL gds.graph.drop('grafSimilitud');
