CALL gds.graph.project(
  'meuGrafProjectat',
  ['Individu', 'Habitatge'],
  {
    VIU: {
      type: 'VIU',
      orientation: 'UNDIRECTED'
    }
  }
);

CALL gds.wcc.stream('meuGrafProjectat')
YIELD nodeId, componentId
RETURN componentId AS `ID Component`, count(nodeId) AS `Mida Component`
ORDER BY `Mida Component` DESC
LIMIT 10;


CALL gds.wcc.stream('meuGrafProjectat')
YIELD nodeId, componentId
WITH componentId, gds.util.asNode(nodeId) AS nodo
WITH componentId, 
     sum(CASE WHEN 'Habitatge' IN labels(nodo) THEN 1 ELSE 0 END) AS habitaclesEnComponent
WHERE habitaclesEnComponent = 0
RETURN count(DISTINCT componentId) AS `Components sense Habitatge`;


CALL gds.graph.drop('meuGrafProjectat');