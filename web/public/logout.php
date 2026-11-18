<?php
require_once __DIR__ . '/../app/bootstrap.php';
if ($_SERVER['REQUEST_METHOD']!=='POST' || !csrf_valid($_POST['_csrf'] ?? null)) { http_response_code(400); exit('Invalid sign-out request.'); }
$_SESSION=[]; if(ini_get('session.use_cookies')) { $p=session_get_cookie_params(); setcookie(session_name(),'',time()-42000,$p['path'],$p['domain'],$p['secure'],$p['httponly']); }
session_destroy(); header('Location: /login.php'); exit;

