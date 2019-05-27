exports.syncLoop = function (arr, deed, done) {
	let idx = 0;
	let loop = {
		next: function () {
			if (idx + 1 < arr.length) {
				deed(arr, idx + 1, loop);
				idx = idx + 1;
			} else {
				done(arr, arr.length - 1, loop, true);
			}
		},
		again: function () {
			deed(arr, idx, loop);
		},
		brk: function () {
			idx = arr.length - 1;
			done(arr, idx, loop, false);
		}
	};

	loop.again();
}
