const w = 400;
const h = 400;

const left = ce("div", { parent: body, style: { float: "left" } });

const can = ce("canvas", {
	parent: left,
	width: w,
	height: h,
	style: { border: "1px solid black" }
});
const ctx = can.getContext("2d");

ce("br", { parent: left });

ct(
	"press a button on the right for a preset or copy your first six\ncalibration numbers from your xinput config here:",
	left
);
ce("br", { parent: left });
const inp = ce("input", {
	parent: left,
	//      h scale, v skew, h move
	//      h skew, v scale, v move
	//value: '1.2,0,-0.1, 0,1.2,-0.1',
	value: "1.13 0 -0.08 0 -1.13 1.07",
	style: {
		width: w + "px",
		boxSizing: "border-box"
	}
});

ce("br", { parent: left });
ct("click ", left);
ce("a", {
	parent: left,
	href:
		"https://user-images.githubusercontent.com/559564/31281485-d7b568e4-aaaf-11e7-85c8-ca1074e597ee.gif",
	target: "_blank",
	textContent: "here"
});
ct(" to see instructions in how to use arrow keys", left);
ce("br", { parent: left });
ce("br", { parent: left });
ct("copy this into your xorg config:", left);
ce("br", { parent: left });
const out = ce("input", {
	parent: left,
	readOnly: true,
	style: { width: w + "px", boxSizing: "border-box" }
});
out.addEventListener("click", function (e) {
	this.selectionStart = 0;
	this.selectionEnd = this.value.length;
});
ce("br", { parent: left });
ce("br", { parent: left });
ct("copy this into your ssh shell to test calibration:", left);
ce("br", { parent: left });
const out2 = ce("input", {
	parent: left,
	readOnly: true,
	style: { width: w + "px", boxSizing: "border-box" }
});
out2.addEventListener("click", function (e) {
	this.selectionStart = 0;
	this.selectionEnd = this.value.length;
});

const right = ce("div", { parent: body, style: { position: "float" } });

ce("button", { parent: right, textContent: "1:1 mapping" }).addEventListener(
	"click",
	(e) => (inp.value = "1 0 0 0 1 0")
);
ce("br", { parent: right });
ce("button", { parent: right, textContent: "rotate right" }).addEventListener(
	"click",
	(e) => (inp.value = "0 -1 1 1 0 0")
);
ce("br", { parent: right });
ce("button", { parent: right, textContent: "rotate left" }).addEventListener(
	"click",
	(e) => (inp.value = "0 1 0 -1 0 1")
);
ce("br", { parent: right });
ce("button", { parent: right, textContent: "flip x" }).addEventListener(
	"click",
	(e) => (inp.value = "-1 0 1 0 1 0")
);
ce("br", { parent: right });
ce("button", { parent: right, textContent: "flip y" }).addEventListener(
	"click",
	(e) => (inp.value = "1 0 0 0 -1 1")
);

inp.addEventListener("keydown", function (e) {
	const up = e.which === 38;
	const down = e.which === 40;
	if (!up && !down) return;

	e.preventDefault();
	e.stopPropagation();

	let start = this.selectionStart;
	const tokens = this.value.match(/[-+]?(\d+|\.\d+|\d+\.\d*)(\s+|$)/g);
	if (!tokens) return;
	let token = null;
	let tokenOffset = 0;
	let pointer = 0;
	for (; tokenOffset < tokens.length; tokenOffset++) {
		token = tokens[tokenOffset];
		if (start < pointer + token.length) {
			break;
		}
		pointer += token.length;
	}

	let offset = start - pointer;

	let nStart = token.match(/\d/);
	if (!nStart) return;
	nStart = nStart.index;

	let nDot = token.match(/\./);
	if (nDot) nDot = nDot.index;
	else nDot = token.match(/\d\s*$/).index + 1;

	let neg = /-/.test(token);

	let exp = nDot - nStart - 1;
	if (offset > nStart) exp -= offset - nStart;
	if (offset > nDot) exp++;
	exp = Math.pow(10, exp);
	if (down) exp = -exp;

	const oldToken = parseFloat(token, 10);
	const newToken = oldToken + exp;
	if (newToken >= 0 && oldToken < 0) start--;
	if (oldToken >= 0 && newToken < 0) start++;
	let newValue = parseFloat((parseFloat(token, 10) + exp).toFixed(8), 10);

	let value = tokens
		.map((t, i) => {
			return i == tokenOffset ? newValue + token.match(/(\s*)$/)[1] : t;
		})
		.join("");
	this.value = value;
	this.selectionStart = start;
	this.selectionEnd = start;
});

/*
	math:
	h scale
	v skew
	h move
	h skew
	v scale
	v move

	canvas:
	a	Horizontal scaling
	b	Horizontal skewing
	c	Vertical skewing
	d	Vertical scaling
	e	Horizontal moving
	f	Vertical moving
*/

ctx.font = "300px Arial";
ctx.textAlign = "center";
ctx.textBaseline = "middle";
ctx.lineWidth = 2;

let cache = "";

const drawBox = (time) => {
	ctx.strokeRect(0, 0, w, h);
	ctx.strokeText("F", w / 2, h / 2);
	ctx.beginPath();
	let x = w / 2 - Math.sin(time * 1e-3) * (w / 2 - 10);
	let y = h / 2 + Math.cos(time * 1e-3) * (w / 2 - 10);
	ctx.arc(x, y, 10, 0, 2 * Math.PI, false);
	ctx.stroke();
};

const draw = function (time) {
	ctx.save();
	ctx.clearRect(0, 0, w, h);
	ctx.transform(0.5, 0, 0, 0.5, 100, 100);
	ctx.strokeStyle = "black";
	drawBox(time);
	try {
		const [a, c, e, b, d, f] = inp.value
			.trim()
			.split(/\s+/)
			.map((x) => parseFloat(x.trim(), 10));
		ctx.transform(a, b, c, d, e * w, f * h);
	} catch (e) {}
	ctx.strokeStyle = "red";
	drawBox(time);
	ctx.restore();
	if (cache != inp.value) {
		out.value = 'Option "TransformationMatrix" "' + inp.value + ' 0 0 1"';
		out2.value =
			'DISPLAY=:0.0 xinput set-prop 6 "Coordinate Transformation Matrix" ' +
			inp.value +
			" 0 0 1";
		cache = inp.value;
	}
	requestAnimationFrame(draw);
};

requestAnimationFrame(draw);