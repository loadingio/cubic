# cubic

Calculator for cubic function and cubic bezier. Provided with an inverse function from given X to t, which could be used to calculate Y then.

Equation roots calculation use Sheng Jin Formula which might be inaccurate according to Kahan; there is an alternative solution here: https://www.npmjs.com/package/cubic-roots , which could be integrated in the future.


## Usage

    require! <[cubic]>
    bezier = new cubic.bezier [0.2, 0.3, 0.4, 0.5]
    t = Math.random!
    x = bezier.x t
    y = bezier.y t
    t-from-x = bezier.t x
    
    assert t == t-from-x

    coff = [0 to 3].map -> Math.random!
    func = new cubic.func coff.0, coff.1, coff.2, coff.3
    x = Math.random!
    func.calc x             # f(x)
    root = func.root 0      # root for solving f(x) = 0


For a simply `x -> y` bezier calculation:

    b = new cubic.bezier([....])
    [0 to 1 by 0.1].map (x) -> y = b.y(bezier.t(x))


## Compatibility

cubic use `Math.cbrt` which is not available in IE < 11. You can simply use a polyfill or following code:

```
    Math.cbrt = -> Math.pow(it, 1/3)
```


## LICENSE

MIT
