# cubic

Calculator for cubic function and cubic bezier. Provided with an inverse function from give X to t, which could be used to calculate Y then.

## Usage

    require! <[cubic]>
    bezier = new cubic.Bezier [0.2, 0.3, 0.4, 0.5]
    t = Math.random!
    assert(t = bezier.t(bezier.x(t)));


## LICENSE

MIT
