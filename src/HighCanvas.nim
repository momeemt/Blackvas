# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.
import dom

proc add*(x, y: int): int =
  ## Adds two files together.
  return x + y

type t1 = enum
  a
  b
  c

proc canvas(id: cstring): t1 {.exportc.} =
  discard getElementById(id)
  result = a

# let canvas = init("canvas")