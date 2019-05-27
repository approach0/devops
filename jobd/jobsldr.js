var fs = require("fs");
var ini = require('ini');
var spawn = require('child_process').spawn;
var DepGraph = require('dependency-graph').DepGraph;
var path = require('path')

function loadEnvVar(env_file) {
	/* a reserved environment variable list */
	const reserved = ['PWD', 'SHLVL', '_', ''];
	const resrv_map = reserved.reduce(function (obj, v) {
		obj[v] = 1;
		return obj;
	}, {});

	/* receive output from `source' and `printenv' */
	return new Promise((resolve, reject) => {
		/* source a environment file */
		var proc = spawn(__dirname + '/source.sh', [env_file], {
			'env': {}
		});
		var env_abc = {};
		proc.stdout.on('data', function (data) {
			var env_arr = data.toString().split('\n');
			for (var i=0; i < env_arr.length; i++) {
				var line = env_arr[i];
				var fields = line.split('=');
				var key = fields[0];
				if (undefined === resrv_map[key]) {
					env_abc[key] = fields.slice(1).join();
				}
			}
		});

		proc.stderr.on('data', function (data) { });
		proc.on('error', function(err) { reject() });

		proc.on('close', function(code) {
			resolve(env_abc);
		});
	});
}

function getJobCfgFiles(jobsdir) {
	var cfgFiles = [];

	fs.readdirSync(jobsdir).forEach(function (filename) {
		let m = filename.match(/([^.]+)\.job\.cfg$/);
		if (m) {
			let name = m[1];
			cfgFiles.push({
				'name': name,
				'path': jobsdir + '/' + filename
			});
		}
	});

	return cfgFiles;
}

function loadJobs(cfgFiles) {
	var depGraph = new DepGraph();

	/* create depGraph node from each cfgFile */
	cfgFiles.forEach(function (cfgFile) {
		let cfg = ini.parse(
			fs.readFileSync(cfgFile.path, 'utf-8')
		);

		for (var section in cfg) {
			if (!cfg.hasOwnProperty(section))
				continue;

			let target = cfgFile.name + ':' + section;
			depGraph.addNode(target);
			depGraph.setNodeData(target, cfg[section]);
		}
	});

	/* add dependencies for each depGraph node */
	depGraph.overallOrder().forEach(function (target) {
		let targetProps = depGraph.getNodeData(target);
		let deps = targetProps.dep || [];
		deps.forEach(function (dep) {
			try {
				depGraph.addDependency(target, dep);
			} catch (e) {
				//console.log(e.message);
				throw(e);
			}
		});
	});

	return depGraph;
}

exports.load = function (jobsdir) {
	return new Promise((all_resolve) => {
		new Promise((envs_resolve) => {
			fs.readdir(jobsdir, function (err, files) {
				if (err) {
					envs_resolve({});
					return;
				}

				let promises = files
				.filter(filename => {
					const ext = filename.split('.').pop();
					return ext == 'env';
				})
				.map(filename => {
					return new Promise(resolve => {
						loadEnvVar(jobsdir + '/' + filename).then(env => {
							/* inject JOBSDIR built-in env variable */
							env['JOBSDIR'] = path.resolve(jobsdir);
							resolve([filename, env]);
						});
					});
				});

				Promise.all(promises).then(envs => {
					const evobj = envs.reduce((obj, item) => {
						obj[item[0]] = item[1];
						return obj;
					});
					envs_resolve(evobj)
				});
			});
		}).then(evobj => {
			let depGraph = null;
			try {
				let jobFiles = getJobCfgFiles(jobsdir);
				depGraph = loadJobs(jobFiles);

				/*
				 * Invoke overallOrder() to throw error on
				 * circular-dependency.
				 */
				depGraph.overallOrder();
			} catch (err) {
				console.log(err);
			}

			all_resolve({
				"env": evobj,
				"depGraph": depGraph
			});
		});
	});
}
