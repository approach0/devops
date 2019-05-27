var express = require('express');
var bodyParser = require('body-parser');
var execSync = require('child_process').execSync;
var path = require('path');

var jobsldr = require('./jobsldr.js');
var routeHandler = require('./jobd-handler.js');

/* arguments parsing */
var args = process.argv;
var jobsdir = args[args.length - 1];

/* load jobs/configs */
jobsldr.load(jobsdir).catch(err => {
	console.log(err);

}).then(jobs => {
	console.log('Environment variables:');
	console.log(jobs.env);

	if (jobs.depGraph === null) {
		console.log("no job, abort");
		process.exit(1);
	}

	console.log('Jobs:');
	console.log(jobs.depGraph.overallOrder());

	user = process.env['USER'];
	console.log('User:');
	console.log(user);

	/* initialize express app */
	app = express();
	app.use(bodyParser.json());
	app.use(express.static('./public/'));

	app.get('/', function (req, res) {
		res.sendFile(path.resolve('./public/query.html'));

	}).get('/deps', function (req, res) {
		routeHandler.handle_deps(req, res, jobs.depGraph);

	}).get('/reload', function (req, res) {
		jobs = routeHandler.handle_reload(res, jobsldr, jobsdir, jobs);

	}).post('/stdin', function (req, res) {
		routeHandler.handle_stdin(req, res);

	}).get('/log/:jobname', function (req, res) {
		routeHandler.handle_log(jobsdir, req.params.jobname, res);

	}).get('/show/:jobname', function (req, res) {
		routeHandler.handle_show(jobs, req.params.jobname, res);

	}).get('/kill_task/:taskid', function (req, res) {
		let taskID = req.params.taskid;
		routeHandler.handle_kill_task(taskID, res);

	}).get('/list_tasks', function (req, res) {
		routeHandler.handle_list_tasks(res);

	}).post('/run', function (req, res) {
		routeHandler.handle_query(req, res, user, jobsdir, jobs);
	});

	console.log('listening on ' + 3009);
	app.listen(3009);
});

process.stdin.on('error', function (e) {
	console.log('main process stdin error: ' + e.message);
});
