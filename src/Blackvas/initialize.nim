import macros


macro init* (body: untyped): untyped =
  result = newStmtList()
  result.add body