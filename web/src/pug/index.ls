pts = [0.5, 0.0, 0.5, 1.0]
cubic.Bezier.x 

hex = (r = 0, g = 0, b = 0) ->
  [r, g, b] = [r * 255, g * 255, b * 255].map -> Math.floor(it)
  "#" + ("#{(r * 65536 + g * 256 + b).toString(16)}".padStart(6,"0"))
canvas = ld$.find \canvas, 0
ctx = canvas.getContext \2d
w = canvas.width
h = canvas.height
dot = (_x, _y, c) ->
  x = _x * (w - 20) + 10
  y = h - (_y * (h - 20) + 10)
  ctx.beginPath!
  ctx.arc x, y, 3, 0, 2 * Math.PI, false
  ctx.fillStyle = c
  ctx.fill!

for t from 0 til 1 by 0.01 =>
  x = cubic.Bezier.x(t, pts)
  y = cubic.Bezier.y(t, pts)
  c = hex(0, 0, t)
  dot x, y, c

for x from 0 til 1 by 0.001 =>
  y = cubic.Bezier.y(cubic.Bezier.t(x, pts), pts)
  c = hex(x, 0, 0)
  dot x, y, c

