using Swifter
using Base.Test

import Swifter: QueryResult, ResultInfo, App

@test 3 == QueryResult(ResultInfo(:any, 3), App(""),"",Dict())
@test 1.2 == QueryResult(ResultInfo(:any, 1.2), App(""),"",Dict())
@test true == QueryResult(ResultInfo(:any, true), App(""),"",Dict())
@test "Hello" == QueryResult(ResultInfo(:any, "Hello"), App(""),"",Dict())
@test ["A"] == QueryResult(ResultInfo(:any, ["A"]), App(""),"",Dict())
@test ["가"] == QueryResult(ResultInfo(:any, ["가"]), App(""),"",Dict())
@test Dict(1=>2) == QueryResult(ResultInfo(:any, Dict(1=>2)), App(""),"",Dict())

@test false == (3 === QueryResult(ResultInfo(:any, 3), App(""),"",Dict()))
