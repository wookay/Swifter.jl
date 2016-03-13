# Swifter.jl

  * iOS REPL with Swifter.jl + [Console](https://github.com/wookay/Console)

  [![Build Status](https://api.travis-ci.org/wookay/Swifter.jl.svg?branch=master)](https://travis-ci.org/wookay/Swifter.jl)


# Run server on your iOS app
```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        Console(initial: self).run()
    }
}
```


# REPL client with Julia
```julia
using Swifter

simulator = App("http://localhost:8080")
vc = initial(simulator)

@query vc.view.backgroundColor = UIColor.greenColor()
```
