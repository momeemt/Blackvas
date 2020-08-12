import macros

macro methods*(body: untyped): untyped =
  result = body