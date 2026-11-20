<?php
require_once __DIR__ . '/../app/bootstrap.php';
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (!csrf_valid($_POST['_csrf'] ?? null)) $error = 'Refresh the page and try again.';
  else {
    $name=trim((string)($_POST['name'] ?? '')); $email=strtolower(trim((string)($_POST['email'] ?? '')));
    $password=(string)($_POST['password'] ?? ''); $passwordConfirm=(string)($_POST['password_confirm'] ?? '');
    if ($name==='' || text_length($name)>80 || !filter_var($email,FILTER_VALIDATE_EMAIL)) $error='Enter a name and valid email.';
    elseif (strlen($password)<10) $error='Password must have at least 10 characters.';
    elseif (!hash_equals($password,$passwordConfirm)) $error='The passwords do not match.';
    else {
      try {
        $q=db()->prepare('INSERT INTO users(name,email,password_hash) VALUES(?,?,?)');
        $q->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT)]);
        $_SESSION['flash']='Account created. Sign in to continue.';
        header('Location: /login.php'); exit;
      } catch (PDOException $e) {
        if ($e->getCode()==='23000') $error='That email is already registered.'; else throw $e;
      }
    }
  }
}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Create account · ModelForge</title><link rel="stylesheet" href="/assets/app.css"></head>
<body class="auth"><main class="auth-card"><a class="brand" href="/register.php"><b>M</b> ModelForge</a><p class="eyebrow">LOCAL EXPERIMENT TRACKER</p><h1>Create account</h1>
<p class="muted">Passwords are saved as one-way hashes.</p><?php if($error): ?><p class="error"><?=h($error)?></p><?php endif; ?>
<form class="stack" method="post"><input type="hidden" name="_csrf" value="<?=h(csrf_token())?>">
<label>Name<input name="name" required maxlength="80" autocomplete="name"></label><label>Email<input type="email" name="email" required maxlength="120" autocomplete="email"></label>
<label>Password<input type="password" name="password" minlength="10" required autocomplete="new-password"></label>
<label>Confirm password<input type="password" name="password_confirm" minlength="10" required autocomplete="new-password"></label>
<button class="primary">Create account</button></form>
<p class="muted">Already registered? <a href="/login.php">Sign in</a></p></main></body></html>