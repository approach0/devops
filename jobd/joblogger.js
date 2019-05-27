var fs = require("graceful-fs");
var loggers = {};

function loggerEach(path, name, callbk, select) {
	let file0 = path + '/' + name + '.0.log';
	let file1 = path + '/' + name + '.1.log';
	if (select === undefined)
		return [file0, file1].forEach(callbk);
	else if (select == 0)
		return [file0].forEach(callbk);
	else
		return [file1].forEach(callbk);
}

function loggerGet(path, name, fvol) {
	let logger = loggers[name];
	if (logger == undefined ||
	    (fvol != undefined && logger['fvol'] != fvol)) {
		logger = loggers[name] = {
			'fvol': fvol,
			'prev': undefined,
			'cnt': 0,
		}
	}

	return logger;
}

function loggerWrite(path, name, data, fvol) {
	let logger = loggerGet(path, name, fvol);
	logger['cnt'] = (1 + logger['cnt']) % (2 * logger['fvol']);
	let now = parseInt(logger['cnt'] / logger['fvol']);

	if (logger['prev'] == undefined) {
		loggerEach(path, name, function (f) {
			fs.closeSync(fs.openSync(f, 'w'));
			fs.truncateSync(f);
		});
	} else if (now != logger['prev']) {
		loggerEach(path, name, function (f) {
			fs.closeSync(fs.openSync(f, 'w'));
			fs.truncateSync(f);
		}, now);
	}

	loggerEach(path, name, function (f) {
		fs.appendFileSync(f, data);
	}, now);

	logger['prev'] = now;
}

function cat(filepath, onData) {
	try{
		fs.accessSync(filepath, fs.F_OK);
	} catch(e) {
		return;
	}

	onData(fs.readFileSync(filepath, "utf8"));
}

function loggerRead(path, name, onData, onEnd) {
	let logger = loggerGet(path, name);
	if (logger['fvol'] != undefined) {
		let now = parseInt(logger['cnt'] / logger['fvol']);

		loggerEach(path, name, function (f) {
			cat(f, onData);
		}, (now + 1) % 2);

		loggerEach(path, name, function (f) {
			cat(f, onData);
		}, now);
	}

	if (onEnd != undefined) onEnd();
}

var timenow = function() {
	let tz_offset = (new Date()).getTimezoneOffset() * 60000;
	let local_time = (new Date(Date.now() - tz_offset)).toISOString().slice(0,-1);
	return local_time.replace(/T/, ' ').replace(/\..+/, '');
};

exports.write = function (jobname, logsdir, output, fvol) {
	output.split('\n').forEach(function (line) {
		let logline = timenow() + ' | ' + line;

		/* log to file */
		loggerWrite(logsdir, jobname, logline + '\n', fvol);
	});
};

exports.read = function (jobname, logsdir, onData, onEnd) {
	loggerRead(logsdir, jobname, onData, onEnd);
};
