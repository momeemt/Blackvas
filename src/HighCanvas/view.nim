import macros
import strformat

macro view*(head, body: untyped): untyped =
  discard