# Cubic ( x ^ 3 ) functions, based on Sheng Jin Formula ( 盛金公式 )
#   ref: https://zh.wikipedia.org/wiki/%E4%B8%89%E6%AC%A1%E6%96%B9%E7%A8%8B
# calculate f(x), or finding roots for f(x) = y

Func = (a, b, c, d) -> @ <<< {a, b, c, d}; return @
Func.prototype = Object.create(Object.prototype) <<< FuncMembers = do
  calc: (x, a = @a, b = @b, c = @c, d = @d) ->
    return a * (x ** 3) + b * (x ** 2) + c * (x) + d
  root: (y = 0, a = @a, b = @b, c = @c, d = @d) ->
    d = d - y
    A = b * b - 3 * a * c
    B = b * c - 9 * a * d
    C = c * c - 3 * b * d
    delta = B * B - 4 * A * C
    if A == B and B == 0 => return [-b / (3 * a), -c / b, -3 * d / c]
    if delta > 0 =>
      y1 = A * b + 3 * a * ( -B + Math.sqrt( B * B - 4 * A * C )) / 2
      y2 = A * b + 3 * a * ( -B - Math.sqrt( B * B - 4 * A * C )) / 2
      x1 = (-b - (Math.cbrt(y1) + Math.cbrt(y2))) / ( 3 * a)
      return [x1]
    if delta == 0 =>
      k = B/A
      return [(-b / a) + k, -k/2, -k/2 ]
    if delta < 0 =>
      t = (2 * A * b - 3 * a * B) / (2 * A * Math.sqrt(A))
      theta = Math.acos t
      x1 = (-b - 2 * Math.sqrt(A) * Math.cos(theta / 3)) / (3 * a)
      x2 = (-b + Math.sqrt(A) * ( Math.cos(theta / 3) + Math.sqrt(3) * Math.sin(theta / 3))) / (3 * a)
      x3 = (-b + Math.sqrt(A) * ( Math.cos(theta / 3) - Math.sqrt(3) * Math.sin(theta / 3))) / (3 * a)
      return [x1, x2, x3]

Func <<< FuncMembers

Func.glsl = """
float cubic(float x, vec4 p) {
  return p.x * x * x * x + p.y * x * x + p.z * x + p.w;
}
/* 3 roots, 1 for root count */
vec4 cubicRoot(float y, vec4 p) {
  float a, b, c, d, A, B, C, D, y1, y2, k, theta, x1, x2, x3;
  d = d - y;
  A = b * b - 3. * a * c;
  B = b * c - 9. * a * d;
  C = c * c - 3. * b * d;
  D = B * B - 4. * A * C;
  if(A==B && B==0.) return vec4(-b / (3. * a), -c / b, -3. * d / c, 3.);
  if(D > 0) {
    y1 = A * b + 3. * a * (-B + sqrt(D)) * 0.5;
    y2 = A * b + 3. * a * (-B - sqrt(D)) * 0.5;
    return vec4(vec3(-b - (cbrt(y1) + cbrt(y2)) / ( 3. * a)), 1.);
  } else if(D == 0) {
    k = B/A;
    return vec4((-b/a) + k, -k/2., -k/2., 2.);
  } else if(D < 0) {
    k = (2. * A * b - 3 * a * B) / (2. * A * sqrt(A));
    theta = acos(k) / 3.;
    x1 = (-b - 2. * sqrt(A) * cos(theta)) / (3. * a);
    x2 = (-b + sqrt(A) * (cos(theta) + sqrt(3.) * sin(theta))) / (3. * a);
    x3 = (-b + sqrt(A) * (cos(theta) - sqrt(3.) * sin(theta))) / (3. * a);
    return vec4(x1, x2, x3, 3.);
  }
}
"""

Bezier = (p) ->
  @ <<< {p}
  @coff = coff = [
    ( 3 * p.0 - 3 * p.2 + 1 ),
    (-6 * p.0 + 3 * p.2     ),
    ( 3 * p.0               ),
    0
  ]
  @eq = new Func coff.0, coff.1, coff.2, coff.3
  @

Bezier.prototype = Object.create(Object.prototype) <<< BezierMembers = do
  x2y: (x, p = @p) -> @y @t x
  x: (t, p = @p) -> 3 * ((1 - t) ** 2) * t * p.0 + 3 * (1 - t) * t * t * p.2 + t * t * t
  y: (t, p = @p) -> 3 * ((1 - t) ** 2) * t * p.1 + 3 * (1 - t) * t * t * p.3 + t * t * t
  t: (x, p, err=0.000001) ->
    ret = if p => Func.root(x, ( 3 * p.0 - 3 * p.2 + 1 ), (-6 * p.0 + 3 * p.2 ), ( 3 * p.0 ), 0)
    else @eq.root(x)
    # sometimes calculated result are quite close to 0 but slightly small, like 1e-17.
    # we add an err threshold for fixing this.
    if err => ret = ret.map -> Math.round( it / err ) * err
    r = ret.filter(->it >= 0 and it <= 1).0
    # if we still can't find a valid solution, then just give the closest one.
    if !(r?) =>
      ret = ret.map -> [it, Math.min(Math.abs(it),Math.abs(it - 1))]
      ret.sort ((a,b) -> a.0 - b.0)
      return ret.0
    return r

Bezier <<< BezierMembers

cubic = {
  func: Func
  bezier: Bezier
  Func: Func      # deprecated
  Bezier: Bezier  # deprecated
}

if module? => module.exports = cubic
else if window? => window.cubic = cubic
