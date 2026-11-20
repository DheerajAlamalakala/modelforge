<?php
require_once __DIR__ . '/../app/bootstrap.php';
$action=(string)($_GET['action'] ?? $_POST['action'] ?? '');

if ($action==='runs' && $_SERVER['REQUEST_METHOD']==='GET') {
    require_login();
    $projectId=filter_input(INPUT_GET,'project_id',FILTER_VALIDATE_INT);
    if (!$projectId) json_response(['ok'=>false,'message'=>'Choose a project.'],422);
    $q=db()->prepare('SELECT r.run_id,r.experiment_id,r.node_id,e.title AS experiment,g.name AS gpu,r.status,r.accuracy,r.loss,r.vram_used_gb,r.notes,r.started_at,r.ended_at
      FROM projects p JOIN experiments e ON e.project_id=p.project_id
      JOIN runs r ON r.experiment_id=e.experiment_id LEFT JOIN gpu_nodes g ON g.node_id=r.node_id
      WHERE p.project_id=? AND p.owner_id=? ORDER BY r.started_at DESC,r.run_id DESC');
    $q->execute([$projectId,(int)$_SESSION['user_id']]);
    json_response(['ok'=>true,'runs'=>$q->fetchAll()]);
}
if ($action==='metrics' && $_SERVER['REQUEST_METHOD']==='GET') {
    require_login();
    $runId=filter_input(INPUT_GET,'run_id',FILTER_VALIDATE_INT);
    if (!$runId) json_response(['ok'=>false,'message'=>'Choose a run.'],422);
    $q=db()->prepare('SELECT m.metric_id,m.epoch,m.loss,m.accuracy FROM metrics m
      JOIN runs r ON r.run_id=m.run_id JOIN experiments e ON e.experiment_id=r.experiment_id
      JOIN projects p ON p.project_id=e.project_id WHERE r.run_id=? AND p.owner_id=? ORDER BY m.epoch');
    $q->execute([$runId,(int)$_SESSION['user_id']]);
    json_response(['ok'=>true,'metrics'=>$q->fetchAll()]);
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
if ($action==='delete_account') {
    $password=(string)($_POST['password'] ?? ''); $confirmation=trim((string)($_POST['confirm_delete'] ?? ''));
    $q=$pdo->prepare('SELECT password_hash FROM users WHERE user_id=?'); $q->execute([$uid]); $hash=$q->fetchColumn();
    if (!$hash || !password_verify($password,(string)$hash)) json_response(['ok'=>false,'message'=>'The password is incorrect.'],422);
    if ($confirmation!=='DELETE') json_response(['ok'=>false,'message'=>'Type DELETE exactly to confirm.'],422);
    try {
      $pdo->beginTransaction();
      $q=$pdo->prepare('DELETE FROM projects WHERE owner_id=?'); $q->execute([$uid]);
      $q=$pdo->prepare('DELETE FROM users WHERE user_id=?'); $q->execute([$uid]);
      $pdo->commit();
    } catch(Throwable $e) {
      if($pdo->inTransaction()) $pdo->rollBack();
      throw $e;
    }
    $_SESSION=[];
    if(ini_get('session.use_cookies')) {
      $params=session_get_cookie_params();
      setcookie(session_name(),'',['expires'=>time()-42000,'path'=>$params['path'],'domain'=>$params['domain'],'secure'=>$params['secure'],'httponly'=>$params['httponly'],'samesite'=>'Lax']);
    }
    session_destroy();
    json_response(['ok'=>true,'message'=>'Account and owned project data deleted.']);
}
if ($action==='project') {
    $title=trim((string)($_POST['title'] ?? ''));
    if ($title==='' || text_length($title)>120) json_response(['ok'=>false,'message'=>'Enter a project title up to 120 characters.'],422);
    $q=$pdo->prepare('INSERT INTO projects(owner_id,title) VALUES(?,?)'); $q->execute([$uid,$title]);
    json_response(['ok'=>true,'message'=>'Project added.']);
}
if ($action==='dataset') {
    $projectId=filter_var($_POST['project_id'] ?? null,FILTER_VALIDATE_INT);
    $name=trim((string)($_POST['name'] ?? '')); $size=filter_var($_POST['size_mb'] ?? null,FILTER_VALIDATE_FLOAT);
    $format=(string)($_POST['format'] ?? ''); $source=trim((string)($_POST['source_url'] ?? ''));
    $parts=$source===''?false:parse_url($source);
    $validSource=$source==='' || (filter_var($source,FILTER_VALIDATE_URL) && is_array($parts) && in_array(strtolower($parts['scheme'] ?? ''),['http','https'],true));
    if (!$projectId || $name==='' || text_length($name)>120 || $size===false || $size<0 || !in_array($format,['csv','json','parquet','images'],true) || !$validSource || text_length($source)>500)
        json_response(['ok'=>false,'message'=>'Check the dataset fields; source links must use HTTP or HTTPS.'],422);
    $q=$pdo->prepare('SELECT 1 FROM projects WHERE project_id=? AND owner_id=?'); $q->execute([$projectId,$uid]);
    if (!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Project not found.'],404);
    $q=$pdo->prepare('INSERT INTO datasets(project_id,name,size_mb,format,source_url) VALUES(?,?,?,?,?)'); $q->execute([$projectId,$name,$size,$format,$source===''?null:$source]);
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
if ($action==='run' || $action==='run_update') {
    $runId=$action==='run_update'?filter_var($_POST['run_id'] ?? null,FILTER_VALIDATE_INT):null;
    $experimentId=filter_var($_POST['experiment_id'] ?? null,FILTER_VALIDATE_INT);
    $nodeId=($_POST['node_id'] ?? '')===''?null:filter_var($_POST['node_id'],FILTER_VALIDATE_INT);
    $status=(string)($_POST['status'] ?? 'queued');
    $rawA=trim((string)($_POST['accuracy'] ?? '')); $rawL=trim((string)($_POST['loss'] ?? ''));
    $accuracy=$rawA===''?null:filter_var($rawA,FILTER_VALIDATE_FLOAT); $loss=$rawL===''?null:filter_var($rawL,FILTER_VALIDATE_FLOAT);
    $vram=filter_var($_POST['vram_used_gb'] ?? null,FILTER_VALIDATE_FLOAT); $notes=trim((string)($_POST['notes'] ?? ''));
    if (($action==='run_update' && !$runId) || !$experimentId || $nodeId===false || !in_array($status,['queued','running','done','failed'],true) ||
       ($rawA!=='' && ($accuracy===false || $accuracy<0 || $accuracy>1)) || ($rawL!=='' && ($loss===false || $loss<0)) ||
       $vram===false || $vram<0 || text_length($notes)>500)
        json_response(['ok'=>false,'message'=>'Check the run fields; notes can be up to 500 characters.'],422);
    $q=$pdo->prepare('SELECT 1 FROM experiments e JOIN projects p ON p.project_id=e.project_id WHERE e.experiment_id=? AND p.owner_id=?');
    $q->execute([$experimentId,$uid]); if(!$q->fetchColumn()) json_response(['ok'=>false,'message'=>'Experiment not found.'],404);
    if($nodeId!==null){$q=$pdo->prepare('SELECT status FROM gpu_nodes WHERE node_id=?');$q->execute([$nodeId]);$nodeStatus=$q->fetchColumn();if($nodeStatus===false)json_response(['ok'=>false,'message'=>'GPU node not found.'],422);if($nodeStatus==='offline')json_response(['ok'=>false,'message'=>'Choose an online GPU node.'],422);}
    $now=date('Y-m-d H:i:s'); $ended=in_array($status,['done','failed'],true)?$now:null;
    try {
      if($action==='run') {
        $q=$pdo->prepare('INSERT INTO runs(experiment_id,node_id,status,accuracy,loss,vram_used_gb,notes,ended_at) VALUES(?,?,?,?,?,?,?,?)');
        $q->execute([$experimentId,$nodeId,$status,$accuracy,$loss,$vram,$notes===''?null:$notes,$ended]);
        json_response(['ok'=>true,'message'=>'Run recorded.']);
      }
      $q=$pdo->prepare('SELECT r.status,r.started_at FROM runs r JOIN experiments e ON e.experiment_id=r.experiment_id JOIN projects p ON p.project_id=e.project_id WHERE r.run_id=? AND p.owner_id=?');
      $q->execute([$runId,$uid]); $existing=$q->fetch(); if(!$existing)json_response(['ok'=>false,'message'=>'Run not found.'],404);
      $started=($status==='running' && $existing['status']!=='running')?$now:$existing['started_at'];
      $q=$pdo->prepare('UPDATE runs SET experiment_id=?,node_id=?,status=?,accuracy=?,loss=?,vram_used_gb=?,notes=?,started_at=?,ended_at=? WHERE run_id=?');
      $q->execute([$experimentId,$nodeId,$status,$accuracy,$loss,$vram,$notes===''?null:$notes,$started,$ended,$runId]);
      json_response(['ok'=>true,'message'=>'Run updated.']);
    } catch(PDOException $e) {
      if(($e->errorInfo[0] ?? '')==='45000') json_response(['ok'=>false,'message'=>$e->errorInfo[2] ?? 'Run rejected by a database rule.'],422);
      throw $e;
    }
}
if ($action==='delete_run') {
    $runId=filter_var($_POST['run_id'] ?? null,FILTER_VALIDATE_INT);
    if(!$runId)json_response(['ok'=>false,'message'=>'Choose a run.'],422);
    $q=$pdo->prepare('DELETE r FROM runs r JOIN experiments e ON e.experiment_id=r.experiment_id JOIN projects p ON p.project_id=e.project_id WHERE r.run_id=? AND p.owner_id=?');
    $q->execute([$runId,$uid]);
    if(!$q->rowCount())json_response(['ok'=>false,'message'=>'Run not found.'],404);
    json_response(['ok'=>true,'message'=>'Run, epoch metrics, and its audit history deleted.']);
}
if ($action==='metric') {
    $runId=filter_var($_POST['run_id'] ?? null,FILTER_VALIDATE_INT); $epoch=filter_var($_POST['epoch'] ?? null,FILTER_VALIDATE_INT);
    $loss=filter_var($_POST['loss'] ?? null,FILTER_VALIDATE_FLOAT); $accuracy=filter_var($_POST['accuracy'] ?? null,FILTER_VALIDATE_FLOAT);
    if(!$runId || !$epoch || $epoch<1 || $loss===false || $loss<0 || $accuracy===false || $accuracy<0 || $accuracy>1)
      json_response(['ok'=>false,'message'=>'Enter a positive epoch, nonnegative loss, and accuracy from 0 to 1.'],422);
    $q=$pdo->prepare('SELECT r.status FROM runs r JOIN experiments e ON e.experiment_id=r.experiment_id JOIN projects p ON p.project_id=e.project_id WHERE r.run_id=? AND p.owner_id=?');
    $q->execute([$runId,$uid]); $runStatus=$q->fetchColumn();
    if($runStatus===false)json_response(['ok'=>false,'message'=>'Run not found.'],404);
    if($runStatus==='queued')json_response(['ok'=>false,'message'=>'Change the run status to Running before recording epochs.'],409);
    $q=$pdo->prepare('INSERT INTO metrics(run_id,epoch,loss,accuracy) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE loss=VALUES(loss),accuracy=VALUES(accuracy)');
    $q->execute([$runId,$epoch,$loss,$accuracy]);
    json_response(['ok'=>true,'message'=>'Epoch '.$epoch.' saved.']);
}
json_response(['ok'=>false,'message'=>'Unknown API action.'],404);