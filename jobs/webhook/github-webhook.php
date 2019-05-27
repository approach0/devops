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

$DOCS_ENG_DIR = '/home/tk/tksync/proj/search-engine-docs-eng';
$DOCS_ENG_REPO = 'search-engine-docs-eng';

$SEARCH_ENGINE_REPO = 'search-engine';

$json_str = file_get_contents("php://input");

//var_dump($json_str);
//exit;

$json = json_decode($json_str);
$repo = $json->repository->name;

if ($repo == $DOCS_ENG_REPO) {
	/* 
	 * make sure $DOCS_ENG_DIR and its sub-dirs can be written
	 * (normally just chown -R www-data:www-data to that dir and
	 * its sub-dirs.)
	 */
	exe_at($DOCS_ENG_DIR, "git fetch origin master");
	exe_at($DOCS_ENG_DIR, "git reset --hard origin/master");
	exe_at($DOCS_ENG_DIR, "git pull origin master");
	exe_at($DOCS_ENG_DIR, "sphinx-build -b html -d _build/doctrees . _build/html");

} else if ($repo == $SEARCH_ENGINE_REPO) {
	/* TODO */
}
?>
