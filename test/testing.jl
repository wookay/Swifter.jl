using Swifter
using Base.Test

import Swifter: QueryResult

@test 3 == QueryResult(:any, 3, (nothing,"",Dict()))
@test 1.2 == QueryResult(:any, 1.2, (nothing,"",Dict()))
@test true == QueryResult(:any, true, (nothing,"",Dict()))
@test "Hello" == QueryResult(:any, "Hello", (nothing,"",Dict()))
@test ["A"] == QueryResult(:any, ["A"], (nothing,"",Dict()))
@test Dict(1=>2) == QueryResult(:any, Dict(1=>2), (nothing,"",Dict()))
