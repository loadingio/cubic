# cubic

Calculator for cubic function and cubic bezier. Provided with an inverse function from give X to t, which could be used to calculate Y then.

Equation roots calculation use Sheng Jin Formula which might be inaccurate according to Kahan; there is an alternative solution here: https://www.npmjs.com/package/cubic-roots , which could be integrated in the future.


## Usage

    require! <[cubic]>
    bezier = new cubic.Bezier [0.2, 0.3, 0.4, 0.5]
    t = Math.random!
    x = bezier.x t
    y = bezier.y t
    t-from-x = bezier.t x
    
    assert t == t-from-x

    coff = [0 to 3].map -> Math.random!
    func = new cubic.Func coff.0, coff.1, coff.2, coff.3
    x = Math.random!
    func.calc x             # f(x)
    root = func.root 0      # root for solving f(x) = 0


## LICENSE

MIT
