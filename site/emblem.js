// The emblem of Delta Hex OS: three spirals in a circle, turning. Each spiral is drawn by the same rule as the D
// digits: a hex spiral, lines 1, 1, 2, 2, 3, 3 ... long, turning a sixth of a turn at each corner. The circle is a walk
// of small hex steps. Colours: chemistry, heat, current. Still when the reader asks for less motion.
(function () {
  var cv = document.getElementById("emblem");
  if (!cv) return;
  var cx = cv.getContext("2d");
  var still = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var colours = ["#B48CF0", "#FF8A3D", "#7DB4FF"];
  var sixth = Math.PI / 3;

  function size() {
    var r = window.devicePixelRatio || 1, w = cv.clientWidth;
    cv.width = Math.round(w * r); cv.height = Math.round(w * r);
  }

  function spiral(x, y, n, unit, turn) {
    var px = 0, py = 0, a = turn, pts = [[0, 0]];
    for (var i = 0; i <= n; i++) {
      var len = (1 + Math.floor(i / 2)) * unit;
      px += len * Math.cos(a); py += len * Math.sin(a);
      pts.push([px, py]); a += sixth;
    }
    var mx = 0, my = 0;
    pts.forEach(function (p) { mx += p[0]; my += p[1]; });
    mx /= pts.length; my /= pts.length;
    cx.beginPath();
    pts.forEach(function (p, k) {
      var X = x + p[0] - mx, Y = y + p[1] - my;
      if (k) cx.lineTo(X, Y); else cx.moveTo(X, Y);
    });
    cx.stroke();
  }

  function ring(x, y, R) {                       // small hex steps round the middle (the screen is the square bridge)
    var steps = 96;
    cx.beginPath();
    for (var i = 0; i <= steps; i++) {
      var a = (i + 0.5) / steps * Math.PI * 2, X = x + R * Math.cos(a), Y = y + R * Math.sin(a);
      if (i) cx.lineTo(X, Y); else cx.moveTo(X, Y);
    }
    cx.stroke();
  }

  function draw(t) {
    var W = cv.width, c = W / 2, R = W * 0.42;
    cx.clearRect(0, 0, W, W);
    cx.lineCap = "round"; cx.lineJoin = "round";
    cx.strokeStyle = "#E6BE6E"; cx.lineWidth = W * 0.022;
    ring(c, c, R);
    cx.lineWidth = W * 0.009;
    for (var k = 0; k < 3; k++) {
      var place = k * 2 * Math.PI / 3 - Math.PI / 2;
      cx.strokeStyle = colours[k];
      spiral(c + R * 0.42 * Math.cos(place), c + R * 0.42 * Math.sin(place), 13, W * 0.024, t * 0.0006 + k * 2.1);
    }
  }

  size();
  window.addEventListener("resize", function () { size(); draw(performance.now()); });
  if (still) { draw(0); return; }
  (function frame(t) { draw(t); requestAnimationFrame(frame); })(0);
})();
