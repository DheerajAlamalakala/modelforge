<?php
require_once __DIR__ . '/../app/bootstrap.php';
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (!csrf_valid($_POST['_csrf'] ?? null)) $error = 'Refresh the page and try again.';
  else {
    $stmt = db()->prepare('SELECT user_id,name,password_hash FROM users WHERE email=?');
    $stmt->execute([strtolower(trim((string)($_POST['email'] ?? '')))]);
    $user = $stmt->fetch();
    if ($user && $user['password_hash'] && password_verify((string)($_POST['password'] ?? ''), $user['password_hash'])) {
      session_regenerate_id(true);
      $_SESSION['user_id'] = (int)$user['user_id'];
      $_SESSION['name'] = $user['name'];
      $_SESSION['last_activity'] = time();
      header('Location: /'); exit;
    }
    $error = 'Email or password is incorrect.';
  }
}
$flash = $_SESSION['flash'] ?? ''; unset($_SESSION['flash']);
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sign in · ModelForge</title><link rel="stylesheet" href="/assets/app.css"></head>
<body class="auth"><main class="auth-card"><a class="brand" href="/login.php"><b>M</b> ModelForge</a><p class="eyebrow">LOCAL EXPERIMENT TRACKER</p><h1>Welcome back</h1>
<p class="muted">Sign in to inspect your projects and runs.</p>
<?php if ($flash): ?><p class="notice"><?=h($flash)?></p><?php endif; ?><?php if ($error): ?><p class="error"><?=h($error)?></p><?php endif; ?>
<form class="stack" method="post"><input type="hidden" name="_csrf" value="<?=h(csrf_token())?>">
<label>Email<input type="email" name="email" required autocomplete="email"></label><label>Password<input type="password" name="password" required autocomplete="current-password"></label>
<button class="primary">Sign in</button></form><p class="muted">New here? <a href="/register.php">Create an account</a></p></main></body></html>

