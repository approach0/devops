<?php
$req = file_get_contents("php://input");

$json = json_decode($req, true);

$req_pretty = json_encode($json, JSON_PRETTY_PRINT);
$fp = fopen('bait.log', 'a');
fwrite($fp, $req_pretty);
fwrite($fp, "\n");
fclose($fp);
?>
