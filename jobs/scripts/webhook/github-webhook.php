<?php
function exe_at($dir, $cmd) {
	$cmd = 'cd '. $dir.' && '.$cmd.' 2>&1';
	echo $cmd."\n";

	/* run command */
	$out = array();
	exec($cmd, $out);

	/* print command line output */
	foreach($out as $line) { echo $line."\n"; }
}

$json_str = file_get_contents("php://input");

//var_dump($json_str);
//exit;

$json = json_decode($json_str);
$repo = $json->repository->name;

$path = "/var/www/html/".$repo."-src/";

/* 
 * make sure $DOCS_ENG_DIR and its sub-dirs can be written
 * (normally just chown -R www-data:www-data to that dir and
 * its sub-dirs.)
 */
exe_at($path, "git fetch origin master");
exe_at($path, "git reset --hard origin/master");
exe_at($path, "sphinx-build -b html -d _build/doctrees . _build/html");
?>
