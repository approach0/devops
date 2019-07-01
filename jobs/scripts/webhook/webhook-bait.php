<?php
header('Content-Type: text/plain');

$req = file_get_contents("php://input");

$json = json_decode($req, true);

$req_pretty = json_encode($json, JSON_PRETTY_PRINT);
$fp = fopen('webhook.log', 'a');

if ($fp === false) {
        echo 'failed to write.';
        http_response_code(500);
        exit();
}

fwrite($fp, $req_pretty);
fwrite($fp, "\n");
fclose($fp);

echo 'catch.';
?>
