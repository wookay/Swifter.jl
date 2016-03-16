# Swifter.jl

  * iOS REPL with Swifter.jl + [AppConsole](https://github.com/wookay/AppConsole)

  [![Build Status](https://api.travis-ci.org/wookay/Swifter.jl.svg?branch=master)](https://travis-ci.org/wookay/Swifter.jl)
  [![AppVeyor Status](https://ci.appveyor.com/api/projects/status/o2s4mck7t36ox7jk/branch/master?svg=true)](https://ci.appveyor.com/project/wookay/swifter-jl/branch/master)
  [![Coverage Status](https://coveralls.io/repos/github/wookay/Swifter.jl/badge.svg?branch=master)](https://coveralls.io/github/wookay/Swifter.jl?branch=master)



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
julia> using Swifter

julia> vc = initial("http://localhost:8080")
Swifter.Memory(Swifter.App("http://localhost:8080"),"0x7f9238f1e4b0")

julia> @query vc.view.backgroundColor = UIColor.greenColor()
"UIDeviceRGBColorSpace 0 1 0 1"
```

* Query mode : pressing the `>` key.

```julia
Swifter> vc.view.frame
"{{0, 0}, {320, 568}}"

Swifter> vc.label.text = "hello world"
"hello world"

Swifter> vc.label.backgroundColor = UIColor.yellowColor()
"UIDeviceRGBColorSpace 1 1 0 1"

Swifter> vc.label.font = UIFont(name: "Helvetica", size: 50)
"<UICTFont: 0x7faa91461b40> font-family: \"Helvetica\"; font-weight: normal; font-style: normal; font-size: 50.00pt"
```

* Setting the custom key
```
julia> ENV["SWIFTER_QUERY_MODE_KEY"] = ">"
">"

julia> using Swifter
```
