# Swifter.jl

  * iOS REPL with Swifter.jl + [AppConsole](https://github.com/wookay/AppConsole)

  [![Build Status](https://api.travis-ci.org/wookay/Swifter.jl.svg?branch=master)](https://travis-ci.org/wookay/Swifter.jl)


# Run server on your iOS app
```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        AppConsole(initial: self).run()
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
