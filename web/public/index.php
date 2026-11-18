<?php
require_once __DIR__ . '/../app/bootstrap.php';
require_login();
$uid=(int)$_SESSION['user_id']; $pdo=db();
$q=$pdo->prepare('SELECT project_id,title FROM projects WHERE owner_id=? ORDER BY title'); $q->execute([$uid]); $projects=$q->fetchAll();
$q=$pdo->prepare('SELECT d.dataset_id,d.name,p.title AS project_title FROM datasets d JOIN projects p ON p.project_id=d.project_id WHERE p.owner_id=? ORDER BY p.title,d.name'); $q->execute([$uid]); $datasets=$q->fetchAll();
$q=$pdo->prepare('SELECT e.experiment_id,e.title,p.title AS project_title FROM experiments e JOIN projects p ON p.project_id=e.project_id WHERE p.owner_id=? ORDER BY p.title,e.title'); $q->execute([$uid]); $experiments=$q->fetchAll();
$nodes=$pdo->query("SELECT node_id,name,vram_gb,status FROM gpu_nodes WHERE status <> 'offline' ORDER BY name")->fetchAll();$csrf=csrf_token(); $visits=(int)($_COOKIE['mf_visits'] ?? 0)+1;
setcookie('mf_visits',(string)$visits,['expires'=>time()+604800,'path'=>'/','secure'=>false,'httponly'=>true,'samesite'=>'Lax']);
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>ModelForge · Workspace</title><link rel="stylesheet" href="/assets/app.css"><link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css"></head><body>
<header><a class="brand" href="/"><b>M</b> ModelForge</a><div class="right">Hi, <?=h($_SESSION['name'] ?? 'researcher')?>
<form method="post" action="/logout.php"><input type="hidden" name="_csrf" value="<?=h($csrf)?>"><button class="quiet">Sign out</button></form></div></header>
<main class="shell"><section class="hero"><div><p class="eyebrow">MODEL TRAINING WORKSPACE</p><h1>Experiments, at a glance.</h1><p class="muted">Your PHP app is connected to the ModelForge MySQL database.</p></div><div class="stat"><strong><?=count($projects)?></strong><span>your projects</span></div></section>
<section class="panel"><div class="panel-head"><div><p class="eyebrow">RUN EXPLORER</p><h2>Browse runs by project</h2></div><a href="/catalog/datasets.xml" target="_blank" rel="noopener">Open XML dataset catalog ↗</a></div>
<?php if(!$projects): ?><p class="notice">Create a project below to get started.</p><?php else: ?>
<div class="toolbar"><label>Project<select id="project-select"><?php foreach($projects as $p): ?><option value="<?=(int)$p['project_id']?>"><?=h($p['title'])?></option><?php endforeach; ?></select></label>
<label>Search experiments<input id="experiment-search" list="suggestions" placeholder="Type at least two letters"><datalist id="suggestions"></datalist></label></div>
<div class="table-wrap"><table><thead><tr><th>Run</th><th>Experiment</th><th>GPU</th><th>Status</th><th>Accuracy</th><th>Loss</th></tr></thead><tbody id="runs-body"><tr><td colspan="6">Loading…</td></tr></tbody></table></div><p id="runs-message" class="muted small" aria-live="polite"></p><?php endif; ?></section>
<section class="cards">
<article class="panel"><p class="eyebrow">01 · PROJECT</p><h2>New project</h2><form class="ajax-form stack" action="/api.php?action=project" method="post"><input type="hidden" name="_csrf" value="<?=h($csrf)?>"><label>Title<input name="title" required maxlength="120"></label><button class="primary">Add project</button><p class="form-message"></p></form></article>
<article class="panel"><p class="eyebrow">02 · DATASET</p><h2>Add dataset</h2><form class="ajax-form stack" action="/api.php?action=dataset" method="post"><input type="hidden" name="_csrf" value="<?=h($csrf)?>">
<label>Project<select name="project_id" required><?php foreach($projects as $p): ?><option value="<?=(int)$p['project_id']?>"><?=h($p['title'])?></option><?php endforeach; ?></select></label><label>Name<input name="name" required maxlength="120"></label>
<div class="split"><label>Size MB<input type="number" name="size_mb" min="0" step=".01" required></label><label>Format<select name="format"><option>csv</option><option>json</option><option>parquet</option><option>images</option></select></label></div>
<button class="secondary">Add dataset</button><p class="form-message"></p></form></article>
<article class="panel"><p class="eyebrow">03 · EXPERIMENT</p><h2>Batch-add experiments</h2><form class="ajax-form stack" action="/api.php?action=experiments" method="post"><input type="hidden" name="_csrf" value="<?=h($csrf)?>">
<label>Project<select name="project_id" required><?php foreach($projects as $p): ?><option value="<?=(int)$p['project_id']?>"><?=h($p['title'])?></option><?php endforeach; ?></select></label>
<label>Dataset (optional)<select name="dataset_id"><option value="">None</option><?php foreach($datasets as $d): ?><option value="<?=(int)$d['dataset_id']?>"><?=h($d['project_title'].' · '.$d['name'])?></option><?php endforeach; ?></select></label>
<label>Titles separated by commas<textarea name="titles" rows="3" required placeholder="U-Net baseline, ResNet fine-tune"></textarea></label><button class="secondary">Add experiments</button><p class="form-message"></p></form></article>
</section><section class="panel"><p class="eyebrow">04 · RUN</p><h2>Record a run</h2>
<form class="ajax-form run-form" action="/api.php?action=run" method="post"><input type="hidden" name="_csrf" value="<?=h($csrf)?>">
<label>Experiment<select name="experiment_id" required><?php foreach($experiments as $e): ?><option value="<?=(int)$e['experiment_id']?>"><?=h($e['project_title'].' · '.$e['title'])?></option><?php endforeach; ?></select></label>
<label>GPU node<select name="node_id"><option value="">No node</option><?php foreach($nodes as $n): ?><option value="<?=(int)$n['node_id']?>"><?=h($n['name'].' · '.$n['vram_gb'].' GB · '.$n['status'])?></option><?php endforeach; ?></select></label>
<div class="split"><label>Status<select name="status"><option>queued</option><option>running</option><option>done</option><option>failed</option></select></label><label>VRAM used (GB)<input type="number" name="vram_used_gb" min="0" step="0.01" value="0" required></label></div>
<div class="split"><label>Accuracy (optional)<input type="number" name="accuracy" min="0" max="1" step="0.0001"></label><label>Loss (optional)<input type="number" name="loss" min="0" step="0.0001"></label></div>
<button class="secondary">Record run</button><p class="form-message"></p></form></section><footer>Session expires after 20 minutes idle · visit cookie <?= $visits ?></footer></main>
<script>window.MF=<?=json_encode(['csrf'=>$csrf],JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT)?>;</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script><script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script><script src="/assets/app.js" defer></script></body></html>




