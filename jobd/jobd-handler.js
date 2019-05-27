var jobRunner = require('./jobrunner.js');
var logger = require('./joblogger.js');
var fs = require('fs');

const fv_all = 40;
const fv_one = 80;
const maxFailsToBreak = 3;

function getLogdir(jobsdir) {
	let logdir = jobsdir + '/logs';
	if (!fs.existsSync(logdir))
		fs.mkdirSync(logdir);
	return logdir;
}

function masterLog(logdir, line) {
	console.log('masterLog: ' + line);
	logger.write('all', logdir, line, fv_all);
}

function slaveLog(jobname, logdir, line) {
	logger.write(jobname, logdir, line, fv_one);
	logger.write('all', logdir, line, fv_all);
	console.log('[' + jobname + '] ' + line);
}

exports.handle_log = function (jobsdir, jobname, res) {
	let logdir = getLogdir(jobsdir);
	res.set('Content-Type', 'text/plain');
	res.header("Access-Control-Allow-Origin", "*");
	logger.read(jobname, logdir, function (lines) {
		res.write(lines);
	}, function () {
		res.end();
	});
};

exports.handle_show = function (jobs, jobname, res) {
	let job = {};
	try {
		job = jobs.depGraph.getNodeData(jobname);
	} catch (e) {
		res.json({"res": e.message});
		return;
	}

	res.json({
		"res": 'successful',
		'job': job
	});
};

exports.handle_deps = function (req, res, depGraph) {
	let nodes = depGraph.overallOrder();
	let retobj = {};
	nodes.forEach(function (n) {
		let props = depGraph.getNodeData(n);
		let deps = props.dep || [];
		retobj[n] = {};
		retobj[n]["dep"] = deps;
		retobj[n]["ref"] = props.ref;
	});

	res.json({'res': 'successful', 'graph': retobj});
};

exports.handle_stdin = function (req, res) {
	let reqJson = req.body;
	let stdinStr = reqJson['stdin'] || '';

	try {
		process.stdin.push(stdinStr + '\n');
		res.json({'res': 'successful'});
	} catch (e) {
		res.json({'res': e.message});
	}
};

exports.handle_kill_task = function (taskID, res) {
	jobRunner.clear_task(taskID);
	res.json({'res': 'successful'});
};

exports.handle_reload = function (res, jobsldr, jobsdir, jobs) {
	var newjobs = {};
	try {
		newjobs = jobsldr.load(jobsdir);
		console.log('all jobs reloaded.');
	} catch (e) {
		console.log(e.message);
		res.json({'res': e.message});
		return jobs;
	}

	res.json({'res': 'successful'});
	return newjobs;
};

exports.handle_list_tasks = function (res) {
	res.json({'tasks': jobRunner.get_all_tasks()});
};

exports.handle_query = function (req, res, user, jobsdir, jobs) {
	let reqJson = req.body;
	let type = reqJson['type'] || '';
	let target = reqJson['target'] || '';
	let runList = [];
	let logdir = getLogdir(jobsdir);

	/* print coming query */
	masterLog(logdir, 'Query: ' + JSON.stringify(reqJson));

	/* check target existance */
	try {
		let _ = jobs.depGraph.getNodeData(target);
	} catch (e) {
		masterLog(logdir, e.message);
		res.json({"res": e.message});
		return;
	}

	/* construct runList from query */
	switch (type) {
	case "dryrun":
	case "goal":
		let deps = jobs.depGraph.dependenciesOf(target);
		deps.forEach(function (dep) {
			runList.push(dep);
		});
		runList.push(target);
		break;

	case "unit":
		runList.push(target);
		break;
	}

	/* return client runList */
	res.json({"res": 'successful', "runList": runList});

	/* set dry-run flag if specified */
	jobs.dryrun = false;
	if (type == 'dryrun')
		jobs.dryrun = true;

	/* fail counter, will break the loop if fail too many times */
	let failCnt = 0;

	jobRunner.run(0, runList, user, jobs,
	/* on Spawn: */
	function (jobname, props) {
		masterLog(logdir, 'Start to run: [' + jobname + ']');
	},
	/* on Exit: */
	function (jobname, props, exitcode, onBreak) {
		masterLog(logdir, 'exitcode: ' + exitcode);

		if (onBreak != undefined) {
			if (exitcode == 0) {
				failCnt = 0;
			} else {
				failCnt ++;
				slaveLog(jobname, logdir, 'Fails: ' + failCnt);
				if (failCnt >= maxFailsToBreak) {
					onBreak();
					return 1;
				}
			}
		}

		return 0;
	},
	/* on Final: */
	function (jobname, completed) {
		slaveLog(jobname, logdir, 'Finished: [' + jobname +
		    ' (' + (completed ? 'successful' : 'failed') + ')]\n');
	},
	/* on Log: */
	function (jobname, line) {
		if (jobname == 'all')
			masterLog(logdir, line);
		else
			slaveLog(jobname, logdir, line);
	});
};
