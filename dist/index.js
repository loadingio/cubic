(function(){
  var Func, FuncMembers, Bezier, BezierMembers, cubic;
  Func = function(a, b, c, d){
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    return this;
  };
  Func.prototype = import$(Object.create(Object.prototype), FuncMembers = {
    calc: function(x, a, b, c, d){
      a == null && (a = this.a);
      b == null && (b = this.b);
      c == null && (c = this.c);
      d == null && (d = this.d);
      return a * Math.pow(x, 3) + b * Math.pow(x, 2) + c * x + d;
    },
    root: function(y, a, b, c, d){
      var A, B, C, delta, y1, y2, x1, k, t, theta, x2, x3;
      y == null && (y = 0);
      a == null && (a = this.a);
      b == null && (b = this.b);
      c == null && (c = this.c);
      d == null && (d = this.d);
      d = d - y;
      A = b * b - 3 * a * c;
      B = b * c - 9 * a * d;
      C = c * c - 3 * b * d;
      delta = B * B - 4 * A * C;
      if (A === B && B === 0) {
        return [-b / (3 * a), -c / b, -3 * d / c];
      }
      if (delta > 0) {
        y1 = A * b + 3 * a * (-B + Math.sqrt(B * B - 4 * A * C)) / 2;
        y2 = A * b + 3 * a * (-B - Math.sqrt(B * B - 4 * A * C)) / 2;
        x1 = (-b - (Math.cbrt(y1) + Math.cbrt(y2))) / (3 * a);
        return [x1];
      }
      if (delta === 0) {
        k = B / A;
        return [-b / a + k, -k / 2, -k / 2];
      }
      if (delta < 0) {
        t = (2 * A * b - 3 * a * B) / (2 * A * Math.sqrt(A));
        theta = Math.acos(t);
        x1 = (-b - 2 * Math.sqrt(A) * Math.cos(theta / 3)) / (3 * a);
        x2 = (-b + Math.sqrt(A) * (Math.cos(theta / 3) + Math.sqrt(3) * Math.sin(theta / 3))) / (3 * a);
        x3 = (-b + Math.sqrt(A) * (Math.cos(theta / 3) - Math.sqrt(3) * Math.sin(theta / 3))) / (3 * a);
        return [x1, x2, x3];
      }
    }
  });
  import$(Func, FuncMembers);
  Func.glsl = "float cubic(float x, vec4 p) {\n  return p.x * x * x * x + p.y * x * x + p.z * x + p.w;\n}\n/* 3 roots, 1 for root count */\nvec4 cubicRoot(float y, vec4 p) {\n  float a, b, c, d, A, B, C, D, y1, y2, k, theta, x1, x2, x3;\n  d = d - y;\n  A = b * b - 3. * a * c;\n  B = b * c - 9. * a * d;\n  C = c * c - 3. * b * d;\n  D = B * B - 4. * A * C;\n  if(A==B && B==0.) return vec4(-b / (3. * a), -c / b, -3. * d / c, 3.);\n  if(D > 0) {\n    y1 = A * b + 3. * a * (-B + sqrt(D)) * 0.5;\n    y2 = A * b + 3. * a * (-B - sqrt(D)) * 0.5;\n    return vec4(vec3(-b - (cbrt(y1) + cbrt(y2)) / ( 3. * a)), 1.);\n  } else if(D == 0) {\n    k = B/A;\n    return vec4((-b/a) + k, -k/2., -k/2., 2.);\n  } else if(D < 0) {\n    k = (2. * A * b - 3 * a * B) / (2. * A * sqrt(A));\n    theta = acos(k) / 3.;\n    x1 = (-b - 2. * sqrt(A) * cos(theta)) / (3. * a);\n    x2 = (-b + sqrt(A) * (cos(theta) + sqrt(3.) * sin(theta))) / (3. * a);\n    x3 = (-b + sqrt(A) * (cos(theta) - sqrt(3.) * sin(theta))) / (3. * a);\n    return vec4(x1, x2, x3, 3.);\n  }\n}";
  Bezier = function(p){
    var coff;
    this.p = p;
    this.coff = coff = [3 * p[0] - 3 * p[2] + 1, -6 * p[0] + 3 * p[2], 3 * p[0], 0];
    this.eq = new Func(coff[0], coff[1], coff[2], coff[3]);
    return this;
  };
  Bezier.prototype = import$(Object.create(Object.prototype), BezierMembers = {
    x2y: function(x, p){
      p == null && (p = this.p);
      return this.y(this.t(x));
    },
    x: function(t, p){
      p == null && (p = this.p);
      return 3 * Math.pow(1 - t, 2) * t * p[0] + 3 * (1 - t) * t * t * p[2] + t * t * t;
    },
    y: function(t, p){
      p == null && (p = this.p);
      return 3 * Math.pow(1 - t, 2) * t * p[1] + 3 * (1 - t) * t * t * p[3] + t * t * t;
    },
    t: function(x, p, err){
      var ret, r;
      err == null && (err = 0.000001);
      ret = p
        ? Func.root(x, 3 * p[0] - 3 * p[2] + 1, -6 * p[0] + 3 * p[2], 3 * p[0], 0)
        : this.eq.root(x);
      if (err) {
        ret = ret.map(function(it){
          return Math.round(it / err) * err;
        });
      }
      r = ret.filter(function(it){
        return it >= 0 && it <= 1;
      })[0];
      if (!(r != null)) {
        ret = ret.map(function(it){
          return [it, Math.min(Math.abs(it), Math.abs(it - 1))];
        });
        ret.sort(function(a, b){
          return a[0] - b[0];
        });
        return ret[0];
      }
      return r;
    }
  });
  import$(Bezier, BezierMembers);
  cubic = {
    func: Func,
    bezier: Bezier,
    Func: Func,
    Bezier: Bezier
  };
  if (typeof module != 'undefined' && module !== null) {
    module.exports = cubic;
  } else if (typeof window != 'undefined' && window !== null) {
    window.cubic = cubic;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
