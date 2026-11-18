<?php
require_once __DIR__ . '/../app/bootstrap.php';
$action=(string)($_GET['action'] ?? $_POST['action'] ?? '');

if ($action==='runs' && $_SERVER['REQUEST_METHOD']==='GET') {
    require_login();
    $projectId=filter_input(INPUT_GET,'project_id',FILTER_VALIDATE_INT);
    if (!$projectId) json_response(['ok'=>false,'message'=>'Choose a project.'],422);
    $q=db()->prepare('SELECT r.run_id,e.title AS experiment,g.name AS gpu,r.status,r.accuracy,r.loss
      FROM projects p JOIN experiments e ON e.project_id=p.project_id
      JOIN runs r ON r.experiment_id=e.experiment_id LEFT JOIN gpu_nodes g ON g.node_id=r.node_id
      WHERE p.project_id=? AND p.owner_id=? ORDER BY r.started_at DESC,r.run_id DESC');
    $q->execute([$projectId,(int)$_SESSION['user_id']]);
    json_response(['ok'=>true,'runs'=>$q->fetchAll()]);
}
if ($action==='experiments' && $_SERVER['REQUEST_METHOD']==='GET') {
    require_login();
    $term=trim((string)($_GET['q'] ?? ''));
    if (text_length($term)<2) json_response([]);
    $q=db()->prepare('SELECT e.title FROM experiments e JOIN projects p ON p.project_id=e.project_id
      WHERE p.owner_id=? AND e.title LIKE ? ORDER BY e.title LIMIT 10');
    $q->execute([(int)$_SESSION['user_id'],'%'.$term.'%']);
    json_response(array_column($q->fetchAll(),'title'));
}

require_api_post();
$pdo=db(); $uid=(int)$_SESSION['user_id'];
if ($action==='project') {
    $title=trim((string)($_POST['title'] ?? ''));
    if ($title==='' || text_length($title)>120) json_response(['ok'=>false,'message'=>'Enter a project title up to 120 characters.'],422);
    $q=$pdo->prepare('INSERT INTO projects(owner_id,title) VALUES(?,?)'); $q->execute([$uid,$title]);
    json_response(['ok'=>true,'message'=>'Project added.']);
}
if ($action==='dataset') {
    $projectId=filter_var($_POST['project_id'] ?? null,FILTER_VALIDATE_INT);
    $name=trim((string)($_POST['name'] ?? '')); $size=filter_var($_POST['size_mb'] ?? null,FILTER_VALIDATE_FLOAT);
    $format=(string)($_POST['format'] ?? '');
    if (!$projectId || $name==='' || text_length($name)>120 || $size===false || $size<0 || !in_array($format,['csv','json','parquet','images'],true))
        json_response(['ok'=>false,'message'=>'Check the dataset fields.'],422);
    $q=$pdo->prepare('SELECT 1 FROM projects WHERE project_id=? AND owner_id=?'); $q->execute([$projectId,$uid]);
    if (!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Project not found.'],404);
    $q=$pdo->prepare('INSERT INTO datasets(project_id,name,size_mb,format) VALUES(?,?,?,?)'); $q->execute([$projectId,$name,$size,$format]);
    json_response(['ok'=>true,'message'=>'Dataset added.']);
}
if ($action==='experiments') {
    $projectId=filter_var($_POST['project_id'] ?? null,FILTER_VALIDATE_INT);
    $datasetId=($_POST['dataset_id'] ?? '')==='' ? null : filter_var($_POST['dataset_id'],FILTER_VALIDATE_INT);
    $titles=array_values(array_unique(array_filter(array_map('trim',explode(',',(string)($_POST['titles'] ?? ''))))));
    if (!$projectId || !$titles || count($titles)>20) json_response(['ok'=>false,'message'=>'Enter 1–20 comma-separated experiment titles.'],422);
    foreach($titles as $title) if(text_length($title)>140) json_response(['ok'=>false,'message'=>'Each title must be at most 140 characters.'],422);
    $q=$pdo->prepare('SELECT 1 FROM projects WHERE project_id=? AND owner_id=?'); $q->execute([$projectId,$uid]);
    if(!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Project not found.'],404);
    if($datasetId!==null) {
        $q=$pdo->prepare('SELECT 1 FROM datasets WHERE dataset_id=? AND project_id=?'); $q->execute([$datasetId,$projectId]);
        if(!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Choose a dataset from this project.'],422);
    }
    $insert=$pdo->prepare('INSERT INTO experiments(project_id,dataset_id,title) VALUES(?,?,?)');
    $pdo->beginTransaction();
    try { foreach($titles as $title) $insert->execute([$projectId,$datasetId,$title]); $pdo->commit(); }
    catch(Throwable $e) { $pdo->rollBack(); throw $e; }
    json_response(['ok'=>true,'message'=>count($titles).' experiments added.']);
}
if ($action==='run') {
    $experimentId=filter_var($_POST['experiment_id'] ?? null,FILTER_VALIDATE_INT);
    $nodeId=($_POST['node_id'] ?? '')==='' ? null : filter_var($_POST['node_id'],FILTER_VALIDATE_INT);
    $status=(string)($_POST['status'] ?? 'queued');
    $rawA=trim((string)($_POST['accuracy'] ?? '')); $rawL=trim((string)($_POST['loss'] ?? ''));
    $accuracy=$rawA==='' ? null : filter_var($rawA,FILTER_VALIDATE_FLOAT);
    $loss=$rawL==='' ? null : filter_var($rawL,FILTER_VALIDATE_FLOAT);
    $vram=filter_var($_POST['vram_used_gb'] ?? null,FILTER_VALIDATE_FLOAT);
    if(!$experimentId || $nodeId===false || !in_array($status,['queued','running','done','failed'],true) ||
       ($rawA!=='' && ($accuracy===false || $accuracy<0 || $accuracy>1)) ||
       ($rawL!=='' && ($loss===false || $loss<0)) || $vram===false || $vram<0)
        json_response(['ok'=>false,'message'=>'Check the run fields and try again.'],422);
    $q=$pdo->prepare('SELECT 1 FROM experiments e JOIN projects p ON p.project_id=e.project_id WHERE e.experiment_id=? AND p.owner_id=?');
    $q->execute([$experimentId,$uid]); if(!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Experiment not found.'],404);
    $ended=in_array($status,['done','failed'],true) ? date('Y-m-d H:i:s') : null;
    try {
        $q=$pdo->prepare('INSERT INTO runs(experiment_id,node_id,status,accuracy,loss,vram_used_gb,ended_at) VALUES(?,?,?,?,?,?,?)');
        $q->execute([$experimentId,$nodeId,$status,$accuracy,$loss,$vram,$ended]);
    } catch(PDOException $e) {
        if(($e->errorInfo[0] ?? '')==='45000') json_response(['ok'=>false,'message'=>$e->errorInfo[2] ?? 'Run rejected by a database rule.'],422);
        throw $e;
    }
    json_response(['ok'=>true,'message'=>'Run recorded.']);
}
json_response(['ok'=>false,'message'=>'Unknown API action.'],404);



