<?php
declare(strict_types=1);
$configPath = dirname(__DIR__) . '/config.local.php';
if (!is_file($configPath)) {
    http_response_code(500);
    exit('Copy web/config.example.php to web/config.local.php and enter your local MySQL credentials.');
}
$config = require $configPath;

ini_set('session.use_strict_mode', '1');
session_set_cookie_params([
    'lifetime' => 0, 'path' => '/',
    'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'httponly' => true, 'samesite' => 'Lax',
]);
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$timeout = (int)($config['session_timeout'] ?? 1200);
if (isset($_SESSION['last_activity']) && time() - (int)$_SESSION['last_activity'] > $timeout) {
    $_SESSION = [];
    session_regenerate_id(true);
    $_SESSION['flash'] = 'Session expired. Please sign in again.';
}
$_SESSION['last_activity'] = time();

function db(): PDO {
    global $config;
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;
    $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
        $config['host'], $config['port'], $config['database']);
    return $pdo = new PDO($dsn, $config['username'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}
function h(?string $value): string {
    return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
function text_length(string $value): int {
    if (function_exists('mb_strlen')) return mb_strlen($value, 'UTF-8');
    return preg_match_all('/./us', $value, $matches) ?: 0;
}
function csrf_token(): string {
    if (empty($_SESSION['_csrf'])) $_SESSION['_csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['_csrf'];
}
function csrf_valid(?string $token): bool {
    return is_string($token) && isset($_SESSION['_csrf']) && hash_equals($_SESSION['_csrf'], $token);
}
function require_login(): void {
    if (empty($_SESSION['user_id'])) { header('Location: /login.php'); exit; }
}
function json_response(array $body, int $status = 200): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}
function require_api_post(): void {
    require_login();
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_response(['ok'=>false,'message'=>'POST required.'],405);
    if (!csrf_valid($_SERVER['HTTP_X_CSRF_TOKEN'] ?? ($_POST['_csrf'] ?? null)))
        json_response(['ok'=>false,'message'=>'Refresh the page and retry.'],419);
}



