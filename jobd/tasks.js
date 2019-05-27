var g_tasks = [ /* {id: 123, joblist: [{name: 'abc', }, ...]} */];
var g_id = 0;

exports.create = function(runList) {
	g_id += 1;
	var new_task = {
		"id": g_id, /* task ID */
		"cur_job_idx": 0, /* current job index */
		"parent_task": 0, /* parent task ID */
		joblist: []
	};

	for (var i = 0; i < runList.length; i++) {
		new_task.joblist.push({
			'name': runList[i], /* task job name */
			'touch_cnt': 0, /* count the number of touching to this task job */
			'invoke_time': 0, /* invoke timestamp */
			'last_exitcode': 0, /* last time exist code */
			'last_pid': 0, /* last time PID */
			'finish_time': 0, /* finish timestamp */
			'cronTab': '', /* cronJob table string */
			'cronJob': null /* cronJob instance */
		});
	};

	g_tasks.unshift(new_task);
	return new_task;
};

exports.getAll = function() {
	let show_tasks = [];
	for (var i = 0; i < g_tasks.length; i++) {
		let task = g_tasks[i];
		let show_task = omit_key(task, 'joblist');
		show_task.joblist = [];
		for (var j = 0; j < task.joblist.length; j++) {
			let task_job = task.joblist[j];
			let show_task_job = omit_key(task_job, 'cronJob');
			show_task_job = omit_key(show_task_job, 'cronTab');
			let cronJob = task_job['cronJob'];
			if (task_job['cronJob']) {
				show_task_job['cronTimeTab'] = task_job['cronTab'];
				show_task_job['cronRunning'] = task_job['cronJob'].running;
			}
			show_task.joblist.push(show_task_job);
		}
		show_tasks.push(show_task);
	}
	return show_tasks;
};

function omit_key(obj, omitKey) {
	return Object.keys(obj).reduce((result, key) => {
		if(key !== omitKey) {
			result[key] = obj[key];
		}
		return result;
	}, {});
}

exports.clear = function() {
	while (g_tasks.length) {
		exports.kill(g_tasks[0].id);
	}
};

exports.kill = function(taskID) {
	for (var i = 0; i < g_tasks.length; i++) {
		let task = g_tasks[i];
		if (taskID == task.id) {
			for (var j = 0; j < task.joblist.length; j++) {
				let task_job = task.joblist[j];
				let cronJob = task_job['cronJob'];
				cronJob && cronJob.stop(); /* stop timer */
			};
			g_tasks.splice(i, 1); // remove this task record
		}
	};
};
