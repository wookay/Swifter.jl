using Swifter
using Base.Test

vc = initial("http://localhost:8000")
result = @query vc.view.backgroundColor = UIColor.greenColor()
@test "UIDeviceRGBColorSpace 0 1 0 1" == result
